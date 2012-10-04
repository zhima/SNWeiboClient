//
//  SNWeiboDetailViewController.m
//  SinaWeiboClient
//
//  Created by Lion User on 23/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNWeiboDetailViewController.h"
#import "SNWeiboDetailHeaderVC.h"
#import "SNWeiboEngine.h"
#import "SHKActivityIndicator.h"
#import "Comment.h"
#import "CommentTableViewCell.h"


#define IMAGE_HEIGHT 105.0f
#define OTHER_SPACE_HEIGHT 90.0f


@interface SNWeiboDetailViewController ()
@property (nonatomic,weak) IBOutlet UIView *headerView;
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

@property (nonatomic,strong) NSMutableArray *comments;
@property (nonatomic,strong) NSMutableDictionary *avaterImageDic;
@property (nonatomic) BOOL isFirstCell;
@property (nonatomic) BOOL isFirstAppear;
@end

@implementation SNWeiboDetailViewController
@synthesize headerView = _headerView;
@synthesize avaterImage = _avaterImage;
@synthesize nameLB = _nameLB;
@synthesize timeLB = _timeLB;
@synthesize contentText = _contentText;
@synthesize contentImage = _contentImage;
@synthesize retweetStatusView = _retweetStatusView;
@synthesize retweetBgImage = _retweetBgImage;
@synthesize retweetContentText = _retweetContentText;
@synthesize retweetContentImage = _retweetContentImage;
@synthesize fromLB = _fromLB;
@synthesize countLB = _countLB;
@synthesize status = _status;
@synthesize avaterImageData = _avaterImageData;
@synthesize contentImageData = _contentImageData;

@synthesize comments = _comments;
@synthesize avaterImageDic = _avaterImageDic;
@synthesize isFirstCell = _isFirstCell;
@synthesize isFirstAppear = _isFirstAppear;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
        frame.size.height=self.retweetContentText.frame.size.height+IMAGE_HEIGHT+36.0f;//+36.0f;
    }else {
        frame.size.height=self.retweetContentText.frame.size.height+28.0f;
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
    
    frame=self.headerView.frame;
    if (hasContentImage) {
        frame.size.height=self.contentText.frame.size.height+self.contentImage.frame.size.height+OTHER_SPACE_HEIGHT+10.0f;
    }else if (!self.retweetStatusView.hidden) {
        frame.size.height=self.contentText.frame.size.height+self.retweetStatusView.frame.size.height+OTHER_SPACE_HEIGHT;
    }else {
        frame.size.height=self.contentText.frame.size.height+OTHER_SPACE_HEIGHT;
    }
    NSLog(@"HEADER VIEW HEIGHT IS %f",frame.size.height);
    self.headerView.frame=frame;
    
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
        if (contenImage) {
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
    self.title=self.status.user.screenName;
    self.comments=[NSMutableArray array];
    self.avaterImageDic=[NSMutableDictionary dictionary];
    self.isFirstCell=YES;
    self.isFirstAppear=YES;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCommentsToShow:) name:SINA_DIDGETCOMMENTSTOSHOW object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetImage:) name:SINA_DID_GET_IMAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAccessToken:) name:DID_GET_ACCESS_TOKEN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRequestFailed:) name:SINA_REQUESTFAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResponseError:) name:SINA_DIDGETRESPONSEERROR object:nil];
    [self setupView:self.status withAvaterImageData:self.avaterImageData withContentImageData:self.contentImageData];
    self.tableView.tableHeaderView=self.headerView;
    
    [[SNWeiboEngine getInstance] getCommentsToShowWithStatusId:self.status.statusKey Count:30 Page:1 filter:0];
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading" inView:self.view];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    if (self.isFirstAppear) {
//        self.isFirstAppear=NO;
//        return;
//    }
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetImage:) name:SINA_DID_GET_IMAGE object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAccessToken:) name:DID_GET_ACCESS_TOKEN object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRequestFailed:) name:SINA_REQUESTFAILED object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResponseError:) name:SINA_DIDGETRESPONSEERROR object:nil];
//
//}


