module Rails
  module Log
    module Profiling
      class QueryProfiling
        def self.execute
          return if Rails::Log::Profiling.sqls.empty?
          self.query_sort
          Rails::Log::Profiling.sqls.each.with_index(1) do |val, ind|
            Rails::Log::Profiling.query_logger.debug("\n \033[36m #{ind}:" + val[1]) # colorで出力
          end
          Rails::Log::Profiling.sqls.clear
        end

        protected
          def self.query_sort
            if Rails::Log::Profiling.sort_order == "desc"
              Rails::Log::Profiling.sqls.sort! { |a, b| b[0] <=> a[0] }
            else # sort_order asc
              Rails::Log::Profiling.sqls.sort!
            end
          end
      end
    end
  end
end
