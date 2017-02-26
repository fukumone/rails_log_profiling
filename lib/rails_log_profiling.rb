# The MIT License (MIT)

# Copyright (c) 2016 fukumone

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require "rails/log/profiling/version"

module Rails
  module Log
    module Profiling
      include ActiveSupport::Configurable

      # クエリのプロファイルリングを設定
      config_accessor :query_profiling_enable, instance_accessor: false do
        false
      end

      # Viewのプロファイリングを設定
      config_accessor :view_profiling_enable, instance_accessor: false do
        false
      end

      config_accessor :query_logger, instance_accessor: false  do
        ""
      end

      config_accessor :view_logger, instance_accessor: false  do
        ""
      end

      config_accessor :sqls, instance_accessor: false  do
        []
      end

      config_accessor :total_sql_time, instance_accessor: false do
        0
      end

      config_accessor :sort_order, instance_accessor: false do
        "desc"
      end

      config_accessor :current_path, instance_accessor: false do
        ""
      end

      config_accessor :rendering_pages, instance_accessor: false do
        { parent: "", children: {} }
      end

      # メソッドの呼び出し状況を制御する
      # 再帰的に探索するため、探知する量が多くなってしまう場合があるため、デフォルトは一回で止める
      config_accessor :continue_to_query_caller, instance_accessor: false do
        false
      end
    end
  end
end

if defined?(Rails)
  class Railtie < ::Rails::Railtie
    initializer "rails_log_profiling.configure_rails_initialization" do
      if Rails::Log::Profiling.query_profiling_enable
        require 'rails/log/profiling/query_profiling_logger'
        require 'rails/log/profiling/query_profiling'
        require 'rails/log/profiling/query_log_subscriber'
        require 'rails/log/profiling/action_controller'
      end

      if Rails::Log::Profiling.view_profiling_enable
        require 'rails/log/profiling/view_profilng_logger'
        require 'rails/log/profiling/view_log_subscriber'
      end
    end
  end
end
