require "rails/log/profiling/version"
require 'rails/log/profiling/logger'
require 'action_controller'
require 'action_controller/log_subscriber'
require "active_record"
require "active_record/log_subscriber"
require "rails/log/profiling/railtie" if defined?(Rails)

module Rails
  module Log
    module Profiling
      include ActiveSupport::Configurable

      config_accessor :logger, instance: false, instance_accessor: false  do
        ""
      end

      class Railtie < ::Rails::Railtie
        initializer "rails_log_profiling.configure_rails_initialization" do
          ::Rails::Log::Profiling::Logger.run
        end
      end

      class QueryLogSubscriber < ActiveRecord::LogSubscriber
        alias_method :origin_sql, :sql
        def sql(event)
          origin_sql(event)
          Rails::Log::Profiling.logger.info(event)
          # TODO: loggerの処理を書く、rails_log_profiling.logに書いていく処理を追加
        end
      end

      class ActionLogSubscriber < ActionController::LogSubscriber
        INTERNAL_PARAMS = %w(controller action format _method only_path)
        alias_method :origin_start_processing, :start_processing
        def start_processing(event)
          origin_start_processing(event)
          # TODO: loggerの処理を書く、rails_log_profiling.logに書いていく処理を追加
        end
      end

      # class ViewLogSubscriber < ActionView::LogSubscriber
      #   # TODO: loggerの処理を書く、rails_log_profiling.logに書いていく処理を追加
      # end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  Rails::Log::Profiling::QueryLogSubscriber.attach_to :active_record
end

ActiveSupport.on_load(:action_controller) do
  Rails::Log::Profiling::ActionLogSubscriber.attach_to :action_controller
end

# initializer :initialize_logger, group: :all do
#   Rails.logger ||= config.logger || begin
#     path = config.paths["log"].first
#     unless File.exist? File.dirname path
#       FileUtils.mkdir_p File.dirname path
#     end

#     f = File.open path, 'a'
#     f.binmode
#     f.sync = config.autoflush_log # if true make sure every write flushes

#     logger = ActiveSupport::Logger.new f
#     logger.formatter = config.log_formatter
#     logger = ActiveSupport::TaggedLogging.new(logger)
#     logger
#   rescue StandardError
#     logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDERR))
#     logger.level = ActiveSupport::Logger::WARN
#     logger.warn(
#       "Rails Error: Unable to access log file. Please ensure that #{path} exists and is writable " +
#       "(ie, make it writable for user and group: chmod 0664 #{path}). " +
#       "The log level has been raised to WARN and the output directed to STDERR until the problem is fixed."
#     )
#     logger
#   end

#   Rails.logger.level = ActiveSupport::Logger.const_get(config.log_level.to_s.upcase)
# end
