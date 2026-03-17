#pragma once

#import <React/RCTTextUIKit.h>
#import <React/RCTUIKit.h>
#include <TargetConditionals.h>

#if TARGET_OS_OSX
#import <React/RCTUITextView.h>
typedef RCTUITextView ENRMPlatformTextView;
typedef NSClickGestureRecognizer UITapGestureRecognizer;
#else
typedef UITextView ENRMPlatformTextView;
#endif

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

/// Returns the link URL at the tap location, or nil if no link was tapped.
NSString *_Nullable linkURLAtTapLocation(ENRMPlatformTextView *textView, UITapGestureRecognizer *recognizer);

/// Returns the link URL at the given character range, or nil if none found.
NSString *_Nullable linkURLAtRange(ENRMPlatformTextView *textView, NSRange characterRange);

/// Returns YES if the point (in textView coordinates) is on a link or task list checkbox.
BOOL isPointOnInteractiveElement(ENRMPlatformTextView *textView, CGPoint point);

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
