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
extern NSString * const kPSScrapperItemTitleKey;
extern NSString * const kPSScrapperItemDateKey;
extern NSString * const kPSScrapperItemTagsKey;
extern NSString * const kPSScrapperItemCaptionKey;
extern NSString * const kPSScrapperItemAuthorKey;
extern NSString * const kPSScrapperItemAuthorImageKey;
extern NSString * const kPSScrapperItemViewKey;
extern NSString * const kPSScrapperItemVoteKey;
extern NSString * const kPSScrapperItemPointKey;
extern NSString * const kPSScrapperItemSmallImageKey;
extern NSString * const kPSScrapperItemMediumImageKey;
extern NSString * const kPSScrapperItemBigImageKey;
extern NSString * const kPSScrapperItemMangaImageKey;

typedef void (^PSScrapNewHandler)( NSArray *items, NSError *error );
typedef void (^PSScrapSearchHandler)( NSArray *items, NSError *error );
typedef void (^PSScrapPageHandler)( NSDictionary *item, NSError *error );
typedef void (^PSScrapImageHandler)( NSImage *image, NSDictionary *item, NSError *error );

typedef NS_ENUM( NSInteger, PSScrapResult ) {
    PSScrapResultOK,
    PSScrapResultError,
    PSScrapResultNotLoggin,
};

@interface PSScrapper : NSObject

+ (instancetype)sharedScrapper;

- (NSURL *)newURLAtIndex:(NSInteger)index;
- (NSURL *)searchURLWithKeyword:(NSString *)keyword atIndex:(NSInteger)index;
- (NSURL *)pageURLWithIndentifier:(NSString *)identifier;

- (PSTaskBlock)scrapNewToIdentifier:(NSString *)identifier count:(NSInteger)itemCount handler:(PSScrapNewHandler)handler;
- (PSTaskBlock)scrapSearchWithKeyword:(NSString *)keywords toIdentifier:(NSString *)toIdentifier count:(NSInteger)itemCount handler:(PSScrapSearchHandler)handler;
- (PSTaskBlock)scrapPageWithIdentifier:(NSString *)identifier handler:(PSScrapPageHandler)handler;
- (PSTaskBlock)scrapImageWithIdentifier:(NSString *)identifier handler:(PSScrapImageHandler)handler;

- (PSScrapResult)validateDocument:(NSXMLDocument *)document;

- (NSURL *)scrapperInfoFileURL;
- (void)updateScrapper:(void (^)(BOOL isSuccessful, NSError *error))completeHandler;
- (id)loadObjectValueForKeyPath:(NSString *)keyPath;

@end
