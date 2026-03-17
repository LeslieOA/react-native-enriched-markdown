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

@class StyleConfig;

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
  BOOL found;
  NSInteger index;
  BOOL checked;
  NSRange itemRange;
} TaskListHitTestResult;

TaskListHitTestResult taskListHitTest(ENRMPlatformTextView *textView, UITapGestureRecognizer *recognizer);

NSRange taskListItemFullRange(ENRMPlatformTextView *textView, NSInteger taskIndex);

NSString *taskListItemText(ENRMPlatformTextView *textView, NSRange itemRange);

BOOL handleTaskListTap(ENRMPlatformTextView *textView, UITapGestureRecognizer *recognizer,
                       void (^handler)(NSInteger index, BOOL checked, NSString *itemText));

NSString *toggleTaskListItemAtIndex(NSString *markdown, NSInteger index, BOOL checked);

BOOL updateTaskListItemCheckedState(ENRMPlatformTextView *textView, NSInteger targetIndex, BOOL newChecked,
                                    StyleConfig *config);

BOOL handleTaskListTapWithSharedLogic(ENRMPlatformTextView *textView, UITapGestureRecognizer *recognizer,
                                      NSString *__strong *cachedMarkdown, StyleConfig *config,
                                      void (^eventEmitterBlock)(NSInteger index, BOOL checked, NSString *itemText),
                                      void (^renderBlock)(NSString *updatedMarkdown));

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
