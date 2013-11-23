//
//  PSScrapper.m
//  PixivStream
//
//  Created by lifeaether on 2013/11/23.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import "PSScrapper.h"

@interface PSScrapper ()

@property NSDictionary *scrapperInfo;

@end

@implementation PSScrapper

+ (instancetype)sharedScrapper
{
    static dispatch_once_t pred;
    static id sharedScrapper = nil;
    dispatch_once( &pred, ^{ sharedScrapper = [[self alloc] init]; } );
    return sharedScrapper;
}
/*
- (NSURL *)newURLAtIndex:(NSInteger)index
{
}

- (NSURL *)searchURLWithKeyword:(NSArray *)keywords atIndex:(NSInteger)index
{
}

- (NSURL *)illustPageURLWithIndentifier:(NSString *)identifier
{
}

- (NSURL *)illustImageURLWithIndetifier:(NSString *)identifier
{
}

- (PSTaskBlock)scrapNewOfRange:(NSRange)range handler:(PSScrapPageHandler)handler
{
}

- (PSTaskBlock)scrapSearchWithKeyword:(NSArray *)keywords ofRange:(NSRange)range handler:(PSScrapPageHandler)handler
{
}

- (PSTaskBlock)scrapPageWithIdentifier:(NSString *)identifier handler:(PSScrapPageHandler)handler
{
}

- (PSTaskBlock)scrapImageWithIdentifier:(NSString *)identifier handler:(PSScrapImageHandler)handler
{
}
*/
static NSString * const kScrapperInfoURLString = @"http://dev.lifeaether.com/api/pixivstream/1.0/scrapper.plist";
static NSString * const kApplicationSupportDirectoryName = @"PixivStream";
static NSString * const kApplicationSupportScrapperInfoFileName = @"scrapper.plist";

- (NSURL *)scrapperInfoFileURL
{
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    if ( [urls count] > 0 ) {
        return [[urls firstObject] URLByAppendingPathComponent:kApplicationSupportScrapperInfoFileName];
    } else {
        return nil;
    }
}

- (void)updateScrapper:(void (^)(BOOL isSuccessful, NSError *error))completeHandler
{
    [[[NSURLSession sharedSession] downloadTaskWithURL:[NSURL URLWithString:kScrapperInfoURLString] completionHandler:
     ^( NSURL *location, NSURLResponse *response, NSError *error ) {
         if ( location ) {
             NSFileManager *fileManager = [NSFileManager defaultManager];
             NSURL *dstURL = [self scrapperInfoFileURL];
             if ( [fileManager fileExistsAtPath:[dstURL absoluteString]] ) {
                 if ( ! [fileManager removeItemAtURL:dstURL error:&error] ) {
                     completeHandler( NO, error );
                     return;
                 }
             }
             if ( [[NSFileManager defaultManager] moveItemAtURL:location toURL:[self scrapperInfoFileURL] error:&error] ) {
                 [self setScrapperInfo:nil];
                 completeHandler( YES, nil );
             } else {
                 completeHandler( NO, error );
             }
         } else {
             completeHandler( NO, error );
         }
     }] resume];
}

- (id)loadObjectValueForKeyPath:(NSString *)keyPath
{
    NSDictionary *info = [self scrapperInfo];
    if ( ! info ) {
         info = [[NSDictionary alloc] initWithContentsOfURL:[self scrapperInfoFileURL]];
         [self setScrapperInfo:info];
    }
    
    return [info valueForKeyPath:keyPath];
}

@end
