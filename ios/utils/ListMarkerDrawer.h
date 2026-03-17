#import <Foundation/Foundation.h>
#import <React/RCTTextUIKit.h>
#import <React/RCTUIKit.h>

@class StyleConfig;

@interface ListMarkerDrawer : NSObject

- (instancetype)initWithConfig:(StyleConfig *)config;

- (void)drawMarkersForGlyphRange:(NSRange)glyphsToShow
                   layoutManager:(NSLayoutManager *)layoutManager
                   textContainer:(NSTextContainer *)textContainer
                         atPoint:(CGPoint)origin;

@end
