//
//  UserCDModel+Utils.m
//  SinaWeiboClient
//
//  Created by Lion User on 18/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserCDModel+Utils.h"

@implementation UserCDModel (Utils)

-(void)updateUserCDModelWithUser:(User *)user
{
    self.userId=user.userKey;
    self.username=user.username;
    self.screenName=user.screenName;
    self.name=user.name;
    self.allowAllActMsg=[NSNumber numberWithBool:user.allowAllActMsg];
    self.createdAt=[NSDate dateWithTimeIntervalSince1970:user.createdAt];
    self.descriptions=user.description;
    self.domain=user.domain;
    self.favoritesCount=[NSNumber numberWithInt:user.favoritesCount];
    self.followersCount=[NSNumber numberWithInt:user.followersCount];
    self.friendsCount=[NSNumber numberWithInt:user.friendsCount];
    self.statusesCount=[NSNumber numberWithInt:user.statusesCount];
    self.following=[NSNumber numberWithBool:user.following];
    self.gender=[NSNumber numberWithShort:user.gender];
    self.geoEnabled=[NSNumber numberWithBool:user.geoEnabled];
    self.location=user.location;
    self.profileImageUrl=user.profileImageUrl;
    self.profileLargeImageUrl=user.profileLargeImageUrl;
    self.url=user.url;
    self.verified=[NSNumber numberWithBool:user.verified];
}

@end
