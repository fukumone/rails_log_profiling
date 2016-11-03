require "rails/log/profiling/version"

module Rails
  module Log
    module Profiling
      include ActiveSupport::Configurable

      # クエリのプロファイルリングを設定
      config_accessor :query_profiling_enable, instance_accessor: false do
        false
      end

      # Viewのプロファイリングを設定
      config_accessor :view_profiling_enable, instance_accessor: false do
        false
      end

      config_accessor :query_logger, instance_accessor: false  do
        ""
      end

      config_accessor :view_logger, instance_accessor: false  do
        ""
      end

      config_accessor :sqls, instance_accessor: false  do
        []
      end

      config_accessor :sort_order, instance_accessor: false do
        "desc"
      end

      config_accessor :current_path, instance_accessor: false do
        ""
      end

      config_accessor :rendering_pages, instance_accessor: false do
        { parent: "", children: {} }
      end
    end
  end
end

if defined?(Rails)
  class Railtie < ::Rails::Railtie
    initializer "rails_log_profiling.configure_rails_initialization" do
      if Rails::Log::Profiling.query_profiling_enable
        require 'rails/log/profiling/query_profiling_logger'
        require 'rails/log/profiling/query_profiling'
        require 'rails/log/profiling/query_log_subscriber'
        require 'rails/log/profiling/action_controller'
      end

      if Rails::Log::Profiling.view_profiling_enable
        require 'rails/log/profiling/view_profilng_logger'
        require 'rails/log/profiling/view_log_subscriber'
      end
    end
  end
end
