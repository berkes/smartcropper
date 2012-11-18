require 'helper'

class TestCroptoelie < Test::Unit::TestCase
  def setup
    @filename = File.join(File.expand_path(File.dirname(__FILE__)), "fixtures", "entropyish.png")
    @image    = Magick::ImageList.new(@filename).last
  end
  should "initialize a croptoelie image from an ImageList item" do
    img = CropToelie.new(@image)
    assert_equal(img.class, CropToelie)
  end
  should "create a croptoelie from an imagefile" do
    img = CropToelie.from_file(@filename)
    assert_equal(img.class, CropToelie)
  end

  should "fail on creating a croptoelie image from a textfile" do
    assert_raise Magick::ImageMagickError, NoMethodError do
       CropToelie.new(File.join(File.expand_path(File.dirname(__FILE__)), "fixtures","entropyish.txt"))
    end
  end

  should "crop to 100x100 without scaling with smart_crop" do
    img = CropToelie.new(@image)
    img = img.smart_crop(100, 100)
    size = [img.rows, img.columns]
    assert_equal(size, [100, 100])
  end

  should "crop to 100x100 with scaling with smart_crop_and_scale" do
    img = CropToelie.new(@image)
    img = img.smart_crop_and_scale(100, 100)
    size = [img.rows, img.columns]
    assert_equal(size, [100, 100])
  end

  should "square image without scaling" do
    img = CropToelie.new(@image)
    img = img.smart_square
    assert_equal(img.rows, img.columns)
  end
end
