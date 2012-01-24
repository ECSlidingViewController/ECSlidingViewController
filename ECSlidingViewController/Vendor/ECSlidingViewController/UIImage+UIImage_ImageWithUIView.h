//
//  UIImage+UIImage_ImageWithUIView.h
//  Taken from http://stackoverflow.com/a/7233268
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIImage (UIImage_ImagewithUIView)
+ (UIImage *)imageWithUIView:(UIView *)view;
@end