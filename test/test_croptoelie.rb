require 'helper'

class TestCroptoelie < Test::Unit::TestCase
  def setup
    @filename = File.join(File.expand_path(File.dirname(__FILE__)), "fixtures", "entropyish.png")
    @image    = Magick::ImageList.new(@filename).last

    @twenty_twenty = Magick::ImageList.new(
      File.join(File.expand_path(File.dirname(__FILE__)), "fixtures", "20x20.png")
    ).last
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

  should "not crop small images" do
    img = CropToelie.new(@twenty_twenty)
    img = img.smart_crop(100, 100)
    size = [img.rows, img.columns]
    assert_equal([20, 20], size)
  end

  should "still crop a slice of one pixel" do
    img = CropToelie.new(@twenty_twenty)
    img = img.smart_crop(19, 19)
    size = [img.rows, img.columns]
    assert_equal([19, 19], size)
  end

  ###########################################################################
  #                   Images reported to fail by issue #5                   #
  ###########################################################################
  [:smart_crop, :smart_crop_and_scale, :smart_square].each do |method|
    full_path = File.join File.dirname(__FILE__), "fixtures", "errors"
    Dir.open(full_path).select{|f| !File.directory?(f)}.each do |file|

      should "'not fail on reported-as-broken image '#{file}' with '#{method}'" do
          realpath = File.realpath(File.join full_path, file)

          img = CropToelie.new(Magick::ImageList.new(realpath).last)
          img = img.smart_crop(200, 200)
          size = [img.rows, img.columns]
          assert_equal(size, [200, 200])
      end
    end
  end
end
