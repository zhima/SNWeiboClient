//
//  SNWeiboHttpManager.h
//  SinaWeiboClient
//
//  Created by Lion User on 01/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNWeiboDefines.h"





@protocol SNWeiboHttpManagerDelegate <NSObject>

-(void)didGetHomeTimeLine:(NSMutableArray *)statusArr;
-(void)didGetCommentsToShow:(NSMutableArray *)commentsArr;
-(void)didGetResponseError:(NSDictionary *)responseError;

-(void)didSucceedPostUpdate;

-(void)didSucceedPostUpload;
-(void)didGetFriendshipsFollowers:(NSMutableArray *)followersArr;
@end


@interface SNWeiboHttpManager : NSObject

@property (nonatomic,strong) id<SNWeiboHttpManagerDelegate> delegate;


+(SNWeiboHttpManager *)getInstance;
-(NSURL *)generateUrl:(NSString *)baseurl withParams:(NSDictionary *)params;
-(void)getUrlReturnValue:(NSString *)url;

-(void)getHomeTimeLineWithCount:(NSInteger)count Page:(NSInteger)page feature:(NSInteger)feature;
-(void)getCommentsToShowWithStatusId:(NSNumber *)statusId Count:(NSInteger)count  Page:(NSInteger)page filter:(NSInteger)filter_by_author;
- (void)getFriendshipsFollowersWithCount:(NSInteger)count cursor:(NSInteger)cursor trim_status:(NSInteger)trimed
;

-(void)postStatus:(NSString *)text;
-(void)postStatus:(NSString *)text withImage:(UIImage *)image;
@end
