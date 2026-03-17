#pragma once
#import "StyleConfig.h"
#import <React/RCTTextUIKit.h>
#import <React/RCTUIKit.h>
#include <TargetConditionals.h>

#if TARGET_OS_OSX
#import <React/RCTUITextView.h>
typedef RCTUITextView ENRMPlatformTextView;
#else
typedef UITextView ENRMPlatformTextView;
#endif

@class RenderContext;
@class AccessibilityInfo;

NS_ASSUME_NONNULL_BEGIN

@interface EnrichedMarkdownInternalText : RCTUIView

- (instancetype)initWithConfig:(StyleConfig *)config;

- (void)applyAttributedText:(NSMutableAttributedString *)text context:(RenderContext *)context;

- (CGFloat)measureHeight:(CGFloat)maxWidth;

@property (nonatomic, readonly) ENRMPlatformTextView *textView;

@property (nonatomic, strong, nullable) AccessibilityInfo *accessibilityInfo;

@property (nonatomic, strong) StyleConfig *config;

@property (nonatomic, assign) BOOL allowTrailingMargin;

@property (nonatomic, assign) CGFloat lastElementMarginBottom;

@end

NS_ASSUME_NONNULL_END
