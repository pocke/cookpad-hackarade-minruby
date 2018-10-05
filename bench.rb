require 'benchmark'

files = Dir.glob('test*.rb')

Benchmark.bm(20) do |x|
  x.report('one') do
    files.each do |f|
      system("ruby interp.rb #{f} > /dev/null", exception: true)
    end
  end
  x.report('two') do
    files.each do |f|
      system("ruby interp.rb interp.rb #{f} > /dev/null", exception: true)
    end
  end
  x.report('three') do
    files.each do |f|
      system("ruby interp.rb interp.rb interp.rb #{f} > /dev/null", exception: true)
    end
  end
end
