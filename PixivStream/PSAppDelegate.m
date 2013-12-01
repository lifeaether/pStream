//
//  PSAppDelegate.m
//  PixivStream
//
//  Created by lifeaether on 2013/11/22.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import "PSAppDelegate.h"
#import "PSApplicationUtility.h"
#import "PSScrapper.h"
#import "PSStream.h"
#import "PSConnection.h"

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
    
    // configure conneciton
    {
        PSConnection *connection = [PSConnection sharedConnection];
        [connection setInterval:1.0];
        [connection setRequestHandler:^( NSURLRequest *request ) {
            NSLog( @"%@", request );
        }];
    }

    [[self stream] setReceiveItemHandler:^( NSDictionary *item ) {
        NSLog( @"%@", [item valueForKey:kPSScrapperItemDateKey] );
        NSLog( @"%@ %@", [item valueForKey:kPSScrapperItemIdentifierKey], [item valueForKey:kPSScrapperItemTitleKey] );
        NSMutableDictionary *content = [NSMutableDictionary dictionary];
        [content setValue:[item valueForKey:kPSScrapperItemTitleKey] forKey:@"title"];
        [content setValue:[item valueForKey:kPSScrapperItemAuthorKey] forKey:@"author"];
        [content setValue:[item valueForKey:kPSScrapperItemDateKey] forKey:@"date"];
        [content setValue:[item valueForKey:kPSScrapperItemCaptionKey] forKey:@"caption"];
        [content setValue:[item valueForKey:kPSScrapperItemIdentifierKey] forKey:@"identifier"];
        
        {
            NSString *tagString = @"";
            for ( NSString *tag in [item valueForKey:kPSScrapperItemTagsKey] ) {
                tagString = [tagString stringByAppendingFormat:@"%@ ", tag];
            }
            [content setValue:tagString forKey:@"tags"];
        }
        
        {
            NSURL *url = [NSURL URLWithString:[item valueForKey:kPSScrapperItemSmallImageKey]];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setValue:[[[PSScrapper sharedScrapper] pageURLWithIndentifier:[item valueForKey:kPSScrapperItemIdentifierKey]] absoluteString] forHTTPHeaderField:@"Referer"];
            NSURLResponse *response = nil;
            NSError *error = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSImage *image = [[NSImage alloc] initWithData:data];
            [content setValue:image forKey:@"image"];
        }
        
        NSArrayController *itemsController = [self itemsController];
        [itemsController insertObject:content atArrangedObjectIndex:0];
    }];
    
    [[self stream] setMaximumCount:59];
    [[self stream] setInterval:60*3];
    [[self stream] start];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [[self stream] stop];
    
    // Remove observers.
    NSUserDefaults *defautls = [NSUserDefaults standardUserDefaults];
    [defautls removeObserver:self forKeyPath:kPSUserDefaultsRefreshIntervalKey];
    [defautls removeObserver:self forKeyPath:kPSUserDefaultsMaxDisplayCountKey];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSUserDefaults *defautls = [NSUserDefaults standardUserDefaults];
    if ( [keyPath isEqualToString:kPSUserDefaultsRefreshIntervalKey] ) {
    } else if ( [keyPath isEqualToString:kPSUserDefaultsMaxDisplayCountKey] ) {
    }
}


- (IBAction)openItem:(id)sender
{
    NSString *identifier = [sender title];
    NSURL *url = [[PSScrapper sharedScrapper] pageURLWithIndentifier:identifier];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

@end
