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
    @width  = 800
    @height = 800

#    @image = @image.quantize
     @image = @image.posterize(5)
#    @image = @image.edge(1) #aggressive egdes
#    @image.display
#    @image = @image.modulate(100,0,100) # grayscale
#    @image.display
#    @image = @image.black_threshold(15) # higher contrast
#    @image.display

    smart_crop(@width, @height)
  end
  
  private
    def smart_crop(requested_x, requested_y)
      left, top = 0, 0
      right, bottom = @image.columns, @image.rows
      width, height = right, bottom

      # Slice from left and right edges until the correct width is reached.
      while (width > requested_x) do
        slice_width = [(width - requested_x), 30].min

        left_entropy  = entropy_slice(@image, left, 0, slice_width, bottom)
        right_entropy = entropy_slice(@image, (right - slice_width), 0, slice_width, bottom)

        #remove the slice with the least entropy
        if left_entropy < right_entropy
          #draw_entropy(@orig, left, 0, left + slice_width, bottom, left_entropy)
          left += slice_width
        else
          #draw_entropy(@orig, (right - slice_width), 0, right + slice_width, bottom, right_entropy)
          right -= slice_width
        end
        
        width = (right - left)
      end

      # Slice from top and bottom edges until the correct height is reached.
      while (height > requested_y) do
        slice_height = [(height - requested_y), 30].min
        
        top_entropy    = entropy_slice(@image, 0, top, @image.columns, slice_height)
        bottom_entropy = entropy_slice(@image, 0, (bottom - slice_height), @image.columns, slice_height)

        #remove the slice with the least entropy
        if top_entropy < bottom_entropy
          draw_entropy(@orig, 0, top, @image.columns, top + slice_height, top_entropy)
          top += slice_height
        else
          draw_entropy(@orig, 0, bottom - slice_height, @image.columns, bottom, bottom_entropy)
          bottom -= slice_height
        end
        
        height = (bottom - top)
      end

      draw_rect(@image, left, top, right, bottom)
      draw_rect(@orig, left, top, right, bottom)
      @image.display
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

    def draw_entropy(img, x1, y1, x2, y2, entropy) 
      gc = Magick::Draw.new
      gc.stroke('transparent')
      gc.fill('red')
      
      opacity = (entropy/ 10.0)
      gc.fill_opacity(opacity)
      gc.rectangle(x1, y1, x2, y2)
      
      gc.font_weight(Magick::NormalWeight)
      gc.font_style(Magick::NormalStyle)
      gc.fill('black')
      gc.stroke('transparent')
      gc.text(x1+10,y1+15, "'#{entropy}'")
      gc.draw(img)
    end
    
    def draw_rect(img, x1, y1, x2, y2)
      gc = Magick::Draw.new
      gc.stroke('transparent')
      gc.fill('white')
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
