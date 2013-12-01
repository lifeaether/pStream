//
//  PSConnection.m
//  PixivStream
//
//  Created by lifeaether on 2013/12/01.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import "PSConnection.h"

@interface PSConnection ()

@property (nonatomic) NSDate *lastRequestDate;

@end

@implementation PSConnection

+ (id)sharedConnection
{
    static dispatch_once_t pred;
    static id sharedInstance = nil;
    dispatch_once( &pred, ^{
        sharedInstance = [[self alloc] init];
    } );
    return sharedInstance;
}

- (NSData *)sendRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error
{
    @synchronized ( self ) {
        NSTimeInterval wait = [[[self lastRequestDate] dateByAddingTimeInterval:[self interval]] timeIntervalSinceNow];
        if ( wait > 0 ) {
            [NSThread sleepForTimeInterval:wait];
        }
        if ( [self requestHandler] ) {
            [self requestHandler]( request );
        }
        [self setLastRequestDate:[NSDate date]];
        return [NSURLConnection sendSynchronousRequest:request returningResponse:response error:error];
    }
}


@end
