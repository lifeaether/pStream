//
//  PSItemLoader.h
//  PixivStream
//
//  Created by lifeaether on 2013/11/30.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSItemLoader : NSObject

@property (nonatomic) NSTimeInterval interval;
@property (nonatomic) NSUInteger maximumItemCount;


- (void)start;
- (void)stop;

- (void)load;

- (NSUInteger)numberOfItem;
- (void)pushItem:(NSDictionary *)item;
- (NSDictionary *)popItem;

@end
