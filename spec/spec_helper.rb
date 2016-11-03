File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'rspec'
require 'active_record/railtie'
require 'rails/log/profiling/query_profiling'
require 'rails/log/profiling/query_log_subscriber'
require 'rails/log/profiling/action_controller'
require 'rails/log/profiling/view_log_subscriber'
require 'rails_log_profiling'

RSpec.configure do |config|
  config.before(:all) do
    require 'fileutils'
    current_path = `pwd`.chomp
    @profiling_logger_file = File.open(current_path + '/rails_view_log_profiling.log', 'a+')

    Rails::Log::Profiling.view_logger = ActiveSupport::Logger.new @profiling_logger_file
    @profiling_logger_file.binmode
    @profiling_logger_file.sync = true

    @view_logger_file = File.open(current_path + '/rails_log_query_profiling.log', 'a+')
    Rails::Log::Profiling.query_logger = ActiveSupport::Logger.new @view_logger_file
    @view_logger_file.binmode
    @view_logger_file.sync = true
  end
end

RSpec.configure do |config|
  config.after(:all) do
    File.delete(@profiling_logger_file)
    File.delete(@view_logger_file)
  end
end
