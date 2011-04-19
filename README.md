# croptoelie

Content aware cropping.

Crops images based on entropy: leaving the most interesting part intact.

Don't expect this to be a replacement for human cropping, it is an algorythm and not an extremely smart one at that :).

Best results achieved in combination with scaling: the cropping is then only used to square the image, cutting off the least interesting part. 
The trimming simply chops off te edge that is least interesting, and continues doing so, untill it reached the requested size.

## Usage

Use it in [carrierwave][1], in a custom `manipulate!` block. For example, carrierwave in a Rails project:

File *uploaders/attachement_uploader.rb*: 

    def smart_crop_and_scale(width, height)
      manipulate! do |img|
        img = CropToelie.new(img)
        img = img.smart_crop_and_scale(width, height)
        img = yield(img) if block_given?
        img
      end
    end

    # Create different versions of your uploaded files:
    version :thumb do
      process :smart_crop_and_scale => [80, 80]
    end

## Contributing to croptoelie

* This is one of my first more complex Ruby gems. So any help in general improvement is welcome. If you read the code and thing "OMG, what was he thinking, the answer is probably 'I wasn't'". Feel free to tell me so.
* RMagick is not the cleanest and leanest of all image-manipulation libraries in Ruby, but it was the only one where I found enough documentation and that had the features I needed (such as histograms). If you have better ideas, feel free to tell me them.
* I only use this gem with [carrierwave][1], so other implementations are probably not well done. If you want to use it in any other project, please tell me what I should change to make your life easier. 
* The integration in carrierwave should be simpler. I would love to be able to say `process :smart_crop_and_scale` instead of having to use the smartcropper as class in a custom carrierwave `manipulate!` block. My knowledge of Ruby, Carrierwave and how to get this integration done properly is limited, if you have a patch, or a suggestion, that would be great!
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Changelog
2011-04-19: Replace crop with crop! avoids copying large chunks of images around.
2011-04-18: Limit to N steps, instead of step_size.
2011-04-16: Introduce tests and a profiler script, to profile performance.

## Todo
Improved algorythm: first @image.scale by F, investigate the entropy on that, most-interesting square by factor F is to-be-cropped area.

## Copyright

Copyright (c) 2011 Bèr Kessels. See LICENSE.txt for
further details.

[1]: https://github.com/jnicklas/carrierwave

