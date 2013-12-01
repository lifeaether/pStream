//
//  PSConnection.h
//  PixivStream
//
//  Created by lifeaether on 2013/12/01.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSConnection : NSObject

@property (nonatomic) NSTimeInterval interval;
@property (copy, nonatomic) void (^requestHandler)( NSURLRequest *request );

+ (instancetype)sharedConnection;
- (NSData *)sendRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error;


@end
