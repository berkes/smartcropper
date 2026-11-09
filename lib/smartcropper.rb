require 'rmagick'
class SmartCropper
  include Magick

  attr_accessor :image
  attr_accessor :steps

  # Create a new SmartCropper object from a ImageList single image object.
  #  If you want to provide a file by its path use SmartCropper.from_file('/path/to/image.png').
  def initialize(image)
    @image = image

    # Hardcoded (but overridable) defaults.
    @steps  = 10

    # Preprocess image.
    @quantized_image = @image.quantize

    # Prepare some often-used internal variables.
    @rows = @image.rows
    @columns = @image.columns
  end

  # Open create a smartcropper from a file on disk.
  def self.from_file(image_path)
    image = ImageList.new(image_path).last
    return SmartCropper.new(image)
  end

  # Crops an image to width x height
  def smart_crop(width, height)
    sq = square(width, height)
    return @image.crop!(sq[:left], sq[:top], width, height, true)
  end

  # Squares an image (with smart_square) and then scales that to width, heigh
  def smart_crop_and_scale(width, height)
    smart_square
    return @image.scale!(width, height)
  end

  # Squares an image by slicing off the least interesting parts.
  # Usefull for squaring images such as thumbnails. Usefull before scaling.
  def smart_square
    if @rows != @columns #None-square images must be shaved off.
      if @rows < @columns #landscape
        crop_height = crop_width = @rows
      else # portrait
        crop_height = crop_width = @columns
      end

      sq = square(crop_width, crop_height)
      @image.crop!(sq[:left], sq[:top], crop_width, crop_height, true)
    end

    @image
  end

  # Finds the most interesting square with size width x height.
  #
  # Returns a hash {:left => left, :top => top, :right => right, :bottom => bottom}
  def square(width, height)
    return smart_crop_by_trim(width, height)
  end

  private
    # Determines if the image should be cropped.
    # Image should be cropped if original is larger then requested size.
    # In all other cases, it should not.
    def should_crop?
      return (@columns > @width) && (@rows < @height)
    end

    def smart_crop_by_trim(requested_x, requested_y)
      left, top = 0, 0
      right, bottom = @columns, @rows
      width, height = right, bottom
      step_size = step_size(requested_x, requested_y)

      # Avoid attempts to slice less then one pixel.
      if step_size > 0
        # Slice from left and right edges until the correct width is reached.
        while (width > requested_x)
          slice_width = [(width - requested_x), step_size].min

          left_entropy  = entropy_slice(@quantized_image, left, 0, slice_width, bottom)
          right_entropy = entropy_slice(@quantized_image, (right - slice_width), 0, slice_width, bottom)

          #remove the slice with the least entropy
          if left_entropy < right_entropy
            left += slice_width
          else
            right -= slice_width
          end

          width = (right - left)
        end

        # Slice from top and bottom edges until the correct height is reached.
        while (height > requested_y)
          slice_height = [(height - step_size), step_size].min

          top_entropy    = entropy_slice(@quantized_image, 0, top, @columns, slice_height)
          bottom_entropy = entropy_slice(@quantized_image, 0, (bottom - slice_height), @columns, slice_height)

          #remove the slice with the least entropy
          if top_entropy < bottom_entropy
            top += slice_height
          else
            bottom -= slice_height
          end

          break if slice_height == step_size
          height = (bottom - top)
        end
      end

      square = {:left => left, :top => top, :right => right, :bottom => bottom}
    end

    # Compute the entropy of an image slice.
    def entropy_slice(image_data, x, y, width, height)
      slice = image_data.crop(x, y, width, height)
      entropy = entropy(slice)
    end

    # Compute the entropy of an image, defined as -sum(p.*log2(p)).
    #  Note: instead of log2, only available in ruby > 1.9, we use
    #  log(p)/log(2). which has the same effect.
    def entropy(image_slice)
      hist = image_slice.color_histogram
      hist_size = hist.values.inject{|sum,x| sum ? sum + x : x }.to_f

      entropy = 0
      hist.values.each do |h|
        p = h.to_f / hist_size
        entropy += (p * (Math.log(p)/Math.log(2))) if p != 0
      end
      return entropy * -1
    end

    def step_size(requested_x, requested_y)
      ((([@rows - requested_x, @columns - requested_y].max)/2)/@steps).to_i
    end
end
