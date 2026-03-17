#pragma once
#import <React/RCTTextUIKit.h>
#import <React/RCTUIKit.h>
#include <TargetConditionals.h>

/// Returns YES if the measured content height differs from the frame height
/// Yoga assigned, comparing at physical-pixel granularity to avoid
/// false positives from sub-pixel floating-point differences.
static inline BOOL needsHeightUpdate(CGSize measuredSize, CGRect bounds)
{
#if TARGET_OS_OSX
  CGFloat scale = NSScreen.mainScreen.backingScaleFactor;
#else
  CGFloat scale = [UIScreen mainScreen].scale;
#endif
  CGFloat assignedHeight = ceil(bounds.size.height * scale) / scale;
  CGFloat measuredHeight = ceil(measuredSize.height * scale) / scale;
  return assignedHeight != measuredHeight;
}
