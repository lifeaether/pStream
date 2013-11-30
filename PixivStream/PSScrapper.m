//
//  PSScrapper.m
//  PixivStream
//
//  Created by lifeaether on 2013/11/23.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import "PSScrapper.h"
#import "PSApplicationUtility.h"

NSString * const kPSScrapperEncodingKey             = @"encodings";
NSString * const kPSScrapperURLNewURLStringKey      = @"url.new";
NSString * const kPSScrapperURLSearchURLStringKey   = @"url.search";
NSString * const kPSScrapperURLPageURLStringKey     = @"url.page";

NSString * const kPSScrapperNewItemXPathKey             = @"xpath.new.item";
NSString * const kPSScrapperNewItemIdentifierXPathKey   = @"xpath.new.identifier";
NSString * const kPSScrapperNewItemTitleXPathKey        = @"xpath.new.title";
NSString * const kPSScrapperNewItemAuthorXPathKey       = @"xpath.new.author";
NSString * const kPSScrapperNewItemThumbnailXPathKey    = @"xpath.new.thumbnail";

NSString * const kPSScrapperItemIdentifierKey       = @"kPSScrapperItemIdentifierKey";
NSString * const kPSScrapperItemTitleKey            = @"kPSScrapperItemTitleKey";
NSString * const kPSScrapperItemDateKey             = @"kPSScrapperItemDateKey";
NSString * const kPSScrapperItemTagsKey             = @"kPSScrapperItemTagsKey";
NSString * const kPSScrapperItemCaptionKey          = @"kPSScrapperItemCaptionKey";
NSString * const kPSScrapperItemAuthorKey           = @"kPSScrapperItemAuthorKey";
NSString * const kPSScrapperItemSmallImageKey       = @"kPSScrapperItemSmallImageKey";
NSString * const kPSScrapperItemMediumImageKey      = @"kPSScrapperItemMediumImageKey";
NSString * const kPSScrapperItemBigImageKey         = @"kPSScrapperItemBigImageKey";
NSString * const kPSScrapperItemMangaImageKey       = @"kPSScrapperItemMangaImageKey";

@interface PSScrapper ()

@property (nonatomic) NSDictionary *scrapperInfo;

@end

@implementation PSScrapper

+ (instancetype)sharedScrapper
{
    static dispatch_once_t pred;
    static id sharedScrapper = nil;
    dispatch_once( &pred, ^{ sharedScrapper = [[self alloc] init]; } );
    return sharedScrapper;
}

- (NSURL *)newURLAtIndex:(NSInteger)index
{
    NSString *urlString = [self loadObjectValueForKeyPath:kPSScrapperURLNewURLStringKey];
    return [NSURL URLWithString:[NSString stringWithFormat:urlString, index]];
}

- (NSURL *)searchURLWithKeyword:(NSString *)keyword atIndex:(NSInteger)index
{
    NSString *urlString = [self loadObjectValueForKeyPath:kPSScrapperURLSearchURLStringKey];
    return [NSURL URLWithString:[NSString stringWithFormat:urlString, keyword, index]];
}

- (NSURL *)pageURLWithIndentifier:(NSString *)identifier
{
    NSString *urlString = [self loadObjectValueForKeyPath:kPSScrapperURLSearchURLStringKey];
    return [NSURL URLWithString:[NSString stringWithFormat:urlString, identifier]];
}

static NSString * stringValueForXPath( NSXMLElement *node, NSString *xpath, NSError **error )
{
    NSArray *nodes = [node nodesForXPath:xpath error:error];
    if ( [nodes count] > 0 ) {
        return [[nodes firstObject] stringValue];
    } else {
        return nil;
    }
}

static NSString * identifierFromLink( NSString *linkURLString )
{
    NSScanner *scanner = [NSScanner scannerWithString:linkURLString];
    if ( [scanner scanUpToString:@"illust_id=" intoString:nil] ) {
        if ( [scanner scanString:@"illust_id=" intoString:nil] ) {
            NSString *identifier = nil;
            if ( [scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&identifier] ) {
                return identifier;
            }
        }
    }
    return nil;
}

