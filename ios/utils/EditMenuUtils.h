#pragma once
#import <Foundation/Foundation.h>
#include <TargetConditionals.h>

#if !TARGET_OS_OSX
#import <UIKit/UIKit.h>
#endif

@class StyleConfig;

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

#if TARGET_OS_OSX
/// On macOS, the edit menu is not supported; this returns nil.
id _Nullable buildEditMenuForSelection(NSAttributedString *attributedText, NSRange range,
                                       NSString *_Nullable cachedMarkdown, StyleConfig *styleConfig,
                                       NSArray *suggestedActions);
#else
/// Builds edit menu with enhanced Copy (RTF/HTML/Markdown) and optional "Copy as Markdown"/"Copy Image URL".
UIMenu *buildEditMenuForSelection(NSAttributedString *attributedText, NSRange range, NSString *_Nullable cachedMarkdown,
                                  StyleConfig *styleConfig, NSArray<UIMenuElement *> *suggestedActions)
    API_AVAILABLE(ios(16.0));
#endif

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
