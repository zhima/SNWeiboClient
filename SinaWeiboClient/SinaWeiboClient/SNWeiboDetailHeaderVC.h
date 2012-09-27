//
//  SNWeiboDetailHeaderVC.h
//  SinaWeiboClient
//
//  Created by Lion User on 23/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "User.h"

@interface SNWeiboDetailHeaderVC : UIViewController
@property (nonatomic,strong) Status *sta;
@property (nonatomic,strong) NSData *avatImage;
@property (nonatomic,strong) NSData *contImage;
@end
