//
//  PSWebRequestMaker.m
//  PixivStream
//
//  Created by lifeaether on 2013/11/23.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import "PSWebRequestMaker.h"

static NSString * const kPixivURLNewIllustPage = @"http://www.pixiv.net/new_illust.php?p=%ld";
static NSString * const kPixivURLNewSearchPage = @"http://www.pixiv.net/search.php?s_mode=s_tag&word=&@";
static NSString * const kPixivURLIllustPgae =@"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=%@";


PSTaskBlock MakeNewStreamRequest( NSInteger pageIndex, PSWebRequestCompleteHandler handler )
{
    return ^{
        NSString *urlString = [NSString stringWithFormat:kPixivURLNewIllustPage, (long)pageIndex];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        handler( data, error );
    };
}

PSTaskBlock MakeSearchStreamRequest( NSString *keyword , NSInteger pageIndex, PSWebRequestCompleteHandler handler )
{
    return ^{};
}

PSTaskBlock MakeIllustInformationRequest( NSString *identifier, PSWebRequestCompleteHandler handler )
{
    return ^{};
}

PSTaskBlock MakeIllustThumbnailImageRequest(NSString *identifier, PSWebRequestCompleteHandler handler )
{
    return ^{};
}