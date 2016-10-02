module Rails
  module Log
    module Profiling
      class Logger
        def self.run
          require 'fileutils'
          root_path = Rails.root.to_s
          FileUtils.mkdir_p(root_path + '/log')
          File.open("#{root_path}/log/rails_profiling.log", 'a+')
        end
      end
    end
  end
end
