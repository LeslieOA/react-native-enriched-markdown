#pragma once
#import <Foundation/Foundation.h>
#import <React/RCTTextUIKit.h>
#import <React/RCTUIKit.h>

@class StyleConfig;

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

/// Builds edit menu with enhanced Copy (RTF/HTML/Markdown) and optional "Copy as Markdown"/"Copy Image URL".
/// Returns nil on macOS (edit menu is not supported on macOS).
#if TARGET_OS_OSX
id _Nullable buildEditMenuForSelection(NSAttributedString *attributedText, NSRange range,
                                       NSString *_Nullable cachedMarkdown, StyleConfig *styleConfig,
                                       NSArray *suggestedActions);
#else
UIMenu *buildEditMenuForSelection(NSAttributedString *attributedText, NSRange range, NSString *_Nullable cachedMarkdown,
                                  StyleConfig *styleConfig, NSArray<UIMenuElement *> *suggestedActions)
    API_AVAILABLE(ios(16.0));
#endif

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
