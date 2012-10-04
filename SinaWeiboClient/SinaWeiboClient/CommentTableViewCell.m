//
//  CommentTableViewCell.m
//  SinaWeiboClient
//
//  Created by Lion User on 25/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommentTableViewCell.h"


@interface CommentTableViewCell ()
@property (nonatomic,weak) IBOutlet UIImageView *avaterImage;
@property (nonatomic,weak) IBOutlet UILabel *nameLB;
@property (nonatomic,weak) IBOutlet UILabel *timeLB;
@property (nonatomic,weak) IBOutlet UILabel *textLB;
@end

@implementation CommentTableViewCell

@synthesize avaterImage = _avaterImage;
@synthesize nameLB = _nameLB;
@synthesize timeLB = _timeLB;
@synthesize textLB = _textLB;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)setupCommentCell:(Comment *)comment withAvaterImage:(NSData *)image
{
    if (image) {
        self.avaterImage.image=[UIImage imageWithData:image];
    }
    self.timeLB.text=comment.timestamp;
    self.nameLB.text=comment.user.screenName;
    
    self.textLB.text=comment.text;
    
    CGSize size=[self.textLB.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(230, MAXFLOAT) lineBreakMode:UILineBreakModeCharacterWrap];
    CGRect frame=self.textLB.frame;
    frame.size.height=size.height;
    self.textLB.frame=frame;
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
