require 'action_controller'

module ActionController
  class Base
    include Rails::Log::Profiling
    before_action :controller_action_message
    after_action :logger_execute

    private
      def controller_action_message
        controller_name = params[:controller].split("_").map(&:capitalize).join
        Rails::Log::Profiling.logger.info("\n \033[36m #{controller_name}Controller##{params[:action]}")
      end

      def logger_execute
        Rails::Log::Profiling.logger.info("\n \033[36m" + Rails::Log::Profiling.sqls.count.to_s + "件のクエリの検知")
        Rails::Log::Profiling::QueryProfiling.execute
      end
  end
end
