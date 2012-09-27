//
//  SNWeiboDetailViewController.h
//  SinaWeiboClient
//
//  Created by Lion User on 23/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "User.h"


@interface SNWeiboDetailViewController : UITableViewController
@property (nonatomic,strong) Status *status;
@property (nonatomic,strong) NSData *avaterImageData;
@property (nonatomic,strong) NSData *contentImageData;
@end
