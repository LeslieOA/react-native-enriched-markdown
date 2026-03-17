#pragma once
#import <React/RCTTextUIKit.h>
#import <React/RCTUIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ENRMMathInlineAttachment : NSTextAttachment

@property (nonatomic, strong) NSString *latex;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong, nullable) RCTUIColor *mathTextColor;

@end

NS_ASSUME_NONNULL_END
