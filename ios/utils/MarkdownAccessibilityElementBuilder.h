#import <React/RCTTextUIKit.h>
#import <React/RCTUIKit.h>
#include <TargetConditionals.h>

@class AccessibilityInfo;

NS_ASSUME_NONNULL_BEGIN

#if !TARGET_OS_OSX

/**
 * Builds UIAccessibilityElement objects from markdown content for VoiceOver.
 * Handles headings, links, images, lists, and custom rotor navigation.
 */
@interface MarkdownAccessibilityElementBuilder : NSObject

+ (NSMutableArray<UIAccessibilityElement *> *)buildElementsForTextView:(UITextView *)textView
                                                                  info:(AccessibilityInfo *)info
                                                             container:(id)container;

+ (NSArray<UIAccessibilityElement *> *)filterHeadingElements:(NSArray<UIAccessibilityElement *> *)elements;
+ (NSArray<UIAccessibilityElement *> *)filterLinkElements:(NSArray<UIAccessibilityElement *> *)elements;
+ (NSArray<UIAccessibilityElement *> *)filterImageElements:(NSArray<UIAccessibilityElement *> *)elements;

+ (UIAccessibilityCustomRotor *)createHeadingRotorWithElements:(NSArray<UIAccessibilityElement *> *)elements;
+ (UIAccessibilityCustomRotor *)createLinkRotorWithElements:(NSArray<UIAccessibilityElement *> *)elements;
+ (UIAccessibilityCustomRotor *)createImageRotorWithElements:(NSArray<UIAccessibilityElement *> *)elements;

+ (NSArray<UIAccessibilityCustomRotor *> *)buildRotorsFromElements:(NSArray<UIAccessibilityElement *> *)elements;

@end

#endif

NS_ASSUME_NONNULL_END
