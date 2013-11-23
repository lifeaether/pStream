//
//  PSTaskScheduler.h
//  PixivStream
//
//  Created by lifeaether on 2013/11/23.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PSTaskBlock)(void);

@interface PSTaskScheduler : NSObject

@property (nonatomic) NSTimeInterval interval;

- (void)addTask:(PSTaskBlock)taskBlock;

- (void)beginTask;
- (void)endTask;
- (BOOL)isBegining;

- (void)executeTask;

@end
