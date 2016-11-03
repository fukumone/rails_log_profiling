module Rails
  module Log
    module Profiling
      class ViewProfilingLogger
        def self.run
          require 'fileutils'
          @root_path = Rails.root.to_s
          FileUtils.mkdir_p(@root_path + '/log')
          rails_log_view_profiling_setting
        end

        private
          def self.rails_log_view_profiling_setting
            file = @root_path + '/log/rails_log_view_profiling.log'
            if File.exist?(file)
              f = File.open(file, 'a')
            else
              f = File.open("#{@root_path}/log/rails_log_view_profiling.log", 'a+')
            end

            f.binmode
            f.sync = true
            Rails::Log::Profiling.view_logger = ActiveSupport::Logger.new f
          end
      end
    end
  end
end

# ファイル読み込みが発生した時点で実行
Rails::Log::Profiling::ViewProfilingLogger.run
