module Rails::Log::Profiling
  class ViewProfiling
    def self.run
      current_path = `pwd`.chomp
      file_content = File.read("#{current_path}/log/development.log")

      file_content.scan(/Started GET[\s\S]*?Completed.*/).each do |val|
        controller_name = "#{val.slice(/\S*Controller*\S*/)}"
        scan_reg = val.scan(/Rendered .*ms.*/)

        print "\033[34m#{controller_name}\033[0m" # colorで出力

        scan_reg.each.with_index(1) do |val, ind|
          puts
          puts " \033[36m #{ind}:" + val # colorで出力
        end
        puts
      end
    end
  end
end
