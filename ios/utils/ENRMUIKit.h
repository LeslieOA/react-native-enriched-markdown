#pragma once

#import <React/RCTTextUIKit.h>
#import <React/RCTUIKit.h>
#include <TargetConditionals.h>

#if TARGET_OS_OSX
#import <React/RCTUITextView.h>
/// Platform text view: RCTUITextView on macOS, UITextView on iOS.
#define ENRMPlatformTextView RCTUITextView
/// Platform tap recognizer: NSClickGestureRecognizer on macOS, UITapGestureRecognizer on iOS.
#define ENRMTapRecognizer NSClickGestureRecognizer
#else
#define ENRMPlatformTextView UITextView
#define ENRMTapRecognizer UITapGestureRecognizer
#endif

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
