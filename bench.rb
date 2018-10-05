require 'benchmark'

Benchmark.bm(20) do |x|
  x.report('one') do
    files = Dir.glob('test*.rb')
    files.each do |f|
      system("ruby interp.rb #{f} > /dev/null", exception: true)
    end
  end
  x.report('two') do
    files = Dir.glob('test*.rb')
    files.each do |f|
      system("ruby interp.rb interp.rb #{f} > /dev/null", exception: true)
    end
  end
  x.report('three') do
    files = Dir.glob('test*.rb')
    files.each do |f|
      system("ruby interp.rb interp.rb interp.rb #{f} > /dev/null", exception: true)
    end
  end
  x.report('four') do
    files = Dir.glob('test*.rb')
    files.each do |f|
      system("ruby interp.rb interp.rb interp.rb interp.rb #{f} > /dev/null", exception: true)
    end
  end
end
