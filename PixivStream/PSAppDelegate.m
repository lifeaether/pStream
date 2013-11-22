//
//  PSAppDelegate.m
//  PixivStream
//
//  Created by lifeaether on 2013/11/22.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import "PSAppDelegate.h"
#import "PSApplicationKey.h"

@implementation PSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Add oberserver to User Defaults
    NSUserDefaults *defautls = [NSUserDefaults standardUserDefaults];
    [defautls addObserver:self forKeyPath:kPSUserDefaultsRefreshIntervalKey options:NSKeyValueObservingOptionNew context:NULL];
    [defautls addObserver:self forKeyPath:kPSUserDefaultsMaxDisplayCountKey options:NSKeyValueObservingOptionNew context:NULL];
    
    // Begin scheduler
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Remove observers.
    NSUserDefaults *defautls = [NSUserDefaults standardUserDefaults];
    [defautls removeObserver:self forKeyPath:kPSUserDefaultsRefreshIntervalKey];
    [defautls removeObserver:self forKeyPath:kPSUserDefaultsMaxDisplayCountKey];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( [keyPath isEqualToString:kPSUserDefaultsRefreshIntervalKey] ) {
    } else if ( [keyPath isEqualToString:kPSUserDefaultsMaxDisplayCountKey] ) {
    }
}

@end
