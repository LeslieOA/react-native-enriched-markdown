#pragma once
#import <React/RCTTextUIKit.h>
#import <React/RCTUIKit.h>
#include <TargetConditionals.h>

#if TARGET_OS_OSX
#import <React/RCTUITextView.h>
typedef RCTUITextView ENRMPlatformTextView;
#else
typedef UITextView ENRMPlatformTextView;
#endif

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

+ (instancetype)attachmentForURL:(NSString *)imageURL config:(StyleConfig *)config isInline:(BOOL)isInline;

+ (void)clearAttachmentRegistry;

+ (NSCache<NSString *, RCTUIImage *> *)originalImageCache;
+ (NSCache<NSString *, RCTUIImage *> *)processedImageCache;

@end

NS_ASSUME_NONNULL_END
