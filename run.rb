require 'open3'
require 'parallel'
require 'optparse'

opt = OptionParser.new
params = {}
opt.on('-s') # self hosting
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

Parallel.each(files, in_threads: files.count) do |f|
  min = 
    if params[:s]
      sh! "ruby interp.rb interp.rb #{f}"
    else
      sh! "ruby interp.rb #{f}"
    end
  org = sh! "ruby -r./fizzbuzz.rb #{f}"

  min_f = "/tmp/min-#{f}"
  org_f = "/tmp/org-#{f}"
  File.write(min_f, min)
  File.write(org_f, org)
  sh!("diff #{min_f} #{org_f}")
rescue => ex
  m.synchronize {
    puts "failed: #{f}"
    pp ex
  }
end
