require 'rspec'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'rails/log/profiling/logger'
require 'rails/log/profiling/query_profiling'
require 'rails/log/profiling/query_log_subscriber'
require 'rails/log/profiling/action_controller'
require 'rails_log_profiling'

File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
UNIT = File.join(File.dirname(__FILE__), "unit")
$LOAD_PATH.unshift(UNIT)

RSpec.configure do |config|
  config.before(:all) do
    Rails::Log::Profiling.enable = true
  end
end
