#import "EmojiAvailabilityPlugin.h"

@implementation EmojiAvailabilityPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"emoji_availability"
            binaryMessenger:[registrar messenger]];
  EmojiAvailabilityPlugin* instance = [[EmojiAvailabilityPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"checkEmojiAvailable" isEqualToString:call.method]) {
    NSString *emoji = call.arguments;
    if (emoji != nil) {
      BOOL isEmoji = [self isEmoji:emoji];
      result(isEmoji ? @YES : @NO);
    } else {
      result([FlutterError errorWithCode:@"600"
                                 message:@"Invalid Parameter: Must be a String"
                                 details:@"Invalid Parameter: Must be a String"]);
    }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

-(BOOL)isEmoji:(NSString *)character {
  
  UILabel *characterRender = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
  characterRender.text = character;
  characterRender.backgroundColor = [UIColor blackColor];//needed to remove subpixel rendering colors
  [characterRender sizeToFit];
  
  CGRect rect = [characterRender bounds];
  UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
  CGContextRef contextSnap = UIGraphicsGetCurrentContext();
  [characterRender.layer renderInContext:contextSnap];
  UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  CGImageRef imageRef = [capturedImage CGImage];
  NSUInteger width = CGImageGetWidth(imageRef);
  NSUInteger height = CGImageGetHeight(imageRef);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
  NSUInteger bytesPerPixel = 4;
  NSUInteger bytesPerRow = bytesPerPixel * width;
  NSUInteger bitsPerComponent = 8;
  CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                               bitsPerComponent, bytesPerRow, colorSpace,
                                               kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  CGColorSpaceRelease(colorSpace);
  
  CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
  CGContextRelease(context);
  
  BOOL colorPixelFound = NO;
  
  int x = 0;
  int y = 0;
  while (y < height && !colorPixelFound) {
    while (x < width && !colorPixelFound) {
      
      NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
      
      CGFloat red = (CGFloat)rawData[byteIndex];
      CGFloat green = (CGFloat)rawData[byteIndex+1];
      CGFloat blue = (CGFloat)rawData[byteIndex+2];
      
      CGFloat h, s, b, a;
      UIColor *c = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
      [c getHue:&h saturation:&s brightness:&b alpha:&a];
      
      b /= 255.0f;
      
      if (b > 0) {
        colorPixelFound = YES;
      }
      
      x++;
    }
    x=0;
    y++;
  }
  
  return colorPixelFound;
  
}

@end
