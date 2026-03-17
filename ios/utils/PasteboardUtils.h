#pragma once
#import <Foundation/Foundation.h>
#import <React/RCTTextUIKit.h>
#import <React/RCTUIKit.h>

@class StyleConfig;

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Copies a plain string to the platform pasteboard.
 */
void copyStringToPasteboard(NSString *string);

/**
 * Copies a dictionary of { UTI → NSString | NSData } items to the platform pasteboard.
 * On macOS, NSString values use setString:forType: and NSData values use setData:forType:.
 * On iOS, the whole dictionary is passed to UIPasteboard setItems:.
 */
void copyItemsToPasteboard(NSDictionary<NSString *, id> *items);

/**
 * Copies attributed string to pasteboard with multiple representations
 * (plain text, Markdown, HTML, RTFD, RTF). Receiving apps pick the richest format they support.
 */
void copyAttributedStringToPasteboard(NSAttributedString *attributedString, NSString *_Nullable markdown,
                                      StyleConfig *_Nullable styleConfig);

/**
 * Extracts markdown for the given range.
 * Full selection returns cached markdown; partial selection reverse-engineers from attributes.
 */
NSString *_Nullable markdownForRange(NSAttributedString *attributedText, NSRange range,
                                     NSString *_Nullable cachedMarkdown);

/**
 * Returns remote image URLs (http/https only) from ENRMImageAttachments in the given range.
 */
NSArray<NSString *> *imageURLsInRange(NSAttributedString *attributedText, NSRange range);

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
