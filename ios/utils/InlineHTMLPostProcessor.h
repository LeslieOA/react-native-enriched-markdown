#import "ENRMUIKit.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Post-processes an attributed string to replace PUA (Private Use Area)
 * Unicode markers with the corresponding NSAttributedString attributes.
 *
 * PUA mapping (inserted by JS preprocessor):
 *   U+E001 / U+E002 → <mark>  (background highlight)
 *   U+E003 / U+E004 → <sub>   (subscript baseline offset + smaller font)
 *   U+E005 / U+E006 → <sup>   (superscript baseline offset + smaller font)
 */
#ifdef __cplusplus
extern "C" {
#endif

void applyInlineHTMLPostProcessing(NSMutableAttributedString *output);

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
