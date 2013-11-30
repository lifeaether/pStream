//
//  PSScrapper.m
//  PixivStream
//
//  Created by lifeaether on 2013/11/23.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import "PSScrapper.h"
#import "PSApplicationUtility.h"

static NSString * const kPSScrapperURLNewURLStringKey      = @"url.new";
static NSString * const kPSScrapperURLSearchURLStringKey   = @"url.search";
static NSString * const kPSScrapperURLPageURLStringKey     = @"url.page";

static NSString * const kPSScrapperNewItemXPathKey             = @"xpath.new.item";
static NSString * const kPSScrapperNewItemIdentifierXPathKey   = @"xpath.new.identifier";
static NSString * const kPSScrapperNewItemTitleXPathKey        = @"xpath.new.title";
static NSString * const kPSScrapperNewItemAuthorXPathKey       = @"xpath.new.author";
static NSString * const kPSScrapperNewItemThumbnailXPathKey    = @"xpath.new.thumbnail";

static NSString * const kPSScrapperSearchItemXPathKey             = @"xpath.search.item";
static NSString * const kPSScrapperSearchItemIdentifierXPathKey   = @"xpath.search.identifier";
static NSString * const kPSScrapperSearchItemTitleXPathKey        = @"xpath.search.title";
static NSString * const kPSScrapperSearchItemAuthorXPathKey       = @"xpath.search.author";
static NSString * const kPSScrapperSearchItemThumbnailXPathKey    = @"xpath.search.thumbnail";

static NSString * const kPSScrapperPageAuthorIdentifierXPathKey     = @"xpath.page.author-identifier";
static NSString * const kPSScrapperPageAuthorNameXPathKey           = @"xpath.page.author-name";
static NSString * const kPSScrapperPageAuthorImagePathKey           = @"xpath.page.author-image";
static NSString * const kPSScrapperPageDateXPathKey                 = @"xpath.page.date";
static NSString * const kPSScrapperPageViewXPathKey                 = @"xpath.page.view";
static NSString * const kPSScrapperPageVoteXPathKey                 = @"xpath.page.vote";
static NSString * const kPSScrapperPagePointXPathKey                = @"xpath.page.point";
static NSString * const kPSScrapperPageTitleXPathKey                = @"xpath.page.title";
static NSString * const kPSScrapperPageCaptionXPathKey              = @"xpath.page.caption";
static NSString * const kPSScrapperPageTagsXPathKey                 = @"xpath.page.tags";
static NSString * const kPSScrapperPageTagXPathKey                  = @"xpath.page.tag";
static NSString * const kPSScrapperPageImageXPathKey                = @"xpath.page.image";
static NSString * const kPSScrapperPageBigImageXPathKey             = @"xpath.page.image-big";

NSString * const kPSScrapperItemIdentifierKey       = @"kPSScrapperItemIdentifierKey";
NSString * const kPSScrapperItemTitleKey            = @"kPSScrapperItemTitleKey";
NSString * const kPSScrapperItemDateKey             = @"kPSScrapperItemDateKey";
NSString * const kPSScrapperItemTagsKey             = @"kPSScrapperItemTagsKey";
NSString * const kPSScrapperItemCaptionKey          = @"kPSScrapperItemCaptionKey";
NSString * const kPSScrapperItemAuthorKey           = @"kPSScrapperItemAuthorKey";
NSString * const kPSScrapperItemAuthorImageKey      = @"kPSScrapperItemAuthorImageKey";
NSString * const kPSScrapperItemViewKey             = @"kPSScrapperItemViewKey";
NSString * const kPSScrapperItemVoteKey             = @"kPSScrapperItemVoteKey";
NSString * const kPSScrapperItemPointKey            = @"kPSScrapperItemPointKey";
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
    NSString *urlString = [self loadObjectValueForKeyPath:kPSScrapperURLPageURLStringKey];
    return [NSURL URLWithString:[NSString stringWithFormat:urlString, identifier]];
}

