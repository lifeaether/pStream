//
//  PSWebRequestMaker.h
//  PixivStream
//
//  Created by lifeaether on 2013/11/23.
//  Copyright (c) 2013年 lifeaether. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSTaskScheduler.h"

typedef void (^PSWebRequestCompleteHandler)( NSData *data, NSError *error );

PSTaskBlock MakeNewStreamRequest( NSInteger pageIndex, PSWebRequestCompleteHandler handler );
PSTaskBlock MakeSearchStreamRequest( NSString *keyword, NSInteger pageIndex, PSWebRequestCompleteHandler handler );
PSTaskBlock MakeIllustInformationRequest( NSString *identifier, PSWebRequestCompleteHandler handler );
PSTaskBlock MakeIllustThumbnailImageRequest(NSString *identifier, PSWebRequestCompleteHandler handler );

