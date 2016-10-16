module Rails
  module Log
    module Profiling
      class QueryProfiling
        def self.execute
          return if Rails::Log::Profiling.sqls.empty?
          Rails::Log::Profiling.sqls.sort! { |a, b| b[0] <=> a[0] }

          Rails::Log::Profiling.sqls.each.with_index(1) do |val, ind|
            Rails::Log::Profiling.logger.debug("\n \033[36m #{ind}:" + val[1]) # colorで出力
          end
          Rails::Log::Profiling.sqls.clear
        end
      end
    end
  end
end
