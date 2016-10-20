require "spec_helper"

describe Rails::Log::Profiling do
  it "has a version number" do
    expect(Rails::Log::Profiling::VERSION).to eq("1.0.0.beta1")
  end
end
