//
//  StatusCDModel+Utils.m
//  SinaWeiboClient
//
//  Created by Lion User on 18/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatusCDModel+Utils.h"
#import "SNWeiboCoreDataManager.h"
#import "UserCDModel+Utils.h"

@implementation StatusCDModel (Utils)
-(void)updateStatusCDModelWithStatus:(Status *)status withIndex:(NSInteger)index isHomeLine:(BOOL)isHomeLine
{
    self.statusId=status.statusKey;
    self.createdAt=[NSDate dateWithTimeIntervalSince1970:status.createdAt];
    self.text=status.text;
    self.source=status.source;
    self.sourceUrl=status.sourceUrl;
    self.favorited=[NSNumber numberWithBool:status.favorited];
    self.truncated=[NSNumber numberWithBool:status.truncated];
    self.thumbnailPic=status.thumbnailPic;
    self.bmiddlePic=status.bmiddlePic;
    self.originalPic=status.originalPic;
    self.latitude=[NSNumber numberWithDouble:status.latitude];
    self.longitude=[NSNumber numberWithDouble:status.longitude];
    self.inReplyToUserId=[NSNumber numberWithInt:status.inReplyToUserId];
    self.inReplyToStatusId=[NSNumber numberWithLongLong:status.inReplyToStatusId];
    self.inReplyToScreenName=status.inReplyToScreenName;
    self.commentsCount=[NSNumber numberWithInt:status.commentsCount];
    self.retweetsCount=[NSNumber numberWithInt:status.retweetsCount];
    self.index=[NSNumber numberWithInteger:index];
    self.isHomeLine=[NSNumber numberWithBool:isHomeLine];
    self.user=[NSEntityDescription insertNewObjectForEntityForName:@"UserCDModel" inManagedObjectContext:[SNWeiboCoreDataManager getInstance].managedContext];
    [self.user updateUserCDModelWithUser:status.user];
    
}
@end
