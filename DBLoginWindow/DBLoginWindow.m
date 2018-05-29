//
//  DBLoginWindow.m
//  DBLoginWindow
//
//  Created by Wolfgang Baird on 5/19/18.
//
//

#import "DBLoginWindow.h"
#import "FConvenience.h"

@interface DBLoginWindow()

@end

@implementation DBLoginWindow

+ (instancetype)sharedInstance {
    static DBLoginWindow *plugin = nil;
    @synchronized(self) {
        if (!plugin) {
            plugin = [[self alloc] init];
        }
    }
    return plugin;
}

+ (void)load {
//    DBLoginWindow *plugin = [DBLoginWindow sharedInstance];
    NSUInteger osx_ver = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
    NSLog(@"%@ loaded into %@ on macOS 10.%ld", [self class], [[NSBundle mainBundle] bundleIdentifier], (long)osx_ver);
}


@end

ZKSwizzleInterface(wb_LUIWindowController, LUIWindowController, NSObject)
@implementation wb_LUIWindowController

- (void)setUsesDesktopPicture:(BOOL)arg1 {
    if (db_EnableAnim) {
        ZKOrig(void, false);
        
        NSString *picturePath;
        for (NSString *ext in @[@"jpg", @"png", @"gif"])
            if ([FileManager fileExistsAtPath:[db_LockFile stringByAppendingPathExtension:ext]])
                picturePath = [db_LockFile stringByAppendingPathExtension:ext];
        
        NSWindow *win = [self valueForKey:@"_mainWindow"];
        NSImageView *view = [[NSImageView alloc] initWithFrame:win.contentView.frame];
        NSImage *theImage = [[NSImage alloc] initWithContentsOfFile:picturePath];
        [theImage setSize: NSMakeSize(win.contentView.frame.size.width, win.contentView.frame.size.height)];
        view.image = theImage;
        view.canDrawSubviewsIntoLayer = YES;
        [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        if (db_LockAnim) {
            view.imageScaling = NSImageScaleNone;
            view.animates = YES;
            NSView *layerview = [[NSImageView alloc] initWithFrame:win.contentView.frame];
            layerview.wantsLayer = YES;
            [layerview addSubview:view];
            [layerview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
            [win.contentView setSubviews:@[layerview]];
        } else {
            [win.contentView setSubviews:@[view]];
        }
    } else {
        ZKOrig(void, arg1);
    }
}

@end

ZKSwizzleInterface(wb_LUIGoodSamaritanMessageView, LUIGoodSamaritanMessageView, NSView)
@implementation wb_LUIGoodSamaritanMessageView

- (id)_fontOfSize:(double)arg1 {
    if (db_EnableSize) {
        float lockSize = [db_LockSize floatValue];
        if (lockSize < 0 || lockSize > 64)
            return ZKOrig(id, arg1);
        return ZKOrig(id, lockSize);
    }
    return ZKOrig(id, arg1);
}

- (void)setMessage:(id)arg1 {
    if (db_EnableText) {
        NSString* lockText = db_LockText;
        if ([lockText isEqualToString:@""])
            lockText = @"🍣";
        ZKOrig(void, lockText);
    } else {
        ZKOrig(void, arg1);
    }
}

@end
