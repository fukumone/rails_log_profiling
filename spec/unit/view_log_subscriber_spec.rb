require "spec_helper"

describe Rails::Log::Profiling::ViewLogSubscriber do
  before do
    Rails::Log::Profiling.rendering_pages = { :parent=>
        ["57.8", "app/views/posts/index.html.erb"],
        :children=>{
          "app/views/articles/_show.html.erb"=>{:rendering_time=>1.9, :partial_count=>10},
          "app/views/articles/_show_2.html.erb"=>{:rendering_time=>4.7, :partial_count=>1},
          "app/views/articles/_show_3.html.erb"=>{:rendering_time=>0.7, :partial_count=>1}}}
  end

  it '.children_sort' do
    view_log_subscriber = Rails::Log::Profiling::ViewLogSubscriber.new

    val = {"app/views/articles/_show_2.html.erb"=>{:rendering_time=>4.7, :partial_count=>1},
           "app/views/articles/_show.html.erb"=>{:rendering_time=>1.9, :partial_count=>10},
           "app/views/articles/_show_3.html.erb"=>{:rendering_time=>0.7, :partial_count=>1}}
    expect(val).to eq(view_log_subscriber.send(:children_sort))
  end
end
