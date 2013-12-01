//
//  PSStream.m
//  PixivStream
//
//  Created by lifeaether on 2013/11/30.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import "PSStream.h"
#import "PSLoader.h"
#import "PSScrapper.h"

@interface PSStream ()

@property NSTimer *timer;
@property PSLoader *loader;

@property id waitingItem;

@end

@implementation PSStream

- (id)init
{
    self = [super init];
    if ( self ) {
        [self setLoader:[[PSLoader alloc] init]];
    }
    return self;
}

- (void)start
{
    if ( ! [self isRunning] && [self interval] > 0 && [self maximumCount] > 0 ) {
        [self setTimer:[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timeFire:) userInfo:nil repeats:YES]];
        [[self loader] setInterval:[self interval]];
        [[self loader] setMaximumItemCount:[self maximumCount]];
        [[self loader] start];
    }
}

- (void)stop
{
    [[self timer] invalidate];
    [self setTimer:nil];
    [[self loader] stop];
}

- (BOOL)isRunning
{
    return [self timer] != nil;
}

- (void)timeFire:(NSTimer *)timer
{
    id item = [self waitingItem];
    if ( ! item ) {
        PSLoader *loader = [self loader];
        if ( [loader numberOfItem] > 0 ) {
            item = [loader popItem];
            NSDictionary *info = [[PSScrapper sharedScrapper] scrapPageWithIdentifier:[item valueForKey:kPSScrapperItemIdentifierKey]];
            [item addEntriesFromDictionary:info];
            [self setWaitingItem:item];
        }
    }
    
    if ( item ) {
        NSDate *date = [NSDate dateWithNaturalLanguageString:[item valueForKey:kPSScrapperItemDateKey]];
        if ( ! date || [[NSDate date] compare:[date dateByAddingTimeInterval:[self interval]]] == NSOrderedDescending ) {
            if ( [self receiveItemHandler] ) {
                [self receiveItemHandler]( item );
            }
            [self setWaitingItem:nil];
        }
    }
    
    NSLog( @"PSStream queue: %ld", [[self loader] numberOfItem] );
}

@end
