require "active_record"
require "active_record/log_subscriber"

module Rails::Log::Profiling
  class QueryLogSubscriber < ActiveRecord::LogSubscriber
    def sql(event)
      locations = get_locations
      return if locations.empty?
      payload = event.payload

      return if IGNORE_PAYLOAD_NAMES.include?(payload[:name])

      if ActiveRecord.version >= Gem::Version.new("5.0.0.beta")
        ar_ver_5(event, locations)
      else
        ar_ver_4(event, locations)
      end
    end

    private
      def ar_ver_5(event, locations)
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
          Rails::Log::Profiling.sqls << [ "#{event.duration.round(1)}".to_f, "  #{name}  #{sql}#{binds}\n#{locations}"]
        end
      end

      def ar_ver_4(event, locations)
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
          Rails::Log::Profiling.sqls << [ "#{event.duration.round(1)}".to_f, "  #{name}  #{sql}#{binds}\n #{locations}" ]
        end
      end

      # クエリの実行箇所を表示
      def get_locations
        ans = ""
        caller.each do |val|
          if val.match(Rails::Log::Profiling.current_path)
            ans += " \033[36mIdentify Query Location:\033[0m\n"
            ans += " " + val + "\n"
            # メソッドの呼び出し状況を検知するのは一回で止める
            # なぜか？ => 再帰的に探索するため、探知する量が多くなってしまう場合があるため
            # 別途オプションを設けて最後までメソッドの呼び出し箇所をトレースするかは検討中
            break
          end
        end
        ans
      end
  end
end

ActiveSupport.on_load(:active_record) do
  Rails::Log::Profiling::QueryLogSubscriber.attach_to :active_record
end