static NSString * stringValueForXPath( NSXMLNode *node, NSString *xpath, NSError **error )
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
                if ( [self validateDocument:document] == PSScrapResultOK ) {
                    NSString *xpathForItem = [self loadObjectValueForKeyPath:kPSScrapperSearchItemXPathKey];
                    NSError *error = nil;
                    NSArray *itemNodes = [document nodesForXPath:xpathForItem error:&error];
                    for ( id itemNode in itemNodes ) {
                        NSDictionary *item = [NSMutableDictionary dictionary];
                        NSString *title = stringValueForXPath( itemNode, [self loadObjectValueForKeyPath:kPSScrapperSearchItemTitleXPathKey], nil );
                        NSString *link = stringValueForXPath( itemNode, [self loadObjectValueForKeyPath:kPSScrapperSearchItemIdentifierXPathKey], nil );
                        NSString *author = stringValueForXPath( itemNode, [self loadObjectValueForKeyPath:kPSScrapperSearchItemAuthorXPathKey], nil );
                        NSString *thumbnailURL = stringValueForXPath( itemNode, [self loadObjectValueForKeyPath:kPSScrapperSearchItemThumbnailXPathKey], nil );
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

- (PSTaskBlock)scrapSearchWithKeyword:(NSString *)keywords ofRange:(NSRange)range handler:(PSScrapPageHandler)handler
{
    return ^{
        for ( NSInteger i = range.location; i < NSMaxRange( range ); i++ ) {
            NSURLRequest *request = [NSURLRequest requestWithURL:[self searchURLWithKeyword:keywords atIndex:i]];
            NSURLResponse *response = nil;
            NSError *error = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ( htmlString ) {
                NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:htmlString options:NSXMLDocumentTidyHTML error:&error];
                if ( [self validateDocument:document] == PSScrapResultOK ) {
                    NSString *xpathForItem = [self loadObjectValueForKeyPath:kPSScrapperNewItemXPathKey];
                    NSError *error = nil;
                    NSArray *itemNodes = [document nodesForXPath:xpathForItem error:&error];
                    for ( id itemNode in itemNodes ) {
                        NSString *title = stringValueForXPath( itemNode, [self loadObjectValueForKeyPath:kPSScrapperNewItemTitleXPathKey], nil );
                        NSString *link = stringValueForXPath( itemNode, [self loadObjectValueForKeyPath:kPSScrapperNewItemIdentifierXPathKey], nil );
                        NSString *author = stringValueForXPath( itemNode, [self loadObjectValueForKeyPath:kPSScrapperNewItemAuthorXPathKey], nil );
                        NSString *thumbnailURL = stringValueForXPath( itemNode, [self loadObjectValueForKeyPath:kPSScrapperNewItemThumbnailXPathKey], nil );
                        NSDictionary *item = [NSMutableDictionary dictionary];
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

static NSArray * tagsFromXMLNode( NSXMLNode *root, NSString *xpathForTags )
{
    NSArray *nodes = [root nodesForXPath:xpathForTags error:nil];
    if ( nodes ) {
        NSMutableArray *tags = [NSMutableArray array];
        for ( NSXMLNode *node in nodes ) {
            [tags addObject:[node stringValue]];
        }
        return tags;
    } else {
        return nil;
    }
}

static NSString * authorIdentifierFromURLString( NSString *urlString )
{
    NSScanner *scanner = [NSScanner scannerWithString:urlString];
    if ( [scanner scanUpToString:@"id=" intoString:nil] ) {
        if ( [scanner scanString:@"id=" intoString:nil] ) {
            NSString *identifier = nil;
            if ( [scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&identifier] ) {
                return identifier;
            }
        }
    }
    return nil;
}

- (PSTaskBlock)scrapPageWithIdentifier:(NSString *)identifier handler:(PSScrapPageHandler)handler
{
    return ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:[self pageURLWithIndentifier:identifier]];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:htmlString options:NSXMLDocumentTidyHTML error:&error];
        if ( [self validateDocument:document] == PSScrapResultOK ) {
            NSString *author_identifier = stringValueForXPath( document, [self loadObjectValueForKeyPath:kPSScrapperPageAuthorIdentifierXPathKey], nil );
            NSString *author_name = stringValueForXPath( document, [self loadObjectValueForKeyPath:kPSScrapperPageAuthorNameXPathKey], nil );
            NSString *author_image = stringValueForXPath( document, [self loadObjectValueForKeyPath:kPSScrapperPageAuthorImagePathKey], nil );
            NSString *date = stringValueForXPath( document, [self loadObjectValueForKeyPath:kPSScrapperPageDateXPathKey], nil );
            NSString *view = stringValueForXPath( document, [self loadObjectValueForKeyPath:kPSScrapperPageViewXPathKey], nil );
            NSString *vote = stringValueForXPath( document, [self loadObjectValueForKeyPath:kPSScrapperPageVoteXPathKey], nil );
            NSString *point = stringValueForXPath( document, [self loadObjectValueForKeyPath:kPSScrapperPagePointXPathKey], nil );
            NSString *title = stringValueForXPath( document, [self loadObjectValueForKeyPath:kPSScrapperPageTitleXPathKey], nil );
            NSString *caption = stringValueForXPath( document, [self loadObjectValueForKeyPath:kPSScrapperPageCaptionXPathKey], nil );
            NSString *image = stringValueForXPath( document, [self loadObjectValueForKeyPath:kPSScrapperPageImageXPathKey], nil );
            NSArray *tags = tagsFromXMLNode( document, [self loadObjectValueForKeyPath:kPSScrapperPageTagsXPathKey] );
            
            NSMutableDictionary *item = [NSMutableDictionary dictionary];
            [item setValue:authorIdentifierFromURLString(author_identifier) forKey:kPSScrapperItemAuthorKey];
            [item setValue:author_name forKey:kPSScrapperItemAuthorKey];
            [item setValue:author_image forKey:kPSScrapperItemAuthorImageKey];
            [item setValue:date forKey:kPSScrapperItemDateKey];
            [item setValue:view forKey:kPSScrapperItemViewKey];
            [item setValue:vote forKey:kPSScrapperItemVoteKey];
            [item setValue:point forKey:kPSScrapperItemPointKey];
            [item setValue:title forKey:kPSScrapperItemTitleKey];
            [item setValue:caption forKey:kPSScrapperItemCaptionKey];
            [item setValue:image forKey:kPSScrapperItemMediumImageKey];
            [item setValue:tags forKey:kPSScrapperItemTagsKey];
            
            if ( ! handler( item, error ) ) {
                return;
            }
        }
    };
}

- (PSTaskBlock)scrapImageWithIdentifier:(NSString *)identifier handler:(PSScrapImageHandler)handler
{
    return ^{
    };
}

- (PSScrapResult)validateDocument:(NSXMLDocument *)document
{
    if ( ! document ) return PSScrapResultError;
    
    return PSScrapResultOK;
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
