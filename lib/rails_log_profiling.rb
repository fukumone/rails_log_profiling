require "rails/log/profiling/version"

module Rails
  module Log
    module Profiling
      include ActiveSupport::Configurable

      config_accessor :logger, instance_accessor: false  do
        ""
      end

      config_accessor :sqls, instance_accessor: false  do
        []
      end

      config_accessor :enable, instance_accessor: false do
        false
      end

      config_accessor :sort_order, instance_accessor: false do
        "desc"
      end

      if defined?(Rails)
        class Railtie < ::Rails::Railtie
          initializer "rails_log_profiling.configure_rails_initialization" do
            if Rails::Log::Profiling.enable
              require 'rails/log/profiling/logger'
              require 'rails/log/profiling/query_profiling'
              require 'rails/log/profiling/query_log_subscriber'
              ::Rails::Log::Profiling::Logger.run
              require 'rails/log/profiling/action_controller'
            end
          end
        end
      end

    end
  end
end

ActiveSupport.on_load(:active_record) do
  if Rails::Log::Profiling.enable
    Rails::Log::Profiling::QueryLogSubscriber.attach_to :active_record
  end
end
