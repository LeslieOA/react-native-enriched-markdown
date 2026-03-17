#import "ThematicBreakAttachment.h"
#include <TargetConditionals.h>

@implementation ThematicBreakAttachment

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex
{
  CGFloat totalHeight = self.marginTop + self.lineHeight + self.marginBottom;
  return CGRectMake(0, 0, CGRectGetWidth(lineFrag), totalHeight);
}

- (RCTUIImage *)imageForBounds:(CGRect)imageBounds
                 textContainer:(NSTextContainer *)textContainer
                characterIndex:(NSUInteger)charIndex
{
#if TARGET_OS_OSX
  CGFloat scale = NSScreen.mainScreen.backingScaleFactor;
  NSImage *resultImage = [[NSImage alloc] initWithSize:imageBounds.size];
  NSBitmapImageRep *rep =
      [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                              pixelsWide:(NSInteger)(imageBounds.size.width * scale)
                                              pixelsHigh:(NSInteger)(imageBounds.size.height * scale)
                                           bitsPerSample:8
                                         samplesPerPixel:4
                                                hasAlpha:YES
                                                isPlanar:NO
                                          colorSpaceName:NSCalibratedRGBColorSpace
                                             bytesPerRow:0
                                            bitsPerPixel:0];
  rep.size = imageBounds.size;
  [resultImage addRepresentation:rep];
  [resultImage lockFocus];

  CGContextRef ctx = [[NSGraphicsContext currentContext] CGContext];
  CGFloat lineY = self.marginTop + (self.lineHeight / 2.0);

  [self.lineColor setStroke];
  CGContextSetLineWidth(ctx, self.lineHeight);
  CGContextMoveToPoint(ctx, 0, lineY);
  CGContextAddLineToPoint(ctx, imageBounds.size.width, lineY);
  CGContextStrokePath(ctx);

  [resultImage unlockFocus];
  return resultImage;
#else
  UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:imageBounds.size];

  return [renderer imageWithActions:^(UIGraphicsImageRendererContext *_Nonnull rendererContext) {
    CGContextRef ctx = rendererContext.CGContext;

    CGFloat lineY = self.marginTop + (self.lineHeight / 2.0);

    [self.lineColor setStroke];
    CGContextSetLineWidth(ctx, self.lineHeight);
    CGContextMoveToPoint(ctx, 0, lineY);
    CGContextAddLineToPoint(ctx, imageBounds.size.width, lineY);
    CGContextStrokePath(ctx);
  }];
#endif
}

@end
