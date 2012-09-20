//
//  StatusTableViewCell.m
//  SinaWeiboClient
//
//  Created by Lion User on 09/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatusTableViewCell.h"

#define IMAGE_HEIGHT 80.0f
#define UITEXTVIEW_PADDING_WIDTH 16.0f

@interface StatusTableViewCell() 
@property (nonatomic,weak) IBOutlet UIImageView *avaterImage;

@property (nonatomic,weak) IBOutlet UILabel *nameLB;
@property (nonatomic,weak) IBOutlet UITextView *contentText;
@property (nonatomic,weak) IBOutlet UIImageView *contentImage;
@property (nonatomic,weak) IBOutlet UIView *retwitterStatusView;
@property (nonatomic,weak) IBOutlet UIImageView *retwitterContentImage;

@property (nonatomic,weak) IBOutlet UITextView *retwitterContentText;
@property (nonatomic,weak) IBOutlet UIImageView *retwitterBgImage;
@property (nonatomic,weak) IBOutlet UILabel *timeLB;
@property (nonatomic,weak) IBOutlet UILabel *countLB;
@property (nonatomic,weak) IBOutlet UILabel *fromLB;
@end

@implementation StatusTableViewCell
@synthesize avaterImage = _avaterImage;
@synthesize nameLB = _nameLB;
@synthesize contentText = _contentText;
@synthesize contentImage = _contentImage;
@synthesize retwitterStatusView = _retwitterStatusView;
@synthesize retwitterContentImage = _retwitterContentImage;

@synthesize retwitterContentText = _retwitterContentText;
@synthesize retwitterBgImage = _retwitterBgImage;
@synthesize timeLB = _timeLB;
@synthesize countLB = _countLB;
@synthesize fromLB = _fromLB;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(CGFloat)heightForTV:(NSString *)contenttext withWidth:(CGFloat)width
{
    CGFloat height=0.0f;
    UIFont *font=[UIFont systemFontOfSize:14.0];
    CGSize size=[contenttext sizeWithFont:font constrainedToSize:CGSizeMake(width-UITEXTVIEW_PADDING_WIDTH, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
    height=size.height;
    
    return height;
}

-(void)setTVHeightWithContentImage:(BOOL)hasContentImage withRetwitterImage:(BOOL)hasRetwitterImage
{
    [self.contentText layoutIfNeeded];
    [self.contentText setNeedsDisplay];
    [self.contentText setNeedsLayout];
    
    
    CGRect frame=self.contentText.frame;
    frame.size=self.contentText.contentSize;
    self.contentText.frame=frame;
    
    frame=self.retwitterContentText.frame;
    frame.size=self.retwitterContentText.contentSize;
    self.retwitterContentText.frame=frame;
    
    frame=self.retwitterStatusView.frame;
//    if (hasContentImage) {
//        frame.origin.y=self.contentText.frame.origin.y+self.contentText.frame.size.height+IMAGE_HEIGHT;
//    }else {
        frame.origin.y=self.contentText.frame.origin.y+self.contentText.frame.size.height;
//    }
    
    if (hasRetwitterImage) {
        frame.size.height=self.retwitterContentText.frame.size.height+IMAGE_HEIGHT+36.0f;
    }else {
        frame.size.height=self.retwitterContentText.frame.size.height;
    }
    
    
    self.retwitterStatusView.frame=frame;
    NSLog(@"self.contentText.height=%f",self.contentText.frame.size.height);
    if (self.retwitterStatusView.hidden==NO) {
        NSLog(@"self.retwitterView.height=%f",frame.size.height);
    }
    
    if (hasContentImage) {
        frame=self.contentImage.frame;
        frame.origin.y=self.contentText.frame.origin.y+self.contentText.frame.size.height+8.0f;
        frame.size.height=IMAGE_HEIGHT;
        self.contentImage.frame=frame;
    }
    
    if (hasRetwitterImage) {
        frame=self.retwitterContentImage.frame;
        frame.origin.y=self.retwitterContentText.frame.origin.y+self.retwitterContentText.frame.size.height;
        frame.size.height=IMAGE_HEIGHT;
        self.retwitterContentImage.frame=frame;
    }
    
//    self.retwitterBgImage.image=[[UIImage imageNamed:@"retweet_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(130, 7, 0, 0)];
//    self.retwitterBgImage.image=[[UIImage imageNamed:@"timeline_rt_border_t.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:320];
    self.retwitterBgImage.image=[[UIImage imageNamed:@"retweet_bg.png"] stretchableImageWithLeftCapWidth:22 topCapHeight:10];

    
    

    
}


-(void)setupCell:(Status *)status withAvaterImageData:(NSData *)avaterImage withContentImageData:(NSData *)contentImage
{
    if (avaterImage) {
        self.avaterImage.image=[UIImage imageWithData:avaterImage];
    }
    self.nameLB.text=[NSString stringWithFormat:@"%@:",status.user.screenName];
    self.contentText.text=[NSString stringWithFormat:@"%@",status.text];
    self.countLB.text=[NSString stringWithFormat:@"转发:%d 评论:%d",status.retweetsCount,status.commentsCount];
    self.timeLB.text=[NSString stringWithFormat:@"%@",status.timestamp];
    self.fromLB.text=[NSString stringWithFormat:@"来自:%@",status.source];
    self.contentImage.hidden=YES;
    self.retwitterStatusView.hidden=YES;
    
    if (status.retweetedStatus  &&![status.retweetedStatus isEqual:[NSNull null]]) {
        self.retwitterStatusView.hidden=NO;
        self.retwitterContentText.text=[NSString stringWithFormat:@"%@:%@",status.retweetedStatus.user.screenName,status.retweetedStatus.text];
        self.retwitterContentText.backgroundColor=[UIColor clearColor];
        self.retwitterContentImage.hidden=YES;
        if (contentImage) {
            self.retwitterContentImage.image=[UIImage imageWithData:contentImage];
            NSString *retwitterContentImageURL=status.retweetedStatus.thumbnailPic;
            self.retwitterContentImage.hidden= retwitterContentImageURL!=nil && [retwitterContentImageURL length]>0 ? NO : YES;
        }
        
        
        [self setTVHeightWithContentImage:NO withRetwitterImage:!self.retwitterContentImage.hidden ];
    }else {
        self.retwitterStatusView.hidden=YES;
        self.contentImage.hidden=YES;
        if (contentImage) {
            self.contentImage.image=[UIImage imageWithData:contentImage];
            NSString *imageURL=status.thumbnailPic;
            self.contentImage.hidden= imageURL!=nil && [imageURL length]>0 ? NO : YES;
        }
        
        
        [self setTVHeightWithContentImage:!self.contentImage.hidden withRetwitterImage:NO];
    }
    
    
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
