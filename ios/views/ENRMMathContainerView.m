#import "ENRMMathContainerView.h"
#import "ENRMFeatureFlags.h"
#include <TargetConditionals.h>

#if ENRICHED_MARKDOWN_MATH
#import <IosMath/IosMath.h>
#endif

#if TARGET_OS_OSX
#import <AppKit/NSPasteboard.h>
#else
#import <UIKit/UIPasteboard.h>
#endif

#if ENRICHED_MARKDOWN_MATH

#if TARGET_OS_OSX
@interface ENRMMathContainerView ()
#else
@interface ENRMMathContainerView () <UIContextMenuInteractionDelegate>
#endif
@property (nonatomic, strong, readonly) MTMathUILabel *mathLabel;
#if TARGET_OS_OSX
@property (nonatomic, strong, readonly) NSScrollView *scrollView;
#else
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
#endif
@property (nonatomic, copy, readwrite) NSString *cachedLatex;
@end

@implementation ENRMMathContainerView

- (instancetype)initWithConfig:(StyleConfig *)config
{
  self = [super initWithFrame:CGRectZero];
  if (self) {
    _config = config;
    _cachedLatex = @"";

#if TARGET_OS_OSX
    _scrollView = [[NSScrollView alloc] init];
    _scrollView.hasVerticalScroller = NO;
    _scrollView.hasHorizontalScroller = YES;
    _scrollView.autohidesScrollers = YES;
    _scrollView.drawsBackground = NO;

    _mathLabel = [[MTMathUILabel alloc] init];
    _mathLabel.labelMode = kMTMathUILabelModeDisplay;

    NSView *documentView = [[NSView alloc] init];
    [documentView addSubview:_mathLabel];
    _scrollView.documentView = documentView;
    [self addSubview:_scrollView];
#else
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = YES;
    _scrollView.bounces = YES;
    _scrollView.alwaysBounceHorizontal = NO;
    [self addSubview:_scrollView];

    _mathLabel = [[MTMathUILabel alloc] init];
    _mathLabel.labelMode = kMTMathUILabelModeDisplay;
    [_scrollView addSubview:_mathLabel];

    UIContextMenuInteraction *contextMenu = [[UIContextMenuInteraction alloc] initWithDelegate:self];
    [self addInteraction:contextMenu];
#endif

#if !TARGET_OS_OSX
    self.isAccessibilityElement = YES;
#endif
  }
  return self;
}

- (void)applyLatex:(NSString *)latex
{
  _cachedLatex = [latex copy];

  StyleConfig *config = self.config;

  _mathLabel.latex = latex;
  _mathLabel.fontSize = config.mathFontSize;
  _mathLabel.textColor = config.mathColor;
  _mathLabel.textAlignment = [self mapAlignment:config.mathTextAlign];

  CGFloat padding = config.mathPadding;
#if TARGET_OS_OSX
  _mathLabel.contentInsets = NSEdgeInsetsMake(padding, padding, padding, padding);
#else
  _mathLabel.contentInsets = UIEdgeInsetsMake(padding, padding, padding, padding);
#endif

  self.backgroundColor = config.mathBackgroundColor ?: [RCTUIColor clearColor];

  [self setNeedsLayout];
}

#if !TARGET_OS_OSX
- (UIContextMenuConfiguration *)contextMenuInteraction:(UIContextMenuInteraction *)interaction
                        configurationForMenuAtLocation:(CGPoint)location
{
  return [UIContextMenuConfiguration
      configurationWithIdentifier:nil
                  previewProvider:nil
                   actionProvider:^UIMenu *(NSArray<UIMenuElement *> *suggestedActions) {
                     UIAction *copyPlainText =
                         [UIAction actionWithTitle:@"Copy"
                                             image:[UIImage systemImageNamed:@"doc.on.doc"]
                                        identifier:nil
                                           handler:^(__kindof UIAction *action) { [self copyLatexToPasteboard]; }];

                     UIAction *copyMarkdown =
                         [UIAction actionWithTitle:@"Copy as Markdown"
                                             image:[UIImage systemImageNamed:@"doc.text"]
                                        identifier:nil
                                           handler:^(__kindof UIAction *action) { [self copyMarkdownToPasteboard]; }];

                     return [UIMenu menuWithTitle:@"" children:@[ copyPlainText, copyMarkdown ]];
                   }];
}
#endif

- (void)copyLatexToPasteboard
{
#if TARGET_OS_OSX
  NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
  [pasteboard clearContents];
  [pasteboard setString:_cachedLatex forType:NSPasteboardTypeString];
#else
  [[UIPasteboard generalPasteboard] setString:_cachedLatex];
#endif
}

- (void)copyMarkdownToPasteboard
{
  NSString *markdown = [NSString stringWithFormat:@"$$\n%@\n$$", _cachedLatex];
#if TARGET_OS_OSX
  NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
  [pasteboard clearContents];
  [pasteboard setString:markdown forType:NSPasteboardTypeString];
#else
  [[UIPasteboard generalPasteboard] setString:markdown];
#endif
}

- (MTTextAlignment)mapAlignment:(NSString *)align
{
  if ([align isEqualToString:@"left"])
    return kMTTextAlignmentLeft;
  if ([align isEqualToString:@"right"])
    return kMTTextAlignmentRight;
  return kMTTextAlignmentCenter;
}

- (CGFloat)measureHeight:(CGFloat)maxWidth
{
#if TARGET_OS_OSX
  CGSize intrinsicSize = _mathLabel.intrinsicContentSize;
#else
  CGSize intrinsicSize = [_mathLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
#endif
  return intrinsicSize.height;
}

- (void)layoutSubviews
{
  [super layoutSubviews];

#if TARGET_OS_OSX
  CGSize intrinsicSize = _mathLabel.intrinsicContentSize;
#else
  CGSize intrinsicSize = [_mathLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
#endif
  CGFloat contentWidth = MAX(intrinsicSize.width, self.bounds.size.width);
  CGFloat contentHeight = self.bounds.size.height;

  _scrollView.frame = self.bounds;
#if TARGET_OS_OSX
  _scrollView.documentView.frame = CGRectMake(0, 0, contentWidth, contentHeight);
#else
  _scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
  _scrollView.scrollEnabled = (intrinsicSize.width > self.bounds.size.width);
#endif
  _mathLabel.frame = CGRectMake(0, 0, contentWidth, contentHeight);
}

- (NSString *)accessibilityLabel
{
  return [NSString stringWithFormat:@"Math equation: %@", _cachedLatex];
}

#if !TARGET_OS_OSX
- (UIAccessibilityTraits)accessibilityTraits
{
  return UIAccessibilityTraitStaticText;
}
#endif

@end

#endif