-(void)handleRequestFailed:(NSNotification *)notification
{
    [[SHKActivityIndicator currentIndicator] hide];
    UIAlertView *requestFailedAlertView=[[UIAlertView alloc] initWithTitle:nil message:@"请求失败，请检查网络连接是否正常" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
    [requestFailedAlertView show];
}


-(void)handleResponseError:(NSNotification *)notification
{
    [[SHKActivityIndicator currentIndicator] hide];
    BOOL tokenExpired=[[SNWeiboEngine getInstance] hasAccessTokenOutOfDate];
    if (tokenExpired) {
        [[SNWeiboEngine getInstance] loginInViewController:self];
    }

}

- (void)didGetAccessToken:(NSNotification *)notification
{
    [[SNWeiboEngine getInstance] getCommentsToShowWithStatusId:self.status.statusKey Count:30 Page:1 filter:0];
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading" inView:self.view];
}



-(void)getImage
{
    if (self.comments==nil) {
        NSLog(@"comments Array is nil");
         [[SHKActivityIndicator currentIndicator] hide];
        return;
    }
    NSInteger count=[self.comments count];
    for (NSInteger i=0; i<count; i++) {
        Comment *comment=[self.comments objectAtIndex:i];
        [[SNWeiboEngine getInstance] getImageWithURL:comment.user.profileImageUrl withIndexnum:i];
    }
}


-(void)didGetCommentsToShow:(NSNotification *)notification
{
    NSDictionary *userInfo=[notification userInfo];
    self.comments=[userInfo objectForKey:COMMENTSTOSHOW];
    NSLog(@"get Comments count is %d",[self.comments count]);
    if ([self.comments count]==0) {
        [[SHKActivityIndicator currentIndicator] hide];
        return;
    }
    [self getImage];
    
}


-(void)didGetImage:(NSNotification *)notification
{
    NSDictionary *userInfo=[notification userInfo];
    NSString *key=[userInfo objectForKey:SNWeibo_ImageKey];
    NSData *imageData=[userInfo objectForKey:SNWeibo_ImageData];
    NSNumber *indexNum=[userInfo objectForKey:SNWeibo_ImageIndex];
    NSInteger index=[indexNum integerValue];
    static NSInteger commentsCount=0;
    
    
    Comment *comment=[self.comments objectAtIndex:index];
    
    if ([key isEqualToString:comment.user.profileImageUrl]) {
        [self.avaterImageDic setObject:imageData forKey:key];
        commentsCount++;
        NSLog(@"comments Count=%d",commentsCount);
        if (commentsCount==[self.comments count]) {
            commentsCount=0;
            [[SHKActivityIndicator currentIndicator] hide];
            [self.tableView reloadData];
        }
    }
}



//- (void)viewWillDisappear:(BOOL)animated
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_DID_GET_IMAGE object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_DIDGETRESPONSEERROR object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:DID_GET_ACCESS_TOKEN object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_REQUESTFAILED object:nil];
//    [super viewWillDisappear:animated];
//}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_DIDGETCOMMENTSTOSHOW object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_DID_GET_IMAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_DIDGETRESPONSEERROR object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DID_GET_ACCESS_TOKEN object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_REQUESTFAILED object:nil];
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
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    return [self.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Comment Cell";
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Comment *comment=[self.comments objectAtIndex:indexPath.row];
    NSData *data=[self.avaterImageDic objectForKey:comment.user.profileImageUrl];
    [cell setupCommentCell:comment withAvaterImage:data];
    // Configure the cell...
//    if (self.isFirstCell) {
//        [[SHKActivityIndicator currentIndicator] hide];
//        self.isFirstCell=NO;
//        
//    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height=0.0f;
    Comment *comment=[self.comments objectAtIndex:indexPath.row];
    CGSize size=[comment.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(240.0f, MAXFLOAT) lineBreakMode:UILineBreakModeCharacterWrap];
    height=size.height;
    height+=44.0f;
    return height;
    
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
