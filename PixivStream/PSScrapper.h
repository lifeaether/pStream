//
//  PSScrapper.h
//  PixivStream
//
//  Created by lifeaether on 2013/11/23.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSTaskScheduler.h"

extern NSString * const kPSScrapperItemIdentifierKey;
extern NSString * const kPSScrapperItemDateKey;
extern NSString * const kPSScrapperItemTagsKey;
extern NSString * const kPSScrapperItemCaptionKey;
extern NSString * const kPSScrapperItemAuthorKey;
extern NSString * const kPSScrapperItemSmallImageKey;
extern NSString * const kPSScrapperItemMediumImageKey;
extern NSString * const kPSScrapperItemBigImageKey;
extern NSString * const kPSScrapperItemMangaImageKey;

typedef BOOL (^PSScrapPageHandler)( NSDictionary *item, NSError *error );
typedef BOOL (^PSScrapImageHandler)( NSImage *image, NSDictionary *item, NSError *error );

@interface PSScrapper : NSObject

+ (instancetype)sharedScrapper;

- (NSURL *)newURLAtIndex:(NSInteger)index;
- (NSURL *)searchURLWithKeyword:(NSArray *)keywords atIndex:(NSInteger)index;
- (NSURL *)illustPageURLWithIndentifier:(NSString *)identifier;
- (NSURL *)illustImageURLWithIndetifier:(NSString *)identifier;

- (PSTaskBlock)scrapNewOfRange:(NSRange)range handler:(PSScrapPageHandler)handler;
- (PSTaskBlock)scrapSearchWithKeyword:(NSArray *)keywords ofRange:(NSRange)range handler:(PSScrapPageHandler)handler;
- (PSTaskBlock)scrapPageWithIdentifier:(NSString *)identifier handler:(PSScrapPageHandler)handler;
- (PSTaskBlock)scrapImageWithIdentifier:(NSString *)identifier handler:(PSScrapImageHandler)handler;

- (NSURL *)scrapperInfoFileURL;
- (void)updateScrapper:(void (^)(BOOL isSuccessful, NSError *error))completeHandler;
- (id)loadObjectValueForKeyPath:(NSString *)keyPath;

@end
