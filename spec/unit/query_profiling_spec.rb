require "spec_helper"

describe Rails::Log::Profiling::QueryProfiling do
  before do
    [10, 100, 500, 3].each do |val|
      Rails::Log::Profiling.sqls << [ val, "test" ]
    end
  end

  after do
    Rails::Log::Profiling.sqls.clear
  end

  it '.execute' do
    Rails::Log::Profiling::QueryProfiling.execute
    expect(Rails::Log::Profiling.sqls).to eq([])
  end

  describe '.query_sort' do

    it 'desc順に並べる'do
      expect(Rails::Log::Profiling::QueryProfiling.query_sort).to eq(
        [[500, "test"], [100, "test"], [10, "test"], [3, "test"]])
    end

    it 'asc順に並べる' do
      Rails::Log::Profiling.sort_order = "asc"
      expect(Rails::Log::Profiling::QueryProfiling.query_sort).to eq(
        [[3, "test"], [10, "test"], [100, "test"], [500, "test"]])
    end
  end
end
