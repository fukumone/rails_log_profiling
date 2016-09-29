module Rails
  module Log
    module Profiling
      class Execute
        def self.run
          # カレントパス
          current_path = `pwd`.chomp
          file_content = File.read("#{current_path}/log/development.log")

          file_content.scan(/Started GET[\s\S]*?Completed.*/).each do |val|
            arr = []
            scan_reg = ""
            # gem 'activerecord-cause'を入れている場合
            if val.match(/.*Load.\(.*ms\)[\s\S]*?Load \(ActiveRecord::Cause\)[\s\S]*?.rb.*/)
              scan_reg = val.scan(/.*Load.\(.*ms\)[\s\S]*?Load \(ActiveRecord::Cause\)[\s\S]*?.rb.*/)
            else
              scan_reg = val.scan(/.*Load.\(.*ms\)[\s\S].*/)
            end

            next if scan_reg.empty?

            val2 = "#{val.slice(/\S*Controller*\S*/)}のクエリを#{scan_reg.count}件検知"
            print "\033[34m#{val2}\033[0m" # colorで出力

            # 取得したクエリの時間をarrに格納
            scan_reg.each do |val|
              # gem 'activerecord-cause'を入れている場合
              if val.match(/.*Load \(ActiveRecord::Cause\).*caused by/)
                val.gsub!(/.*Load \(ActiveRecord::Cause\).*caused by/, "  検知箇所:")
              end

              temp = val.slice(/\(\d?.*ms\)/)[1..-4]

              arr << [ temp.to_f, val ]
            end

            arr.sort! { |a, b| b[0] <=> a[0] }

            arr.each.with_index(1) do |val, ind|
              puts
              puts " \033[36m #{ind}:" + val[1] # colorで出力
            end
            puts
          end
        end
      end
    end
  end
end
