module Rails
  module Log
    module Profiling
      class Logger
        def self.run
          require 'fileutils'
          root_path = Rails.root.to_s
          FileUtils.mkdir_p(root_path + '/log')
          log_file = root_path + '/log/rails_profiling.log'
          if File.exist?(log_file)
            f = File.open(log_file, 'a')
          else
            f = File.open("#{root_path}/log/rails_profiling.log", 'a+')
          end
          f.binmode
          f.sync = true
          Rails::Log::Profiling.logger = ActiveSupport::Logger.new f
          Rails::Log::Profiling.logger.formatter = ::Logger::Formatter.new
          Rails::Log::Profiling.logger = ActiveSupport::TaggedLogging.new(Rails::Log::Profiling.logger)
        end
      end
    end
  end
end
