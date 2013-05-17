module Paperplane
  class Notifier
    def initialize(opts = nil)
      @connection = Connection.new(opts)
    end

    def push(notifications)
      notifications = Array(notifications)

      with_connection do
        notifications.map { |n| @connection.write(n.to_bytes) }
      end
    end

    private

    def with_connection
      @connection.open unless @connection.open?
      yield
    ensure
      @connection.close
    end
  end
end