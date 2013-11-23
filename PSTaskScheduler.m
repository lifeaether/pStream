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

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        [self setTaskQueue:[NSMutableArray array]];
    }
    return self;
}

- (void)addTask:(PSTaskBlock)taskBlock
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

- (BOOL)isBegining
{
    return [self timer] != nil;
}

- (void)executeTask
{
    NSMutableArray *taskQueue = [self taskQueue];
    if ( taskQueue ) {
        PSTaskBlock task = [taskQueue firstObject];
        task(); // execute on detach thread.
        [taskQueue removeObjectAtIndex:0];
    }
}

- (void)timerFire:(NSTimer *)timer
{
    [self executeTask];
}

- (void)setInterval:(NSTimeInterval)interval
{
    [self endTask];
    _interval = interval;
    [self beginTask];
}

@end
