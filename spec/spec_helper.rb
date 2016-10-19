require 'rspec'
require "active_record/railtie"
require "action_controller/railtie"
require "rails_log_profiling"

File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
UNIT = File.join(File.dirname(__FILE__), "unit")
$LOAD_PATH.unshift(UNIT)
