//
//  PSStream.h
//  PixivStream
//
//  Created by lifeaether on 2013/11/30.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSStream : NSObject

@property (nonatomic) NSTimeInterval interval;
@property (nonatomic) NSInteger maximumCount;
@property (nonatomic) NSString *keyword;
@property (copy) void (^receiveItemHandler)( NSDictionary *item );
@property (copy) void (^receiveErrorHandler)( NSError *error );

- (void)start;
- (void)stop;
- (BOOL)isRunning;

@end
