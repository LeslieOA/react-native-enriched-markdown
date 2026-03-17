#pragma once
#import "StyleConfig.h"
#import <React/RCTTextUIKit.h>
#import <React/RCTUIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CodeBlockBackground : NSObject

- (instancetype)initWithConfig:(StyleConfig *)config;
- (void)drawBackgroundsForGlyphRange:(NSRange)glyphsToShow
                       layoutManager:(NSLayoutManager *)layoutManager
                       textContainer:(NSTextContainer *)textContainer
                             atPoint:(CGPoint)origin;

@end

NS_ASSUME_NONNULL_END
