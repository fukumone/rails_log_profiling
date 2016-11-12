require "spec_helper"

describe Rails::Log::Profiling do
  it "has a version number" do
    expect(Rails::Log::Profiling::VERSION).to eq("0.1.0")
  end
end
