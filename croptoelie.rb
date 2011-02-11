require 'RMagick'
class CropToelie
  include Magick
  
  attr_accessor :orig
  attr_accessor :step_size
  
  def initialize(image_path)
    @image  = ImageList.new(image_path).last
    @orig   = ImageList.new(image_path).last
    
    # Hardcoded (but overridable) defaults.
    @step_size  = 10

    # Preprocess image.
    @image = @image.quantize
    
    # Prepare some often-used internal variables.
    @rows = @image.rows
    @columns = @image.columns
    
    # @TODO throw a warning if should_crop? is false. 
  end

  # Crops an image to width x height
  # 
  # If you want speed, choose :by_trim. It will use smart_crop_by_trim().
  # If you have a very crowded image, an image with lots of color, or dark and light
  #  spots, the much slower :by_search will give better results. It will use
  #  smart_crop_by_search().  
  def smart_crop(width, height, method = :by_trim)
    sq = square(width, height, method)
    return @orig.crop(sq[:left], sq[:top], width, height, true)
  end

  # Squares an image (with smart_square) and then scales that to width, heigh
  # 
  # If you want speed, choose :by_trim. It will use smart_crop_by_trim().
  # If you have a very crowded image, an image with lots of color, or dark and light
  #  spots, the much slower :by_search will give better results. It will use
  #  smart_crop_by_search().  
  def smart_crop_and_scale(width, height)
    cropped = smart_square    
    return cropped.scale(width, height)
  end
  
  # Squares an image by slicing off the least interesting parts. 
  # Usefull for squaring images such as thumbnails. Usefull before scaling.
  def smart_square
    cropped = @orig  #square images can be returned as-is.
    if @rows != @columns #None-square images must be shaved off.
      if @rows < @columns #landscape
        crop_height = crop_width = @rows
      else # portrait
        crop_height = crop_width = @columns
      end

      sq = square(crop_width, crop_height, :by_trim)
      cropped = @orig.crop(sq[:left], sq[:top], crop_width, crop_height, true)
    end
    
    cropped    
  end
  
  # Finds the most interesting square with size width x height.
  # 
  # See smart_crop documentation for explanation about the method
  # Returns a hash {:left => left, :top => top, :right => right, :bottom => bottom}
  def square(width, height, method = :by_trim)
    if method == :by_trim
      return smart_crop_by_trim(width, height)
    else
      return smart_crop_by_search(width, height)
    end
  end
  
  private
    # Determines if the image should be cropped. 
    # Image should be cropped if original is larger then requested size. 
    # In all other cases, it should not. 
    def should_crop?
      return (@columns > @width) && (@rows < @height)
    end

    # Find Entropy by moving the "to be cropped" area over the image and 
    # recording the entropy of each such square. 
    # The square with the highest entropy is considered the most interesting and
    # cropped out of the original.
    # NOTE: this method is very slow compared to smart_crop_by_trim. 
    def smart_crop_by_search(requested_x, requested_y)
      left, top     = 0, 0
      right, bottom = requested_x, requested_y

      # Create a hash with all entropies
      entropies = {}
              
      # start in left-top corner, walk to right, with steps of 10 px.
      while (bottom <= @rows)
        while (right <= @columns)
          square = {:left => left, :top => top, :right => right, :bottom => bottom}
          entropies[square] = entropy_slice(@image, left, top, right - left, bottom - top)
          
          left += @step_size
          right += @step_size
        end
        # @TODO last item is the one that goes over the edge, or touches the edge.
        left = 0
        right = requested_x
        top += @step_size
        bottom += @step_size
      end

      # Find the square with highest entropy
      best = entropies.max_by{|s| s[1]}[0]
      
      # chop that one out
      best
    end
  
    def smart_crop_by_trim(requested_x, requested_y)
      left, top = 0, 0
      right, bottom = @columns, @rows
      width, height = right, bottom

      # Slice from left and right edges until the correct width is reached.
      while (width > requested_x)
        slice_width = [(width - requested_x), @step_size].min

        left_entropy  = entropy_slice(@image, left, 0, slice_width, bottom)
        right_entropy = entropy_slice(@image, (right - slice_width), 0, slice_width, bottom)

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
        slice_height = [(height - @step_size), @step_size].min
        
        top_entropy    = entropy_slice(@image, 0, top, @columns, slice_height)
        bottom_entropy = entropy_slice(@image, 0, (bottom - slice_height), @columns, slice_height)

        #remove the slice with the least entropy
        if top_entropy < bottom_entropy
          top += slice_height
        else
          bottom -= slice_height
        end
        
        height = (bottom - top)
      end

      square = {:left => left, :top => top, :right => right, :bottom => bottom}
    end

    # Compute the entropy of an image slice.
    def entropy_slice(image_data, x, y, width, height)
      slice = image_data.crop(x, y, width, height)
      entropy = entropy(slice)
    end
    
    # Compute the entropy of an image, defined as -sum(p.*log2(p)).
    def entropy(image_slice)
      hist = image_slice.color_histogram
      hist_size = hist.values.inject{|sum,x| sum ? sum + x : x }.to_f
      
      entropy = 0
      hist.values.each do |h| 
        p = h.to_f / hist_size
        entropy += (p * Math.log2(p)) if p != 0
      end
     
      return entropy * -1
    end
end
