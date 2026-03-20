#pragma once
#include <TargetConditionals.h>

#if TARGET_OS_OSX
#import "ENRMUIKit.h"

typedef NSMenu *_Nullable (^ENRMContextMenuProvider)(NSMenu *baseMenu, NSTextView *textView);

/// Called when a link is clicked. Return YES if handled.
typedef BOOL (^ENRMLinkClickHandler)(NSString *url);

/// macOS-only ENRMPlatformTextView subclass that manages context menus
/// and text deselection across sibling text views.
@interface ENRMContextMenuTextView : ENRMPlatformTextView <NSMenuDelegate>

@property (nonatomic, copy, nullable) ENRMContextMenuProvider contextMenuProvider;
@property (nonatomic, copy, nullable) ENRMLinkClickHandler linkClickHandler;

@end

#endif // TARGET_OS_OSX
