//
//  PSTaskScheduler.m
//  PixivStream
//
//  Created by lifeaether on 2013/11/23.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import "PSTaskScheduler.h"

@interface PSTaskScheduler ()

@property NSMutableArray *taskQueue;
@property NSTimer *timer;

@end

@implementation PSTaskScheduler

- (void)addTask:(void (^)(void))taskBlock
{
    [[self taskQueue] addObject:taskBlock];
}

- (void)beginTask
{
    [self setTimer:[NSTimer timerWithTimeInterval:[self interval] target:self selector:@selector(timerFire:) userInfo:NULL repeats:YES]];
}

- (void)endTask
{
    [[self timer] invalidate];
    [self setTimer:nil];
}

- (void)timerFire:(NSTimer *)timer
{
    NSMutableArray *taskQueue = [self taskQueue];
    if ( taskQueue ) {
        void (^task)(void) = [taskQueue firstObject];
        task();
        [taskQueue removeObjectAtIndex:0];
    }
}

@end
