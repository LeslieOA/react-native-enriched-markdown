#import "InlineHTMLPostProcessor.h"

/// PUA marker characters (must match JS preprocessor in EnrichedMarkdownText.tsx)
static const unichar kMarkOpen = 0xE001;
static const unichar kMarkClose = 0xE002;
static const unichar kSubOpen = 0xE003;
static const unichar kSubClose = 0xE004;
static const unichar kSupOpen = 0xE005;
static const unichar kSupClose = 0xE006;

/// Scale factor for sub/superscript font size relative to the surrounding text
static const CGFloat kScriptFontScale = 0.75;
/// Baseline offset for subscript (negative = below baseline)
static const CGFloat kSubscriptOffset = -0.2;
/// Baseline offset for superscript (positive = above baseline)
static const CGFloat kSuperscriptOffset = 0.4;

typedef struct {
  unichar openChar;
  unichar closeChar;
} PUAMarkerPair;

/**
 * Process a single PUA marker pair: find open/close markers, remove them,
 * and apply attributes to the content between them.
 */
static void processMarkerPair(NSMutableAttributedString *output, PUAMarkerPair pair,
                              void (^applyAttributes)(NSMutableAttributedString *, NSRange))
{
  // Process from end to front so index shifts don't affect earlier matches
  NSString *text = output.string;
  NSUInteger length = text.length;

  // Find all open markers first, then match with close markers
  for (NSInteger i = (NSInteger)length - 1; i >= 0; i--) {
    if ([text characterAtIndex:i] != pair.openChar)
      continue;

    // Found open marker at i — find matching close marker
    NSRange searchRange = NSMakeRange(i + 1, text.length - (i + 1));
    NSString *closeStr = [NSString stringWithCharacters:&pair.closeChar length:1];
    NSRange closeRange = [text rangeOfString:closeStr options:0 range:searchRange];
    if (closeRange.location == NSNotFound)
      continue;

    // Remove close marker first (higher index)
    [output deleteCharactersInRange:closeRange];
    // Remove open marker
    [output deleteCharactersInRange:NSMakeRange(i, 1)];

    // Content range (after removing both markers)
    NSRange contentRange = NSMakeRange(i, closeRange.location - i - 1);
    if (contentRange.length > 0) {
      applyAttributes(output, contentRange);
    }

    // Re-read string after mutation
    text = output.string;
  }
}

void applyInlineHTMLPostProcessing(NSMutableAttributedString *output)
{
  if (output.length == 0)
    return;

  // Quick check: scan for any PUA characters before doing work
  NSCharacterSet *puaSet = [NSCharacterSet
      characterSetWithCharactersInString:[NSString stringWithFormat:@"%C%C%C%C%C%C", kMarkOpen, kMarkClose, kSubOpen,
                                                                    kSubClose, kSupOpen, kSupClose]];
  if ([output.string rangeOfCharacterFromSet:puaSet].location == NSNotFound) {
    return;
  }

  // <mark> → background highlight
  processMarkerPair(output, (PUAMarkerPair){kMarkOpen, kMarkClose}, ^(NSMutableAttributedString *str, NSRange range) {
    RCTUIColor *highlightColor;
#if TARGET_OS_OSX
    NSAppearance *appearance = [NSApp effectiveAppearance];
    NSAppearanceName bestMatch =
        [appearance bestMatchFromAppearancesWithNames:@[ NSAppearanceNameAqua, NSAppearanceNameDarkAqua ]];
    BOOL isDark = [bestMatch isEqualToString:NSAppearanceNameDarkAqua];
#else
      BOOL isDark = NO;
      if (@available(iOS 13.0, *)) {
        isDark = [UITraitCollection currentTraitCollection].userInterfaceStyle == UIUserInterfaceStyleDark;
      }
#endif
    highlightColor = isDark ? [RCTUIColor colorWithRed:0.4 green:0.35 blue:0.0 alpha:1.0]  // dark: muted yellow
                            : [RCTUIColor colorWithRed:1.0 green:0.95 blue:0.4 alpha:1.0]; // light: yellow highlight
    [str addAttribute:NSBackgroundColorAttributeName value:highlightColor range:range];
  });

  // <sub> → subscript
  processMarkerPair(output, (PUAMarkerPair){kSubOpen, kSubClose}, ^(NSMutableAttributedString *str, NSRange range) {
    [str enumerateAttribute:NSFontAttributeName
                    inRange:range
                    options:0
                 usingBlock:^(id value, NSRange attrRange, BOOL *stop) {
#if TARGET_OS_OSX
                   NSFont *font = value ?: [NSFont systemFontOfSize:NSFont.systemFontSize];
                   CGFloat smallSize = font.pointSize * kScriptFontScale;
                   NSFont *smallFont = [NSFont fontWithDescriptor:font.fontDescriptor size:smallSize];
#else
        UIFont *font = value ?: [UIFont systemFontOfSize:UIFont.systemFontSize];
        CGFloat smallSize = font.pointSize * kScriptFontScale;
        UIFont *smallFont = [font fontWithSize:smallSize];
#endif
                   [str addAttribute:NSFontAttributeName value:smallFont range:attrRange];
                   [str addAttribute:NSBaselineOffsetAttributeName
                               value:@(font.pointSize * kSubscriptOffset)
                               range:attrRange];
                 }];
  });

  // <sup> → superscript
  processMarkerPair(output, (PUAMarkerPair){kSupOpen, kSupClose}, ^(NSMutableAttributedString *str, NSRange range) {
    [str enumerateAttribute:NSFontAttributeName
                    inRange:range
                    options:0
                 usingBlock:^(id value, NSRange attrRange, BOOL *stop) {
#if TARGET_OS_OSX
                   NSFont *font = value ?: [NSFont systemFontOfSize:NSFont.systemFontSize];
                   CGFloat smallSize = font.pointSize * kScriptFontScale;
                   NSFont *smallFont = [NSFont fontWithDescriptor:font.fontDescriptor size:smallSize];
#else
        UIFont *font = value ?: [UIFont systemFontOfSize:UIFont.systemFontSize];
        CGFloat smallSize = font.pointSize * kScriptFontScale;
        UIFont *smallFont = [font fontWithSize:smallSize];
#endif
                   [str addAttribute:NSFontAttributeName value:smallFont range:attrRange];
                   [str addAttribute:NSBaselineOffsetAttributeName
                               value:@(font.pointSize * kSuperscriptOffset)
                               range:attrRange];
                 }];
  });
}
