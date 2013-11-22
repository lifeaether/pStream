//
//  PSTaskScheduler.h
//  PixivStream
//
//  Created by lifeaether on 2013/11/23.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSTaskScheduler : NSObject

@property NSTimeInterval interval;

- (void)addTask:(void (^)(void))taskBlock;

- (void)beginTask;
- (void)endTask;


@end
