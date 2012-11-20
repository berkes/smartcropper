require 'ruby-prof'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'smartcropper'

tests = {
  :smart_crop_by_trim => {:method => :smart_crop, :params => [100, 100]}, 
#  :smart_crop_by_search => {:method => :smart_crop, :params => [100, 100, :by_search]},
  :smart_crop_and_scale => {:method => :smart_crop_and_scale, :params => [100, 100]},
  :smart_square => {:method => :smart_square, :params => []}
}
#result = RubyProf.profile do
  tests.each do |id, test|
    filename = File.join(File.expand_path(File.dirname(__FILE__)), "../doc/tyto.jpg")
    
    2.times do |i|
#      result = RubyProf.profile do
        img = SmartCropper.from_file(filename)
        img.send(test[:method], *test[:params])
        img = nil
#      end

  #    # Print a flat profile to text
  #    puts "Run #{i}:\t #{id} ------------------------"
  #    #file = File.new("./#{id}-#{i}.txt", "w")
  #    printer = RubyProf::FlatPrinter.new(result)
  #    printer.print(STDOUT, {:min_percent => 10})
  #    print = nil
    end
  end
#end
#    # Print a flat profile to text
#    puts "Run #{i}:\t #{id} ------------------------"
#    #file = File.new("./#{id}-#{i}.txt", "w")
#    printer = RubyProf::FlatPrinter.new(result)
#    printer.print(STDOUT, {:min_percent => 10})
#    print = nil
