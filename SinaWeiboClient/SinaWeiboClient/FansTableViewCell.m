//
//  FansTableViewCell.m
//  SinaWeiboClient
//
//  Created by Lion User on 01/10/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FansTableViewCell.h"

@interface FansTableViewCell ()
@property (nonatomic,weak) IBOutlet UIImageView *avaterImage;
@property (nonatomic,weak) IBOutlet UILabel *nameLB;
@property (nonatomic,weak) IBOutlet UIButton *followedBtn;
@property (nonatomic,weak) IBOutlet UILabel *countLB;
@property (nonatomic,weak) IBOutlet UILabel *profileLB;
@end

@implementation FansTableViewCell

@synthesize avaterImage = _avaterImage;
@synthesize nameLB = _nameLB;
@synthesize followedBtn = _followedBtn;
@synthesize countLB = _countLB;
@synthesize profileLB = _profileLB;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setupCell:(User *)userInfo withAvaterImageData:(NSData *)imageData
{
    if (imageData) {
        self.avaterImage.image = [UIImage imageWithData:imageData];
    }
    self.profileLB.hidden=YES;
    self.nameLB.text=userInfo.screenName;
    self.countLB.text=[NSString stringWithFormat:@"关注:%d 粉丝:%d 微博:%d", userInfo.friendsCount,userInfo.followersCount,userInfo.statusesCount];
    
    if (userInfo.description!=nil && (![userInfo.description isEqual:[NSNull null]]) && (![userInfo.description isEqualToString:@""])) {
        self.profileLB.hidden=NO;
        self.profileLB.text=userInfo.description;
        CGRect frame = self.profileLB.frame;
        CGSize size = [userInfo.description sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(207.0f, MAXFLOAT) lineBreakMode:UILineBreakModeCharacterWrap];
        frame.size.height=size.height;
        self.profileLB.frame=frame;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
