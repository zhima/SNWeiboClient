//
//  StatusTableViewCell.h
//  SinaWeiboClient
//
//  Created by Lion User on 09/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "User.h"
@interface StatusTableViewCell : UITableViewCell
-(void)setupCell:(Status *)status withAvaterImageData:(NSData *)avaterImage withContentImageData:(NSData *)contentImage;
@end
