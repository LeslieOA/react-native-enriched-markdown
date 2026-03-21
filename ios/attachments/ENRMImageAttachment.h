#pragma once
#import "ENRMUIKit.h"

@class StyleConfig;

NS_ASSUME_NONNULL_BEGIN

/**
 * Custom NSTextAttachment for rendering markdown images.
 * Images are loaded asynchronously and scaled dynamically based on text container width.
 * Supports inline and block images with custom height and border radius from config.
 */
@interface ENRMImageAttachment : NSTextAttachment

@property (nonatomic, readonly) NSString *imageURL;
@property (nonatomic, readonly) BOOL isInline;
/// Explicit width from <img> tag (0 = use default sizing)
@property (nonatomic, readonly) CGFloat explicitWidth;
/// Explicit height from <img> tag (0 = use default sizing)
@property (nonatomic, readonly) CGFloat explicitHeight;
/// When YES, images render at natural dimensions (clamped to container width)
@property (nonatomic, readonly) BOOL responsive;

+ (instancetype)attachmentForURL:(NSString *)imageURL config:(StyleConfig *)config isInline:(BOOL)isInline;

+ (void)clearAttachmentRegistry;

+ (NSCache<NSString *, RCTUIImage *> *)originalImageCache;
+ (NSCache<NSString *, RCTUIImage *> *)processedImageCache;

@end

NS_ASSUME_NONNULL_END
