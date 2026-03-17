#import "ENRMMathInlineAttachment.h"
#import "ENRMFeatureFlags.h"

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

#if TARGET_OS_OSX

- (instancetype)init
{
  self = [super init];
  if (self) {
    // NSTextAttachment creates a default NSTextAttachmentCell on macOS.
    // Clear it so NSLayoutManager falls back to the image/bounds properties
    // we set in renderForMacOS.
    self.attachmentCell = nil;
  }
  return self;
}

- (void)renderForMacOS
{
  // MTMathUILabel is an NSView — must be created and laid out on the main thread.
  if (![NSThread isMainThread]) {
    dispatch_sync(dispatch_get_main_queue(), ^{ [self renderForMacOS]; });
    return;
  }

  MTMathUILabel *mathLabel = [[MTMathUILabel alloc] init];
  mathLabel.labelMode = kMTMathUILabelModeText;
  mathLabel.textAlignment = kMTTextAlignmentLeft;
  mathLabel.fontSize = self.fontSize;
  mathLabel.latex = self.latex;

  if (self.mathTextColor) {
    mathLabel.textColor = self.mathTextColor;
  }

  // Give the label a concrete frame so layoutSubviews positions the formula correctly.
  CGSize labelSize = mathLabel.intrinsicContentSize;
  mathLabel.frame = CGRectMake(0, 0, labelSize.width, labelSize.height);
  [mathLabel layout];

  _displayList = mathLabel.displayList;
  if (!_displayList) {
    return;
  }

  _mathAscent = _displayList.ascent;
  _mathDescent = _displayList.descent;
  _cachedSize = CGSizeMake(_displayList.width, _mathAscent + _mathDescent);

  // Render the formula into an NSImage. NSLayoutManager draws self.image
  // automatically when attachmentCell is nil, so this is the reliable
  // macOS rendering path instead of imageForBounds:textContainer:characterIndex:.
  //
  // NSImage.lockFocus creates a bottom-left origin Quartz context, which matches
  // CoreText's coordinate system — no CTM flip is needed here (unlike iOS where
  // UIGraphicsImageRenderer uses top-left origin and requires a flip).
  NSImage *image = [[NSImage alloc] initWithSize:_cachedSize];
  [image lockFocus];
  CGContextRef ctx = [[NSGraphicsContext currentContext] CGContext];
  CGContextSaveGState(ctx);
  _displayList.position = CGPointMake(0, _mathDescent);
  [_displayList draw:ctx];
  CGContextRestoreGState(ctx);
  [image unlockFocus];

  // self.image → NSLayoutManager draws it
  // self.bounds → positions the image relative to the baseline (negative Y = below baseline)
  self.image = image;
  self.bounds = CGRectMake(0, -_mathDescent, _cachedSize.width, _cachedSize.height);
}

#else

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

  [mathLabel layoutIfNeeded];

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

- (UIImage *)imageForBounds:(CGRect)imageBounds
              textContainer:(NSTextContainer *)textContainer
             characterIndex:(NSUInteger)characterIndex
{
  [self prepareIfNeeded];

  if (!_displayList)
    return nil;

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
}

#endif

@end

#endif
