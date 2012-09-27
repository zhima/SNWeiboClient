//
//  CommentTableViewCell.h
//  SinaWeiboClient
//
//  Created by Lion User on 25/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
#import "User.h"
@interface CommentTableViewCell : UITableViewCell
-(void)setupCommentCell:(Comment *)comment withAvaterImage:(NSData *)image;
@end
