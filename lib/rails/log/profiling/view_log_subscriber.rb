require "action_view"
require "action_view/log_subscriber"

module Rails::Log::Profiling
  class ViewLogSubscriber < ActionView::LogSubscriber
    def render_template(event)
      Rails::Log::Profiling.rendering_pages[:parent] = [ "#{event.duration.round(1)}", event.payload[:identifier] ]
      children_sort
      view_logger_info
      # グローバル変数のため値をクリアにする
      Rails::Log::Profiling.rendering_pages = { parent: "", children: {} }
    end

    def render_partial(event)
      identifier = event.payload[:identifier]
      if Rails::Log::Profiling.rendering_pages[:children].has_key?(identifier)
        Rails::Log::Profiling.rendering_pages[:children][identifier][:partial_count] += 1
      else
        Rails::Log::Profiling.rendering_pages[:children][identifier] = { rendering_time: event.duration.round(1), partial_count: 1 }
      end
    end

    private
      def children_sort
        unless Rails::Log::Profiling.rendering_pages[:children].empty?
          sort_array = Rails::Log::Profiling.rendering_pages[:children].to_a.sort! { |a, b| b[1][:rendering_time] <=> a[1][:rendering_time] }
          # ソートした値を入れ替えるため一旦クリアにする
          Rails::Log::Profiling.rendering_pages[:children].clear
          Rails::Log::Profiling.rendering_pages[:children] = sort_array.to_h
        end
      end

      def view_logger_info
        log = "\n \033[36mParent: #{Rails::Log::Profiling.rendering_pages[:parent][0]}ms \033[0m\n  #{Rails::Log::Profiling.rendering_pages[:parent][1]}"
        children = Rails::Log::Profiling.rendering_pages[:children]

        unless children.empty?
          log += "\n"
          temp= true
          partial_total_time = 0
          rendering_pages_count = 0
          children.each do |val|
            partial_total_time += val[1][:rendering_time]
            rendering_pages_count += val[1][:partial_count]
          end

          children.each do |child|
            if temp
              if child[1][:partial_count] > 1
                log += " \033[36mChildren: total time: #{partial_total_time}ms, "
                log += "partial page count: #{children.count}, "
                log += "total rendering page count: #{rendering_pages_count}\033[0m\n  "
                log += "\033[36m#{child[1][:rendering_time]}ms:\033[0m #{child[0]}\n"
                log += "    \033[36mrendering page count: #{child[1][:partial_count]}\033[0m"
              else
                log += " \033[36mChildren: total time: #{partial_total_time}ms, "
                log += "partial page count: #{children.count}, "
                log += "total rendering page count: #{rendering_pages_count}\033[0m\n  "
                log += "\033[36m#{child[1][:rendering_time]}ms:\033[0m #{child[0]}"
              end
              temp = false
            else
              if child[1][:partial_count] > 1
                log += "\n  \033[36m#{child[1][:rendering_time]}ms:\033[0m #{child[0]}\n"
                log += "    \033[36mrendering page count: #{child[1][:partial_count]}\033[0m"
              else
                log += "\n  \033[36m#{child[1][:rendering_time]}ms:\033[0m #{child[0]}"
              end
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
