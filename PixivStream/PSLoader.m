//
//  PSItemLoader.m
//  PixivStream
//
//  Created by lifeaether on 2013/11/30.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import "PSLoader.h"
#import "PSScrapper.h"

@interface PSLoader ()

@property NSTimer *timer;
@property NSMutableArray *items;
@property (nonatomic) NSString *lastIdentifier;

@end

@implementation PSLoader

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        [self setItems:[NSMutableArray array]];
        [self setInterval:0];
        [self setMaximumItemCount:0];
    }
    return self;
}

- (void)start
{
    if ( [self interval] > 0 && [self maximumItemCount] > 0 && ! [self timer] ) {
        [self setTimer:[NSTimer scheduledTimerWithTimeInterval:[self interval] target:self selector:@selector(timerFire:) userInfo:nil repeats:YES]];
        [self load];
    }
}

- (void)stop
{
    [[self timer] invalidate];
    [self setTimer:nil];
}

- (void)load
{
    NSArray *items = [[PSScrapper sharedScrapper] scrapNewToIdentifier:[self lastIdentifier] count:[self maximumItemCount]];
    for ( id item in items ) {
        [self pushItem:item];
    }
    if ( [items count] > 0 ) {
        [self setLastIdentifier:[[items firstObject] valueForKey:kPSScrapperItemIdentifierKey]];
    }
}

- (void)timerFire:(NSTimer *)timer
{
    [self load];
}
             
- (NSUInteger)numberOfItem
{
    @synchronized ( self ) {
        return [[self items] count];
    }
}

- (void)pushItem:(NSDictionary *)item
{
    @synchronized ( self ) {
        [[self items] insertObject:item atIndex:0];
    }
}

- (NSDictionary *)popItem
{
    @synchronized ( self ) {
        if ( [self numberOfItem] > 0 ) {
            NSDictionary *item = [[self items] firstObject];
            [[self items] removeObjectAtIndex:0];
            return item;
        } else {
            return nil;
        }
    }
}

@end
