//
//  OAthWebViewController.h
//  SinaWeiboClient
//
//  Created by Lion User on 01/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DID_GET_ACCESS_TOKEN    @"DID_GET_ACCESS_TOKEN"

@protocol OAuthorizeDelegate <NSObject>

-(void)didGetAccessToken:(NSString *)token withUid:(NSString *)uid;

@end

@interface OAthWebViewController : UIViewController
@property (nonatomic,strong) id<OAuthorizeDelegate> delegate;
@end
