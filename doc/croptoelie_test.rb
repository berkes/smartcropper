require 'RMagick'
include Magick
require './croptoelie.rb'

samples = ImageList.new('ts.jpg', 'sea.jpg', 'hosni.jpg', 'tahrir.jpg', 'sikh.jpg')

canvas = Image.new(2012, 1012) { self.background_color = "white" }
x = y = 6

samples.each do |img|
  scaled = img.resize_to_fit(400, 400)
  
  puts "...processing #{img.filename}"
  canvas.composite!(scaled, x, y, CopyCompositeOp)
  
  gc = Magick::Draw.new
  gc.font_weight(Magick::NormalWeight)
  gc.font_style(Magick::NormalStyle)
  gc.fill('black')
  gc.stroke('transparent')
  gc.text(x+10,y+15, "'#{img.filename}'")
  gc.draw(canvas)
  
  y += (400 + 15 + 6)
  ct = CropToelie.new(img.filename)
  size = img.columns/3
  cropped = ct.smart_crop(size, size)
  cropped = cropped.resize_to_fit(150, 150)
  canvas.composite!(cropped, x, y, CopyCompositeOp)
  
  gc = Magick::Draw.new
  gc.font_weight(Magick::NormalWeight)
  gc.font_style(Magick::NormalStyle)
  gc.fill('black')
  gc.stroke('transparent')
  gc.text(x, y - 6, "'smart_crop(#{size}, #{size})'")
  gc.draw(canvas)

  y += (150 + 15 + 6)
  ct.step_size = 30
  cropped = ct.smart_crop(size, size, :by_search)
  cropped = cropped.resize_to_fit(150, 150)
  canvas.composite!(cropped, x, y, CopyCompositeOp)
  gc = Magick::Draw.new
  gc.font_weight(Magick::NormalWeight)
  gc.font_style(Magick::NormalStyle)
  gc.fill('black')
  gc.stroke('transparent')
  gc.text(x, y - 6, "'smart_crop(#{size}, #{size}, :by_search)'")
  gc.draw(canvas)

  y += (150 + 15 + 6)  
  ct.step_size = 10
  cropped = ct.smart_crop_and_scale(150, 150)
  canvas.composite!(cropped, x, y, CopyCompositeOp)
  gc = Magick::Draw.new
  gc.font_weight(Magick::NormalWeight)
  gc.font_style(Magick::NormalStyle)
  gc.fill('black')
  gc.stroke('transparent')
  gc.text(x, y - 6, "'smart_crop_and_scale(150, 150)'")
  gc.draw(canvas)

  x += 402
  y = 6
end

canvas.write('composite.png')
canvas.display
