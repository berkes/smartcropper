= croptoelie

Content aware cropping.

Crops images based on entropy: leaving the most interesting part intact.

Don't expect this to be a replacement for human cropping, it is an algorythm and not an extremely smart one at that :).

Best results achieved in combination with scaling: the cropping is then only used to square the image, cutting off the least interesting part. It offers two methods, scanning and trimming: with scanning the whole image is placed in an array then evaluated: very slow and memory-gobbling. 

The trimming simply chops off te edge that is least interesting, and continues doing so, untill it reached the requested size.

== Contributing to croptoelie
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2011 Bèr Kessels. See LICENSE.txt for
further details.

