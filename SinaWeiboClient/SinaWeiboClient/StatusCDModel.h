//
//  StatusCDModel.h
//  SinaWeiboClient
//
//  Created by Lion User on 18/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StatusCDModel, UserCDModel;

@interface StatusCDModel : NSManagedObject

@property (nonatomic, retain) NSString * bmiddlePic;
@property (nonatomic, retain) NSNumber * commentsCount;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * favorited;
@property (nonatomic, retain) NSString * inReplyToScreenName;
@property (nonatomic, retain) NSNumber * inReplyToStatusId;
@property (nonatomic, retain) NSNumber * inReplyToUserId;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * originalPic;
@property (nonatomic, retain) NSNumber * retweetsCount;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * sourceUrl;
@property (nonatomic, retain) NSNumber * statusId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * thumbnailPic;
@property (nonatomic, retain) NSNumber * truncated;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * isHomeLine;
@property (nonatomic, retain) StatusCDModel *retweetedStatus;
@property (nonatomic, retain) UserCDModel *user;

@end
