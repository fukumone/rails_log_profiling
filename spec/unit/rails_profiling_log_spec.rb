require "spec_helper"

describe Rails::Log::Profiling do
  it "has a version number" do
    expect(Rails::Log::Profiling::VERSION).to eq("0.1.0.beta1")
  end

  describe "Rails::Log::Profiling::QueryProfiling" do
    before do
      require 'fileutils'
      current_path = `pwd`.chomp
      @log_file = current_path + '/rails_profiling.log'
      if File.exist?(@log_file)
        @file = File.open(@log_file, 'a')
      else
        @file = File.open(@log_file, 'a+')
      end

      Rails::Log::Profiling.logger = ActiveSupport::Logger.new @file
      @file.binmode
      @file.sync = true

      [10, 100, 500, 3].each do |val|
        Rails::Log::Profiling.sqls << [ val, "test" ]
      end
    end

    after do
      File.delete(@log_file)
      Rails::Log::Profiling.sqls.clear
    end

    it '.execute' do
      Rails::Log::Profiling::QueryProfiling.execute
      expect(Rails::Log::Profiling.sqls).to eq([])
    end

    it '.query_sort(クエリをソートする)' do
      expect(Rails::Log::Profiling::QueryProfiling.query_sort).to eq(
        [[500, "test"], [100, "test"], [10, "test"], [3, "test"]])
    end
  end
end