- (PSTaskBlock)scrapNewOfRange:(NSRange)range handler:(PSScrapPageHandler)handler
{
    return ^{
        for ( NSInteger i = range.location; i < NSMaxRange( range ); i++ ) {
            NSURLRequest *request = [NSURLRequest requestWithURL:[self newURLAtIndex:i]];
            NSURLResponse *response = nil;
            NSError *error = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ( htmlString ) {
                NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:htmlString options:NSXMLDocumentTidyHTML error:&error];
                if ( document ) {
                    NSString *xpathForItem = [self loadObjectValueForKeyPath:kPSScrapperNewItemXPathKey];
                    NSError *error = nil;
                    NSArray *itemNodes = [document nodesForXPath:xpathForItem error:&error];
                    for ( id itemNode in itemNodes ) {
                        NSDictionary *item = [NSMutableDictionary dictionary];
                        NSString *title = stringValueForXPath( itemNode, [self loadObjectValueForKeyPath:kPSScrapperNewItemTitleXPathKey], nil );
                        NSString *link = stringValueForXPath( itemNode, [self loadObjectValueForKeyPath:kPSScrapperNewItemIdentifierXPathKey], nil );
                        NSString *author = stringValueForXPath( itemNode, [self loadObjectValueForKeyPath:kPSScrapperNewItemAuthorXPathKey], nil );
                        NSString *thumbnailURL = stringValueForXPath( itemNode, [self loadObjectValueForKeyPath:kPSScrapperNewItemThumbnailXPathKey], nil );
                        [item setValue:title forKey:kPSScrapperItemTitleKey];
                        [item setValue:author forKey:kPSScrapperItemAuthorKey];
                        [item setValue:thumbnailURL forKey:kPSScrapperItemSmallImageKey];
                        [item setValue:identifierFromLink(link) forKey:kPSScrapperItemIdentifierKey];
                        if ( ! handler( item, error ) ) {
                            return;
                        }
                    }
                }
            }
        }
    };
}

- (PSTaskBlock)scrapSearchWithKeyword:(NSArray *)keywords ofRange:(NSRange)range handler:(PSScrapPageHandler)handler
{
    return ^{
    };
}

- (PSTaskBlock)scrapPageWithIdentifier:(NSString *)identifier handler:(PSScrapPageHandler)handler
{
    return ^{
    };
}

- (PSTaskBlock)scrapImageWithIdentifier:(NSString *)identifier handler:(PSScrapImageHandler)handler
{
    return ^{
    };
}

static NSString * const kScrapperInfoURLString = @"http://dev.lifeaether.com/pixivstream/1.0/scrapper.plist";
static NSString * const kApplicationSupportScrapperInfoFileName = @"scrapper.plist";

- (NSURL *)scrapperInfoFileURL
{
    return [PSApplicationSupportDirectory() URLByAppendingPathComponent:kApplicationSupportScrapperInfoFileName];
}

- (void)updateScrapper:(void (^)(BOOL isSuccessful, NSError *error))completeHandler
{
    [[[NSURLSession sharedSession] downloadTaskWithURL:[NSURL URLWithString:kScrapperInfoURLString] completionHandler:
     ^( NSURL *location, NSURLResponse *response, NSError *error ) {
         if ( location ) {
             NSFileManager *fileManager = [NSFileManager defaultManager];
             NSURL *dstURL = [self scrapperInfoFileURL];
             if ( [fileManager fileExistsAtPath:[dstURL path]] ) {
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
        if ( ! info ) {
            NSURL *altURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"scrapper.plist"];
            info = [[NSDictionary alloc] initWithContentsOfURL:altURL];
        }
        [self setScrapperInfo:info];
    }
    
    return [info valueForKeyPath:keyPath];
}

@end
