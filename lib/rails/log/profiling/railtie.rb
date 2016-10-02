module Rails
  module Log
    module Profiling
      class Railtie < ::Rails::Railtie
        initializer "rails_log_profiling" do
          ::Rails::Log::Profiling::Logger.run
        end
      end
    end
  end
end
