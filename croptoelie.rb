require 'RMagick'
class CropToelie
  include Magick
  
  attr_accessor :image
  attr_accessor :width
  attr_accessor :height
  attr_accessor :gamma
  
  def initialize image_path
    @image  = ImageList.new(image_path).last
    @orig   = ImageList.new(image_path).last
    @width  = 300
    @height = 300
    
    smart_crop(@width, @height)
  end
  
  private
    def smart_crop(requested_x, requested_y)
      x,y = @image.columns, @image.rows
      offset_x, offset_y = 0, 0
      offset_x2, offset_y2 = x, y

      # Slice from left and right edges until the correct width is reached.
      while (x > requested_x) do
        slice_width = [(x - requested_x), 10].min

        left  = @image.crop(0, 0, slice_width, y, true)
        right = @image.crop((x - slice_width), 0, slice_width, y, true)
        #remove the slice with the least entropy
        if entropy(left) < entropy(right)
          offset_x += slice_width
          @image.crop!(slice_width, 0, x - slice_width, y, true)
        else
          offset_x2 -= slice_width
          @image.crop!(0, 0, (x - slice_width), y, true)
        end
        
        x = @image.columns
      end

      # Slice from top and bottom edges until the correct height is reached.
      while (y > requested_y) do
        slice_height = [(y - requested_y), 10].min
        
        top    = @image.crop(0, 0, x, slice_height, true)
        bottom = @image.crop(0, (y - slice_height), x, slice_height, true)
        #remove the slice with the least entropy
        if entropy(top) < entropy(bottom)
          offset_y += slice_height
          @image.crop!(0, slice_height, x, (y - slice_height), true)
        else
          offset_y2 -= slice_height
          @image.crop!(0, 0, x, (y - slice_height), true)
        end
        
        y = @image.rows
      end

      draw_rect(@orig, offset_x, offset_y, offset_x2, offset_y2)
      @orig.display
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

    def draw_rect(img, x1, y1, x2, y2)
      gc = Magick::Draw.new
      gc.stroke('transparent')
      gc.fill('red')
      gc.fill_opacity(0.65)
      gc.rectangle(x1, y1, x2, y2)
      
      # Outline corners
      gc.stroke_width(1)
      gc.stroke('gray50')
      gc.circle(x1,y1, x1+3,y1+3)
      gc.circle(x2,y2, x2+3,y2+3)

      # Annotate
      gc.font_weight(Magick::NormalWeight)
      gc.font_style(Magick::NormalStyle)
      gc.fill('black')
      gc.stroke('transparent')
      gc.text(x1+10,y1+15, "'#{x1},#{y1}'")
      gc.text(x2-50,y2-5, "'#{x2},#{y2}'")
      gc.draw(img)
    end
end
