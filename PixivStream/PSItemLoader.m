//
//  PSItemLoader.m
//  PixivStream
//
//  Created by lifeaether on 2013/11/30.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import "PSItemLoader.h"
#import "PSTaskScheduler.h"
#import "PSScrapper.h"

@interface PSItemLoader ()

@property NSTimer *timer;
@property NSMutableArray *items;
@property (nonatomic) NSString *lastIdentifier;

@end

@implementation PSItemLoader

+ (id)sharedTaskScheduler
{
    static dispatch_once_t pred;
    static id sharedInstance = nil;
    dispatch_once( &pred, ^{
        sharedInstance = [[PSTaskScheduler alloc] init];
        [sharedInstance start];
    } );
    return sharedInstance;
}

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
    if ( [self interval] > 0 && [self maximumItemCount] > 0 ) {
        [self setTimer:[NSTimer scheduledTimerWithTimeInterval:[self interval] target:self selector:@selector(timerFire:) userInfo:nil repeats:YES]];
    }
}

- (void)stop
{
    [[self timer] invalidate];
}

- (void)load
{
    [self loadAtPageIndex:0];
}

- (void)loadAtPageIndex:(NSUInteger)pageIndex
{
    PSScrapper *scrapper = [PSScrapper sharedScrapper];
    PSTaskBlock block = [scrapper scrapNewOfRange:NSMakeRange(pageIndex, 1) handler:^( NSArray *items, NSError *error ) {
        for ( id item in items ) {
            NSUInteger current = [[item valueForKey:kPSScrapperItemIdentifierKey] intValue];
            NSUInteger last = [[self lastIdentifier] intValue];
            if ( current > last ) {
                [self pushItem:item];
            } else {
                return;
            }
        }
        if ( [self numberOfItem] < [self maximumItemCount] ) {
            [self loadAtPageIndex:pageIndex+1];
        }
    }];
    [[PSItemLoader sharedTaskScheduler] addTask:block];
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
        [[self items] addObject:item];
    }
}

- (NSDictionary *)popItem
{
    @synchronized ( self ) {
        if ( [self numberOfItem] > 0 ) {
            NSDictionary *item = [[self items] lastObject];
            [[self items] removeLastObject];
            return item;
        } else {
            return nil;
        }
    }
}

@end
