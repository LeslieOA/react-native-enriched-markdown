#import "ENRMMathInlineAttachment.h"
#import "ENRMFeatureFlags.h"
#include <TargetConditionals.h>

#if ENRICHED_MARKDOWN_MATH
#import <IosMath/IosMath.h>
#endif

#if ENRICHED_MARKDOWN_MATH

@implementation ENRMMathInlineAttachment {
  CGSize _cachedSize;
  CGFloat _mathAscent;
  CGFloat _mathDescent;
  MTMathListDisplay *_displayList;
}

- (void)prepareIfNeeded
{
  if (_displayList)
    return;

  MTMathUILabel *mathLabel = [[MTMathUILabel alloc] init];
  mathLabel.labelMode = kMTMathUILabelModeText;
  mathLabel.textAlignment = kMTTextAlignmentLeft;
  mathLabel.fontSize = self.fontSize;
  mathLabel.latex = self.latex;

  if (self.mathTextColor) {
    mathLabel.textColor = self.mathTextColor;
  }

#if TARGET_OS_OSX
  [mathLabel layoutSubtreeIfNeeded];
#else
  [mathLabel layoutIfNeeded];
#endif

  _displayList = mathLabel.displayList;
  if (_displayList) {
    _mathAscent = _displayList.ascent;
    _mathDescent = _displayList.descent;
    _cachedSize = CGSizeMake(_displayList.width, _mathAscent + _mathDescent);
  }
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFragment
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)characterIndex
{
  [self prepareIfNeeded];

  return CGRectMake(0, -_mathDescent, _cachedSize.width, _cachedSize.height);
}

- (RCTUIImage *)imageForBounds:(CGRect)imageBounds
                 textContainer:(NSTextContainer *)textContainer
                characterIndex:(NSUInteger)characterIndex
{
  [self prepareIfNeeded];

  if (!_displayList)
    return nil;

#if TARGET_OS_OSX
  CGFloat scale = NSScreen.mainScreen.backingScaleFactor;
  NSImage *resultImage = [[NSImage alloc] initWithSize:_cachedSize];
  NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                  pixelsWide:(NSInteger)(_cachedSize.width * scale)
                                                                  pixelsHigh:(NSInteger)(_cachedSize.height * scale)
                                                               bitsPerSample:8
                                                             samplesPerPixel:4
                                                                    hasAlpha:YES
                                                                    isPlanar:NO
                                                              colorSpaceName:NSCalibratedRGBColorSpace
                                                                 bytesPerRow:0
                                                                bitsPerPixel:0];
  rep.size = _cachedSize;
  [resultImage addRepresentation:rep];
  [resultImage lockFocus];

  CGContextRef ctx = [[NSGraphicsContext currentContext] CGContext];
  CGContextSaveGState(ctx);
  CGContextTranslateCTM(ctx, 0, _cachedSize.height);
  CGContextScaleCTM(ctx, 1.0, -1.0);
  _displayList.position = CGPointMake(0, _mathDescent);
  [_displayList draw:ctx];
  CGContextRestoreGState(ctx);

  [resultImage unlockFocus];
  return resultImage;
#else
  UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat preferredFormat];
  format.opaque = NO;

  UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:_cachedSize format:format];

  return [renderer imageWithActions:^(UIGraphicsImageRendererContext *rendererContext) {
    CGContextRef ctx = rendererContext.CGContext;

    CGContextSaveGState(ctx);

    CGContextTranslateCTM(ctx, 0, _cachedSize.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    _displayList.position = CGPointMake(0, _mathDescent);

    [_displayList draw:ctx];

    CGContextRestoreGState(ctx);
  }];
#endif
}

@end

#endif
