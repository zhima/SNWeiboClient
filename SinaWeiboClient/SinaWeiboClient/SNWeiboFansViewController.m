//
//  SNWeiboFansViewController.m
//  SinaWeiboClient
//
//  Created by Lion User on 01/10/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNWeiboFansViewController.h"
#import "FansTableViewCell.h"
#import "User.h"
#import "SNWeiboEngine.h"
#import "SNWeiboDefines.h"
#import "SHKActivityIndicator.h"


@interface SNWeiboFansViewController ()
@property (nonatomic,strong) NSMutableArray *users;
@property (nonatomic,strong) NSMutableDictionary *avaterImageDic;
@property (nonatomic) BOOL isFirstCell;
@property (nonatomic) BOOL isFirstAppear;

@end

@implementation SNWeiboFansViewController

@synthesize users = _users;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"粉丝列表";
    self.users = [NSMutableArray array];
    self.avaterImageDic = [NSMutableDictionary dictionary];
    self.isFirstCell=YES;
    self.isFirstAppear=YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetFriendshipsFollowers:) name:SINA_DIDGETFRIENDSHIPSFOLLOWERS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetImage:) name:SINA_DID_GET_IMAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestFailed:) name:SINA_REQUESTFAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetResponseError:) name:SINA_DIDGETRESPONSEERROR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAccessToken:) name:DID_GET_ACCESS_TOKEN object:nil];
    
    
    [[SNWeiboEngine getInstance] getFriendshipsFollowersWithCount:40 cursor:0 trim_status:0];
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading" inView:self.view];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isFirstAppear) {
        self.isFirstAppear=NO;
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetImage:) name:SINA_DID_GET_IMAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestFailed:) name:SINA_REQUESTFAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetResponseError:) name:SINA_DIDGETRESPONSEERROR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAccessToken:) name:DID_GET_ACCESS_TOKEN object:nil];

    //
}


-(void)getImage
{
    if (self.users==nil) {
        NSLog(@"Error:SNWeiboFansViewController:users dictionary is nil");
        return;
    }
    
    NSInteger count=[self.users count];
    
    for (NSInteger i=0; i<count; i++) {
        User *user = [self.users objectAtIndex:i];
        
        [[SNWeiboEngine getInstance] getImageWithURL:user.profileImageUrl withIndexnum:i];
    }
}

-(void)didGetAccessToken:(NSNotification *)notification
{
    [[SNWeiboEngine getInstance] getFriendshipsFollowersWithCount:40 cursor:0 trim_status:0];
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading" inView:self.view];

}


-(void)didGetResponseError:(NSNotification *)notification
{
    [[SHKActivityIndicator currentIndicator] hide];
    BOOL tokenExpired=[[SNWeiboEngine getInstance] hasAccessTokenOutOfDate];
    if (tokenExpired) {
        [[SNWeiboEngine getInstance] loginInViewController:self];
    }
}


-(void)requestFailed:(NSNotification *)notification
{
    [[SHKActivityIndicator currentIndicator] hide];
    UIAlertView *requestFailedAlertView=[[UIAlertView alloc] initWithTitle:nil message:@"请求失败，请检查网络连接是否正常" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
    [requestFailedAlertView show];
}

-(void)didGetFriendshipsFollowers:(NSNotification *)notification
{
    NSDictionary *notificationUserInfo=[notification userInfo];
    self.users=[notificationUserInfo objectForKey:FRIENDSHIPSFOLLOWERS];
    NSLog(@"did get followers count=%d",[self.users count]);
    if (self.users==nil||([self.users count]==0)) {
        [[SHKActivityIndicator currentIndicator] hide];
    }
    [self getImage];
}


-(void)didGetImage:(NSNotification *)notification
{
    NSDictionary *notiUserInfo=notification.userInfo;
    NSString *key=[notiUserInfo objectForKey:SNWeibo_ImageKey];
    NSData *imageData=[notiUserInfo objectForKey:SNWeibo_ImageData];
    NSInteger index=[[notiUserInfo objectForKey:SNWeibo_ImageIndex] integerValue];
    static NSInteger imageCount=0;
    
    User *user=[self.users objectAtIndex:index];
    if ([key isEqualToString:user.profileImageUrl]) {
        [self.avaterImageDic setObject:imageData forKey:user.profileImageUrl];
        imageCount++;
        NSLog(@"SNWeiboFansViewController:imageCount=%d",imageCount);
        if (imageCount==[self.users count]) {
            imageCount=0;
            [self.tableView reloadData];
        }
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_DIDGETRESPONSEERROR object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_DID_GET_IMAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DID_GET_ACCESS_TOKEN object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_REQUESTFAILED object:nil];
  
    [super viewWillDisappear:animated];
}


- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_DIDGETFRIENDSHIPSFOLLOWERS object:nil];
    self.users=nil;
    self.avaterImageDic=nil;
    
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.

}

- (IBAction)followedBtnClicked:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"取消关注"]) {
        sender.titleLabel.text=@"关注";
    }else {
        sender.titleLabel.text=@"取消关注";
    }
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
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Fans Cell";
    FansTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil) {
        cell=[[FansTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    User *userInfo=[self.users objectAtIndex:indexPath.row];
    NSData *imageData=[self.avaterImageDic objectForKey:userInfo.profileImageUrl];
    [cell setupCell:userInfo withAvaterImageData:imageData];
    
    
    if (self.isFirstCell) {
        self.isFirstCell=NO;
        [[SHKActivityIndicator currentIndicator] hide];
    }
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *userInfo=[self.users objectAtIndex:indexPath.row];
    CGFloat height=0.0f;
    if (userInfo.description!=nil && (![userInfo.description isEqual:[NSNull null]]) && (![userInfo.description isEqualToString:@""])) {
        
        CGSize size = [userInfo.description sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(207.0f, MAXFLOAT) lineBreakMode:UILineBreakModeCharacterWrap];
        height=size.height+66.0f;
        
    }else {
        height=66.0f;
    }
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
