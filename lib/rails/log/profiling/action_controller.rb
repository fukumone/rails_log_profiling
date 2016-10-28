require 'action_controller'

module ActionController
  class Base
    include Rails::Log::Profiling
    after_action :logger_execute

    private
      def logger_execute
        unless Rails::Log::Profiling.sqls.empty?
          controller_name = params[:controller].split("_").map(&:capitalize).join
          Rails::Log::Profiling.logger.info("\n\033[36m #{controller_name}Controller##{params[:action]}")
          Rails::Log::Profiling.logger.info("\n \033[36m" + Rails::Log::Profiling.sqls.count.to_s + "件のクエリの検知")
          Rails::Log::Profiling::QueryProfiling.execute
        end
      end
  end
end
