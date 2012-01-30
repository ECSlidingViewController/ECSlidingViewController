//
//  UIImage+ImageWithUIView.m
//  Taken from http://stackoverflow.com/a/7233268
//

#import "UIImage+ImageWithUIView.h"

@implementation UIImage (ImageWithUIView)
#pragma mark -
#pragma mark TakeScreenShot
static CGContextRef createBitmapContext(int pixelsWide, int pixelsHigh)
{
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGBitmapInfo bitmapInfo = (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
  CGContextRef bitmapContext = CGBitmapContextCreate(nil, pixelsWide, pixelsHigh, 8, 0, colorSpace, bitmapInfo);
  CGColorSpaceRelease(colorSpace);
  
  return bitmapContext;
}

+ (UIImage *)imageWithUIView:(UIView *)view
{
  CGSize screenShotSize = view.bounds.size;
  CGContextRef contextRef = createBitmapContext(screenShotSize.width, screenShotSize.height);
  CGContextTranslateCTM (contextRef, 0, screenShotSize.height);
  CGContextScaleCTM(contextRef, 1, -1);
  
  [view.layer renderInContext:contextRef];
  CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
  CGContextRelease(contextRef);
  
  UIImage *img = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  // return the image
  return img;
}
@end
