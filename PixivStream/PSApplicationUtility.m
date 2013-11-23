//
//  PSApplicationUtility.m
//  PixivStream
//
//  Created by lifeaether on 2013/11/22.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import "PSApplicationUtility.h"

NSString * const kPSApplicationName = @"PixivStream";

NSString * const kPSUserDefaultsRefreshIntervalKey = @"refreshInterval";
NSString * const kPSUserDefaultsMaxDisplayCountKey = @"displayCount";

NSURL * PSApplicationSupportDirectory()
{
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    if ( [urls count] > 0 ) {
        return [[urls firstObject] URLByAppendingPathComponent:kPSApplicationName];
    } else {
        return nil;
    }
}