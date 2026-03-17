#pragma once

#include <TargetConditionals.h>

// RCTUIKit.h is react-native-macos only. On iOS we import UIKit and define the aliases ourselves.
#if TARGET_OS_OSX
#import <React/RCTTextUIKit.h>
#import <React/RCTUIKit.h>
#import <React/RCTUITextView.h>
#define ENRMPlatformTextView RCTUITextView
#define ENRMTapRecognizer NSClickGestureRecognizer
#else
#import <UIKit/UIKit.h>
#define RCTUIColor UIColor
#define RCTUIImage UIImage
#define RCTUIView UIView
#define RCTUIScrollView UIScrollView
#define RCTUIGraphicsImageRenderer UIGraphicsImageRenderer
#define RCTUIGraphicsImageRendererContext UIGraphicsImageRendererContext
#define RCTUIGraphicsImageRendererFormat UIGraphicsImageRendererFormat
#define ENRMPlatformTextView UITextView
#define ENRMTapRecognizer UITapGestureRecognizer

// Inline helpers that RCTUIKit.h normally provides on iOS.
static inline UIBezierPath *UIBezierPathWithRoundedRect(CGRect rect, CGFloat cornerRadius)
{
  return [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
}
static inline void UIBezierPathAppendPath(UIBezierPath *path, UIBezierPath *appendPath)
{
  [path appendPath:appendPath];
}
static inline CGFloat UIFontLineHeight(UIFont *font)
{
  return font.lineHeight;
}
#endif

/// On iOS, explicitly sets opaque=NO — without it the renderer produces an opaque backing,
/// breaking transparent backgrounds. macOS handles transparency by default.
static inline RCTUIGraphicsImageRenderer *ImageRendererForSize(CGSize size)
{
#if TARGET_OS_OSX
  return [[RCTUIGraphicsImageRenderer alloc] initWithSize:size];
#else
  RCTUIGraphicsImageRendererFormat *format = [RCTUIGraphicsImageRendererFormat preferredFormat];
  format.opaque = NO;
  return [[RCTUIGraphicsImageRenderer alloc] initWithSize:size format:format];
#endif
}

/// NSBezierPath uses NS-prefixed enum values; UIBezierPath uses kCG-prefixed constants.
static inline void BezierPathSetRoundStyle(UIBezierPath *path)
{
#if TARGET_OS_OSX
  path.lineCapStyle = NSLineCapStyleRound;
  path.lineJoinStyle = NSLineJoinStyleRound;
#else
  path.lineCapStyle = kCGLineCapRound;
  path.lineJoinStyle = kCGLineJoinRound;
#endif
}

/// Cross-platform line segment: NSBezierPath uses lineToPoint: instead of addLineToPoint:.
static inline void BezierPathAddLine(UIBezierPath *path, CGPoint point)
{
#if TARGET_OS_OSX
  [path lineToPoint:point];
#else
  [path addLineToPoint:point];
#endif
}

/// Cross-platform quad-curve: NSBezierPath lacks addQuadCurveToPoint:, so we approximate
/// with a cubic Bezier using the standard quadratic-to-cubic conversion.
static inline void BezierPathAddQuadCurve(UIBezierPath *path, CGPoint end, CGPoint control)
{
#if TARGET_OS_OSX
  CGPoint start = [path currentPoint];
  [path curveToPoint:end
       controlPoint1:CGPointMake(start.x + 2.0 / 3.0 * (control.x - start.x),
                                 start.y + 2.0 / 3.0 * (control.y - start.y))
       controlPoint2:CGPointMake(end.x + 2.0 / 3.0 * (control.x - end.x), end.y + 2.0 / 3.0 * (control.y - end.y))];
#else
  [path addQuadCurveToPoint:end controlPoint:control];
#endif
}

/// Cross-platform attributed text read: NSTextView exposes content via textStorage;
/// UITextView exposes it via attributedText.
static inline NSAttributedString *ENRMGetAttributedText(ENRMPlatformTextView *textView)
{
#if TARGET_OS_OSX
  return textView.textStorage;
#else
  return textView.attributedText;
#endif
}

/// Cross-platform display refresh: UIView requires layoutIfNeeded before setNeedsDisplay
/// to flush pending layout before the redraw; NSView takes a BOOL argument.
/// Implemented as a macro to avoid Objective-C++ implicit pointer conversion issues in .mm files.
#if TARGET_OS_OSX
#define ENRMSetNeedsDisplay(view) [(view) setNeedsDisplay:YES]
#else
#define ENRMSetNeedsDisplay(view)                                                                                      \
  do {                                                                                                                 \
    [(view) layoutIfNeeded];                                                                                           \
    [(view) setNeedsDisplay];                                                                                          \
  } while (0)
#endif

/// Refreshes a text view's layout and display after it is attached to a window.
/// On iOS, resets contentOffset to zero (NSTextView has no scroll position).
/// Sets the frame and text container to the given bounds, invalidates layout for
/// any existing content, then triggers a redraw.
static inline void ENRMRefreshTextViewAfterWindowAttach(ENRMPlatformTextView *textView, CGRect bounds)
{
#if !TARGET_OS_OSX
  textView.contentOffset = CGPointZero;
#endif
  textView.frame = bounds;
  textView.textContainer.size = CGSizeMake(bounds.size.width, CGFLOAT_MAX);
  NSUInteger textLength = ENRMGetAttributedText(textView).length;
  if (textLength > 0) {
    [textView.layoutManager invalidateLayoutForCharacterRange:NSMakeRange(0, textLength) actualCharacterRange:NULL];
    [textView.layoutManager ensureLayoutForTextContainer:textView.textContainer];
  }
  ENRMSetNeedsDisplay(textView);
}
