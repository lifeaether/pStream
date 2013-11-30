//
//  PSAppDelegate.m
//  PixivStream
//
//  Created by lifeaether on 2013/11/22.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import "PSAppDelegate.h"
#import "PSApplicationUtility.h"
#import "PSTaskScheduler.h"
#import "PSScrapper.h"

@implementation PSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // create application support directory
    {
        NSURL *url = PSApplicationSupportDirectory();
        NSFileManager *manager = [NSFileManager defaultManager];
        if ( ! [manager fileExistsAtPath:[url path]] ) {
            NSError *error = nil;
            if ( ! [manager createDirectoryAtURL:url withIntermediateDirectories:NO attributes:nil error:&error] ) {
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert runModal];
            }
        }
    }
    
    // Add oberserver to User Defaults
    {
        NSUserDefaults *defautls = [NSUserDefaults standardUserDefaults];
        [defautls addObserver:self forKeyPath:kPSUserDefaultsRefreshIntervalKey options:NSKeyValueObservingOptionNew context:NULL];
        [defautls addObserver:self forKeyPath:kPSUserDefaultsMaxDisplayCountKey options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    // validation user defaults values.

    // update scrapper
/*    [[PSScrapper sharedScrapper] updateScrapper:^( BOOL isSuccess, NSError *error ) {
        if ( ! isSuccess ) {
            NSLog( @"%@", error );
        }
    }];*/

    // Begin scheduler
/*    {
        NSUserDefaults *defautls = [NSUserDefaults standardUserDefaults];
        PSTaskScheduler *scheduler = [self refreshTaskScheduler];
        [scheduler setInterval:[[defautls valueForKey:kPSUserDefaultsRefreshIntervalKey] floatValue]];
        [scheduler executeTask];
        [scheduler beginTask];
    }*/
    
    //test
    {
        PSTaskBlock block = [[PSScrapper sharedScrapper] scrapNewOfRange:NSMakeRange(0, 1) handler:^( NSDictionary *item, NSError *error ) {
            NSLog( @"%@", item );
            return YES;
        }];
        
        block();
    }
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
