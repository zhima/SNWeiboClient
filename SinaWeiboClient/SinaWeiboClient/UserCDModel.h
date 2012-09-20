//
//  UserCDModel.h
//  SinaWeiboClient
//
//  Created by Lion User on 18/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserCDModel : NSManagedObject

@property (nonatomic, retain) NSNumber * allowAllActMsg;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * descriptions;
@property (nonatomic, retain) NSString * domain;
@property (nonatomic, retain) NSNumber * favoritesCount;
@property (nonatomic, retain) NSNumber * followersCount;
@property (nonatomic, retain) NSNumber * following;
@property (nonatomic, retain) NSNumber * friendsCount;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSNumber * geoEnabled;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * profileImageUrl;
@property (nonatomic, retain) NSString * profileLargeImageUrl;
@property (nonatomic, retain) NSString * screenName;
@property (nonatomic, retain) NSNumber * statusesCount;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * verified;

@end
