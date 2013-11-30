//
//  PSAppDelegate.h
//  PixivStream
//
//  Created by lifeaether on 2013/11/22.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PSItemLoader;

@interface PSAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet PSItemLoader *itemLoader;

@end
