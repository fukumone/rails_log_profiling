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

          if ActiveRecord.version >= Gem::Version.new("5.0.0.beta")
            ar_ver_5(event)
          else
            ar_ver_4(event)
          end
        end

        private

          def ar_ver_5(event)
            payload = event.payload
            name  = "#{payload[:name]} (#{event.duration.round(1)}ms)"
            sql   = payload[:sql]
            binds = nil

            unless (payload[:binds] || []).empty?
              binds = "  " + payload[:binds].map { |attr| render_bind(attr) }.inspect
            end

            name = colorize_payload_name(name, payload[:name])
            sql  = color(sql, sql_color(sql), true)

            if !name.match(/.*ActiveRecord::SchemaMigration.*/) && name.match(/.*Load.\(.*ms\).*/)
              Rails::Log::Profiling.sqls << [ "#{event.duration.round(1)}".to_f, "  #{name}  #{sql}#{binds}"]
            end
          end

          def ar_ver_4(event)
            payload = event.payload
            name  = '%s (%.1fms)' % [payload[:name], event.duration]
            sql   = payload[:sql].squeeze(' ')
            binds = nil

            unless (payload[:binds] || []).empty?
              binds = "  " + payload[:binds].map { |col,v|
                if col
                  [col.name, v]
                else
                  [nil, v]
                end
              }.inspect
            end

            if odd?
              name = color(name, CYAN, true)
              sql  = color(sql, nil, true)
            else
              name = color(name, MAGENTA, true)
            end

            if !name.match(/.*ActiveRecord::SchemaMigration.*/) && name.match(/.*Load.\(.*ms\).*/)
              Rails::Log::Profiling.sqls << [ "#{event.duration.round(1)}".to_f, "  #{name}  #{sql}#{binds}" ]
            end
          end
      end
    end
  end
end

if defined?(Rails)
  module ActionController
    class Base
      include Rails::Log::Profiling
      before_filter :controller_action_message
      after_filter :logger_execute

      private
        def controller_action_message
          controller_name = params[:controller].split("_").map(&:capitalize).join
          Rails::Log::Profiling.logger.info("#{controller_name}Controller##{params[:action]}")
        end

        def logger_execute
          Rails::Log::Profiling::QueryProfiling.execute
        end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  Rails::Log::Profiling::QueryLogSubscriber.attach_to :active_record
end
