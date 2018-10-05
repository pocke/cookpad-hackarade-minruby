require 'open3'
require 'parallel'
require 'optparse'
require 'pp'

opt = OptionParser.new
params = {}
opt.on('-s N') # self hosting
opt.on('-f file')
opt.parse(ARGV, into: params)

def sh!(cmd)
  out, err, status = Open3.capture3(cmd)
  if status.success?
    return out
  end

  raise <<~MSG
    #{err}
    #{out}
  MSG
end

m = Mutex.new

files = params[:f] ? Array(params[:f]) : Dir.glob('test*.rb').sort

Parallel.map(files, in_threads: files.count) do |f|
  min = 
    if params[:s]
      sh! "ruby #{"interp.rb " * params[:s].to_i} #{f}"
    else
      sh! "ruby interp.rb #{f}"
    end
  org = sh! "ruby -r./fizzbuzz.rb #{f}"

  min_f = "/tmp/min-#{f}"
  org_f = "/tmp/org-#{f}"
  File.write(min_f, min)
  File.write(org_f, org)
  sh!("diff #{min_f} #{org_f}")
  nil
rescue => ex
  m.synchronize {
    <<~MSG
      failed: #{f}
      #{ex.pretty_inspect}
    MSG
  }
end.compact.each do |msg|
  puts '-' * 100
  puts msg
end
