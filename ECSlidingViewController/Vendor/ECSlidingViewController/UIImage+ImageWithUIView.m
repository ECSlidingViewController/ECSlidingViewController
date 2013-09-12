//
//  UIImage+ImageWithUIView.m
//

#import "UIImage+ImageWithUIView.h"

@implementation UIImage (ImageWithUIView)
#pragma mark -
#pragma mark TakeScreenShot

+ (UIImage *)imageWithUIView:(UIView *)view
{
  CGSize screenShotSize = view.bounds.size;
  UIImage *img;  
  UIGraphicsBeginImageContext(screenShotSize);
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  [view.layer renderInContext:ctx];
  img = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return img;
}
@end
