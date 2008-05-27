# Change the logging slightly so it chops out the annoying eager-loading code (t1_t2 AS foo)
# and shows a returned record count in the sql log.
#
if RAILS_ENV != 'production'
  module ActiveRecord
    module ConnectionAdapters # :nodoc:
      class AbstractAdapter
        protected
          alias_method :old_log, :log
          
          def log(sql, name, &block)
            if block_given?
              if @logger and @logger.level <= Logger::INFO
                result = nil
                seconds = Benchmark.realtime { result = yield }
                @runtime += seconds
                s = result.respond_to?(:num_rows) ? result.num_rows : 0
                log_info(sql, name, seconds, s)
                return result
              end
            end
            old_log(sql, name) { yield }
          rescue Exception => e
            @last_verification = 0
            message = "#{e.class.name}: #{e.message}: #{sql}"
            log_info(message, name, 0)
            raise ActiveRecord::StatementInvalid, message
          end
          
          alias_method :old_log_info, :log_info
          def log_info(sql, name, runtime, result_size = 0)
            if name =~ /Load Including Associations$/
              sql = sql.scan(/SELECT /).to_s + ' ...<snip>... ' + sql.scan(/(FROM .*)$/).to_s
            end
            name = "#{name} (#{result_size.to_i})"
            old_log_info(sql, name, runtime)
          end
      end
    end
  end
end