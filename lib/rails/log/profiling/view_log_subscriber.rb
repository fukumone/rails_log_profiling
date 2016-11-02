require "action_view"
require "action_view/log_subscriber"

module Rails::Log::Profiling

  class ViewLogSubscriber < ActionView::LogSubscriber
    def render_template(event)
      Rails::Log::Profiling.redering_pages[:parent] = [ "#{event.duration.round(1)}", event.payload[:identifier] ]
      children_sort
      view_logger_info
      Rails::Log::Profiling.redering_pages = { parent: "", children: [] }
    end

    def render_partial(event)
      Rails::Log::Profiling.redering_pages[:children] << [ "#{event.duration.round(1)}", event.payload[:identifier] ]
    end

    private
      def children_sort
        unless Rails::Log::Profiling.redering_pages[:children].empty?
          Rails::Log::Profiling.redering_pages[:children].sort! { |a, b| b[0] <=> a[0] }
        end
      end

      def view_logger_info
        log = "\n \033[36mParent: #{Rails::Log::Profiling.redering_pages[:parent][0]}ms \033[0m\n  #{Rails::Log::Profiling.redering_pages[:parent][1]}"
        unless Rails::Log::Profiling.redering_pages[:children].empty?
          partial_time = Rails::Log::Profiling.redering_pages[:children].flatten.inject { |memo, val| memo.to_f + val.to_f }
          log += "\n"
          temp = true

          Rails::Log::Profiling.redering_pages[:children].each do |child|
            if temp
              log += " \033[36mChildren: total time: #{partial_time}ms, partial page count: #{Rails::Log::Profiling.redering_pages[:children].count}\033[0m\n  \033[36m#{child[0]}ms:\033[0m #{child[1]}"
              temp = false
            else
              log += "\n  \033[36m#{child[0]}ms:\033[0m #{child[1]}"
            end
          end
        end
        Rails::Log::Profiling.view_logger.info(log)
      end
  end
end

ActiveSupport.on_load(:action_view) do
  Rails::Log::Profiling::ViewLogSubscriber.attach_to :action_view
end
