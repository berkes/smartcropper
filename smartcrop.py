import Image, ImageFile, math
#from ImageEnhance import Color
#import os, sys


def image_entropy(im):
    """From Reddit: Calculate the entropy of an image"""
    hist = im.histogram()
    hist_size = sum(hist)
    hist = [float(h) / hist_size for h in hist]
    entropy = -sum([p * math.log(p, 2) for p in hist if p != 0])
    return entropy

def square_image(im, requested_size, opts):
    """From Reddit: if the image is taller than it is wide, square it off. determine
    which pieces to cut off based on the entropy pieces.

    This version is improved as it squares images that are wider than it is tall.
    """
    if 'autosquare' in opts:
        x,y = im.size

        # if the image is taller than it is wide:
        if y > x:
            while y > x:
                #slice 10px at a time until square
                slice_height = min(y - x, 10)

                bottom = im.crop((0, y - slice_height, x, y))
                top = im.crop((0, 0, x, slice_height))

                #remove the slice with the least entropy
                if image_entropy(bottom) < image_entropy(top):
                    im = im.crop((0, 0, x, y - slice_height))
                else:
                    im = im.crop((0, slice_height, x, y))

                x,y = im.size

        # If the image is wider than it is tall
        else:
            while y < x:
                #slice 10px at a time until square
                slice_width = min(x - y, 10)

                left = im.crop((0,0, y, slice_width))
                right = im.crop((0,y - slice_width, x, y))

                #remove the slice with the least entropy
                if image_entropy(left) < image_entropy(right):
                    im = im.crop((0, 0, x - slice_width, y))
                else:
                    im = im.crop((slice_width, 0, x, y))

                x,y = im.size

        im = im.resize(requested_size, resample=Image.ANTIALIAS)

    return im
    
im = Image.open('ts.jpg')
cropped = square_image(im, [500, 500], ['autosquare'])
cropped.show()
