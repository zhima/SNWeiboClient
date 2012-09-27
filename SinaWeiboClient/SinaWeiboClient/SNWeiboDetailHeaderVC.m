//
//  SNWeiboDetailHeaderVC.m
//  SinaWeiboClient
//
//  Created by Lion User on 23/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNWeiboDetailHeaderVC.h"


#define IMAGE_HEIGHT 105.0f
#define OTHER_SPACE_HEIGHT 20.0f

@interface SNWeiboDetailHeaderVC ()
@property (weak, nonatomic) IBOutlet UIImageView *avaterImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLB;

@property (weak, nonatomic) IBOutlet UILabel *timeLB;
@property (weak, nonatomic) IBOutlet UITextView *contentText;
@property (weak, nonatomic) IBOutlet UIImageView *contentImage;
@property (weak, nonatomic) IBOutlet UIView *retweetStatusView;
@property (weak, nonatomic) IBOutlet UIImageView *retweetBgImage;
@property (weak, nonatomic) IBOutlet UITextView *retweetContentText;
@property (weak, nonatomic) IBOutlet UIImageView *retweetContentImage;
@property (weak, nonatomic) IBOutlet UILabel *fromLB;
@property (weak, nonatomic) IBOutlet UILabel *countLB;



@end

@implementation SNWeiboDetailHeaderVC
@synthesize avaterImage;
@synthesize nameLB;
@synthesize timeLB;
@synthesize contentText;
@synthesize contentImage;
@synthesize retweetStatusView;
@synthesize retweetBgImage;
@synthesize retweetContentText;
@synthesize retweetContentImage;
@synthesize fromLB;
@synthesize countLB;
@synthesize sta = _sta;
@synthesize avatImage = _avatImage;
@synthesize contImage = _contImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)setTVHeightWithContentImage:(BOOL)hasContentImage withRetwitterImage:(BOOL)hasRetwitterImage
{
    [self.contentText layoutIfNeeded];
    [self.contentText setNeedsDisplay];
    [self.contentText setNeedsLayout];
    [self.retweetContentText layoutIfNeeded];
    
    CGRect frame=self.contentText.frame;
    frame.size=self.contentText.contentSize;
    self.contentText.frame=frame;
    
    frame=self.retweetContentText.frame;
    frame.size=self.retweetContentText.contentSize;
    self.retweetContentText.frame=frame;
    
    frame=self.retweetStatusView.frame;
    //    if (hasContentImage) {
    //        frame.origin.y=self.contentText.frame.origin.y+self.contentText.frame.size.height+IMAGE_HEIGHT;
    //    }else {
    frame.origin.y=self.contentText.frame.origin.y+self.contentText.frame.size.height;
    //    }
    
    if (hasRetwitterImage) {
        frame.size.height=self.retweetContentText.frame.size.height+IMAGE_HEIGHT;//+36.0f;
    }else {
        frame.size.height=self.retweetContentText.frame.size.height;
    }
    
    
    self.retweetStatusView.frame=frame;
        if (self.retweetStatusView.hidden==NO) {
        NSLog(@"self.retwitterView.height=%f",frame.size.height);
    }
    
    if (hasContentImage) {
        frame=self.contentImage.frame;
        frame.origin.y=self.contentText.frame.origin.y+self.contentText.frame.size.height+8.0f;
        frame.size.height=IMAGE_HEIGHT;
        self.contentImage.frame=frame;
    }
    
    if (hasRetwitterImage) {
        frame=self.retweetContentImage.frame;
        frame.origin.y=self.retweetContentText.frame.origin.y+self.retweetContentText.frame.size.height;
        frame.size.height=IMAGE_HEIGHT;
        self.retweetContentImage.frame=frame;
    }
    
    frame=self.view.frame;
    if (hasContentImage) {
        frame.size.height=self.contentText.frame.origin.y+self.contentText.frame.size.height+self.contentImage.frame.size.height+OTHER_SPACE_HEIGHT;
    }else if (!self.retweetStatusView.hidden) {
        frame.size.height=self.retweetStatusView.frame.origin.y+self.retweetStatusView.frame.size.height+OTHER_SPACE_HEIGHT;
    }else {
        frame.size.height=self.contentText.frame.origin.y+self.contentText.frame.size.height+OTHER_SPACE_HEIGHT;
    }
    self.view.frame=frame;
    
    self.retweetBgImage.image=[[UIImage imageNamed:@"retweet_bg.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:10];
    
    
}




-(void)setupView:(Status *)status withAvaterImageData:(NSData *)avateImage withContentImageData:(NSData *)contenImage
{
    if (avateImage) {
        self.avaterImage.image=[UIImage imageWithData:avateImage];
    }
    self.nameLB.text=[NSString stringWithFormat:@"%@:",status.user.screenName];
    self.contentText.text=[NSString stringWithFormat:@"%@",status.text];
    self.countLB.text=[NSString stringWithFormat:@"转发:(%d) 评论:(%d)",status.retweetsCount,status.commentsCount];
    self.timeLB.text=[NSString stringWithFormat:@"%@",status.timestamp];
    self.fromLB.text=[NSString stringWithFormat:@"来自:%@",status.source];
    self.contentImage.hidden=YES;
    self.retweetStatusView.hidden=YES;
    
    if (status.retweetedStatus  &&![status.retweetedStatus isEqual:[NSNull null]]) {
        self.retweetStatusView.hidden=NO;
        self.retweetContentText.text=[NSString stringWithFormat:@"%@:%@",status.retweetedStatus.user.screenName,status.retweetedStatus.text];
        self.retweetContentText.backgroundColor=[UIColor clearColor];
        self.retweetContentImage.hidden=YES;
        if (contenImage) {
            self.retweetContentImage.image=[UIImage imageWithData:contenImage];
            NSString *retwitterContentImageURL=status.retweetedStatus.thumbnailPic;
            self.retweetContentImage.hidden= retwitterContentImageURL!=nil && [retwitterContentImageURL length]>0 ? NO : YES;
        }
        
        
        [self setTVHeightWithContentImage:NO withRetwitterImage:!self.retweetContentImage.hidden ];
    }else {
        self.retweetStatusView.hidden=YES;
        self.contentImage.hidden=YES;
        if (contentImage) {
            self.contentImage.image=[UIImage imageWithData:contenImage];
            NSString *imageURL=status.thumbnailPic;
            self.contentImage.hidden= imageURL!=nil && [imageURL length]>0 ? NO : YES;
        }
        
        
        [self setTVHeightWithContentImage:!self.contentImage.hidden withRetwitterImage:NO];
    }
    
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView:self.sta withAvaterImageData:self.avatImage withContentImageData:self.contImage];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setAvaterImage:nil];
    [self setNameLB:nil];
    [self setTimeLB:nil];
    [self setContentText:nil];
    [self setContentImage:nil];
    [self setRetweetStatusView:nil];
    [self setRetweetBgImage:nil];
    [self setRetweetContentText:nil];
    [self setRetweetContentImage:nil];
    [self setFromLB:nil];
    [self setCountLB:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
