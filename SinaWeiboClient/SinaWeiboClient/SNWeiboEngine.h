//
//  SNWeiboEngine.h
//  SinaWeiboClient
//
//  Created by Lion User on 13/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAthWebViewController.h"
#import "SNWeiboImageDownload.h"
#import "SNWeiboDefines.h"




@interface SNWeiboEngine : NSObject

+(SNWeiboEngine *)getInstance;
-(void)loginInViewController:(UIViewController *)viewController;

-(void)getImageWithURL:(NSString *)url withIndexnum:(NSInteger)index;
-(void)getImageWithURL:(NSString *)url;
-(BOOL)hasAccessTokenOutOfDate;

-(void)postStatus:(NSString *)text withImage:(UIImage *)image;

-(void)getHomeTimeLineWithCount:(NSInteger)count Page:(NSInteger)page feature:(NSInteger)feature;
-(void)getCommentsToShowWithStatusId:(NSNumber *)statusId Count:(NSInteger)count  Page:(NSInteger)page filter:(NSInteger)filter_by_author;
- (void)getFriendshipsFollowersWithCount:(NSInteger)count cursor:(NSInteger)cursor trim_status:(NSInteger)trimed
;
@end
