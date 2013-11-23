//
//  PSAppDelegate.m
//  PixivStream
//
//  Created by lifeaether on 2013/11/22.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import "PSAppDelegate.h"
#import "PSApplicationKey.h"
#import "PSTaskScheduler.h"
#import "PSWebRequestMaker.h"
#import "PSScrapper.h"

@implementation PSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Add oberserver to User Defaults
    NSUserDefaults *defautls = [NSUserDefaults standardUserDefaults];
    [defautls addObserver:self forKeyPath:kPSUserDefaultsRefreshIntervalKey options:NSKeyValueObservingOptionNew context:NULL];
    [defautls addObserver:self forKeyPath:kPSUserDefaultsMaxDisplayCountKey options:NSKeyValueObservingOptionNew context:NULL];
    
    // validation user defaults values.

    // update scrapper
    [[PSScrapper sharedScrapper] updateScrapper:^( BOOL isSuccess, NSError *error ) {
        if ( ! isSuccess ) {
            NSLog( @"%@", error );
        }
    }];

    // Begin scheduler
    PSTaskScheduler *scheduler = [self refreshTaskScheduler];
    [scheduler setInterval:[[defautls valueForKey:kPSUserDefaultsRefreshIntervalKey] floatValue]];
    [scheduler executeTask];
    [scheduler beginTask];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Remove observers.
    NSUserDefaults *defautls = [NSUserDefaults standardUserDefaults];
    [defautls removeObserver:self forKeyPath:kPSUserDefaultsRefreshIntervalKey];
    [defautls removeObserver:self forKeyPath:kPSUserDefaultsMaxDisplayCountKey];
    
    // end task.
    [[self streamTaskScheduler] endTask];
    [[self refreshTaskScheduler] endTask];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSUserDefaults *defautls = [NSUserDefaults standardUserDefaults];
    if ( [keyPath isEqualToString:kPSUserDefaultsRefreshIntervalKey] ) {
        [[self refreshTaskScheduler] setInterval:[[defautls valueForKey:kPSUserDefaultsRefreshIntervalKey] floatValue]];
    } else if ( [keyPath isEqualToString:kPSUserDefaultsMaxDisplayCountKey] ) {
    }
}

@end
