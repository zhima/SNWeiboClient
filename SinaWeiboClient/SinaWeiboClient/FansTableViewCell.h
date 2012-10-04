//
//  FansTableViewCell.h
//  SinaWeiboClient
//
//  Created by Lion User on 01/10/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"


@interface FansTableViewCell : UITableViewCell
- (void)setupCell:(User *)userInfo withAvaterImageData:(NSData *)imageData;
@end
