#pragma once
#import "StyleConfig.h"
#import <React/RCTTextUIKit.h>
#import <React/RCTUIKit.h>
#include <TargetConditionals.h>

NS_ASSUME_NONNULL_BEGIN

@interface ENRMMathContainerView : RCTUIView

- (instancetype)initWithConfig:(StyleConfig *)config;

- (void)applyLatex:(NSString *)latex;

- (CGFloat)measureHeight:(CGFloat)maxWidth;

@property (nonatomic, strong) StyleConfig *config;
@property (nonatomic, copy, readonly) NSString *cachedLatex;

@end

NS_ASSUME_NONNULL_END
