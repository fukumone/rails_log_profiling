require "active_record"
require "active_record/log_subscriber"

module Rails::Log::Profiling
  class QueryLogSubscriber < ActiveRecord::LogSubscriber
    def sql(event)
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

        locations = get_locations

        if !name.match(/.*ActiveRecord::SchemaMigration.*/) && name.match(/.*Load.\(.*ms\).*/)
          Rails::Log::Profiling.sqls << [ "#{event.duration.round(1)}".to_f, "  #{name}  #{sql}#{binds}\n#{locations}"]
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

        locations = get_locations

        if !name.match(/.*ActiveRecord::SchemaMigration.*/) && name.match(/.*Load.\(.*ms\).*/)
          Rails::Log::Profiling.sqls << [ "#{event.duration.round(1)}".to_f, "  #{name}  #{sql}#{binds}\n #{locations}" ]
        end
      end

      def get_locations
        ans = ""
        caller.each do |val|
          if val =~ /#{Rails::Log::Profiling.current_path}/
            ans += val
          end
        end
        ans
      end
  end
end

ActiveSupport.on_load(:active_record) do
  Rails::Log::Profiling::QueryLogSubscriber.attach_to :active_record
end
