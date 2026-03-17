#import <React/RCTTextUIKit.h>
#import <React/RCTUIKit.h>

@interface FontScaleObserver : NSObject

@property (nonatomic, assign) BOOL allowFontScaling;
@property (nonatomic, readonly) CGFloat effectiveFontScale;

@property (nonatomic, copy, nullable) void (^onChange)(void);

@end
