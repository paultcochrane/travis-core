require 'zlib'

module Travis
  # http://hashrocket.com/blog/posts/advisory-locks-in-postgres
  # https://github.com/mceachen/with_advisory_lock
  # 13.3.4. Advisory Locks : http://www.postgresql.org/docs/9.3/static/explicit-locking.html
  # http://www.postgresql.org/docs/9.3/static/functions-admin.html#FUNCTIONS-ADVISORY-LOCKS
  class AdvisoryLocks
    attr_reader :lock_name

    def initialize(lock_name)
      @lock_name = lock_name
    end

    # must be used within a transaction
    def self.exclusive(lock_name, timeout = 30)
      al = self.new(lock_name)
      al.exclusive(timeout) { yield }
    end

    # must be used within a transaction
    def exclusive(timeout = 30)
      give_up_at = Time.now + timeout if timeout
      while timeout.nil? || Time.now < give_up_at do
        if obtained_lock?
          return yield
        else
          # Randomizing sleep time may help reduce contention.
          sleep(rand(0.1..0.2))
        end
      end
    end

    private

    def obtained_lock?
      result = connection.select_value("select pg_try_advisory_xact_lock(#{lock_code});")
      result == 't' || result == 'true'
    end

    def connection
      ActiveRecord::Base.connection
    end

    def lock_code
      Zlib.crc32(lock_name)
    end
  end
end