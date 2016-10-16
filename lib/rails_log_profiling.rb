require "rails/log/profiling/version"
require 'rails/log/profiling/logger'
require 'rails/log/profiling/query_profiling'
require 'action_controller'
require 'action_controller/log_subscriber'
require "active_record"
require "active_record/log_subscriber"

module Rails
  module Log
    module Profiling
      include ActiveSupport::Configurable

      config_accessor :logger, instance_accessor: false  do
        ""
      end

      config_accessor :match_paths, instance_accessor: false do
        []
      end

      config_accessor :logger_ok, instance_accessor: false do
        false
      end

      config_accessor :sqls, instance: false, instance_accessor: false  do
        []
      end

      if defined?(Rails)
        class Railtie < ::Rails::Railtie
          initializer "rails_log_profiling.configure_rails_initialization" do
            ::Rails::Log::Profiling::Logger.run
          end
        end
      end

      class QueryLogSubscriber < ActiveRecord::LogSubscriber
        def sql(event)
          return unless Rails::Log::Profiling.logger.debug?
          payload = event.payload

          return if IGNORE_PAYLOAD_NAMES.include?(payload[:name])

          name  = "#{payload[:name]} (#{event.duration.round(1)}ms)"
          sql   = payload[:sql]
          binds = nil

          unless (payload[:binds] || []).empty?
            binds = "  " + payload[:binds].map { |attr| render_bind(attr) }.inspect
          end

          name = colorize_payload_name(name, payload[:name])
          sql  = color(sql, sql_color(sql), true)

          Rails::Log::Profiling.sqls << [ "#{event.duration.round(1)}".to_f, "  #{name}  #{sql}#{binds}"]
        end
      end

      class ActionLogSubscriber < ActionController::LogSubscriber
        def start_processing(event)
          return unless Rails::Log::Profiling.logger.debug?
          payload = event.payload
          if Rails::Log::Profiling.logger_ok
            Rails::Log::Profiling.logger.debug "#{payload[:controller]}##{payload[:action]}"
          end
          Rails::Log::Profiling.logger_ok = true
        end

        def process_action(event)
          return unless Rails::Log::Profiling.logger.debug?
          Rails::Log::Profiling::QueryProfiling.execute
          Rails::Log::Profiling.logger_ok = false
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
