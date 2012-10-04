//
//  SNWeiboFirstViewController.m
//  SinaWeiboClient
//
//  Created by Lion User on 04/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNWeiboFirstViewController.h"
#import "SNWeiboEngine.h"
#import "SNWeiboHttpManager.h"
#import "SNWeiboImageDownload.h"
#import "StatusTableViewCell.h"
#import "SHKActivityIndicator.h"
#import "Status.h"
#import "SNWeiboCoreDataManager.h"
#import "SNWeiboSendWeiboViewController.h"
#import "SNWeiboDetailViewController.h"


#define UITEXTVIEW_PADDING_WIDTH 16.0f

@interface SNWeiboFirstViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSMutableArray *statuses;
@property (nonatomic,strong) NSMutableDictionary*avaterImages;
@property (nonatomic,strong) NSMutableDictionary *contentImages;
@property (nonatomic,strong) SNWeiboHttpManager *httpManager;
@property (nonatomic,strong) SNWeiboEngine *weiboEngine;
@property (nonatomic)   NSInteger statusCount;
@property (nonatomic)  BOOL isFirstCell;
@property (nonatomic)  BOOL isFirstAppear;
@end

@implementation SNWeiboFirstViewController

@synthesize statuses = _statuses;
@synthesize avaterImages = _avaterImages;
@synthesize contentImages = _contentImages;
@synthesize isFirstCell = _isFirstCell;
@synthesize weiboEngine = _weiboEngine;
@synthesize httpManager = _httpManager;
@synthesize statusCount = _statusCount;
@synthesize isFirstAppear = _isFirstAppear;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}


-(void)postStatus
{
    SNWeiboSendWeiboViewController *sendViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"Send Weibo"];
    sendViewController.viewController=self;
    [self presentModalViewController:sendViewController animated:NO];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title= @"主页";
    self.tabBarItem.title=@"主页";
    
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"发微博" style:UIBarButtonItemStyleBordered target:self action:@selector(postStatus)];
    BOOL isNeedToLogin=NO;
    self.statuses=[NSMutableArray array];
    self.avaterImages=[NSMutableDictionary dictionary];
    self.contentImages=[NSMutableDictionary dictionary];
    self.isFirstCell=YES;
    self.isFirstAppear=YES;
    self.statusCount=0;
    self.weiboEngine=[SNWeiboEngine getInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetHomeTimeLine:) name:SINA_DIDGETHOMETIMELINE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResponseError:) name:SINA_DIDGETRESPONSEERROR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetImage:) name:SINA_DID_GET_IMAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAccessToken:) name:DID_GET_ACCESS_TOKEN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRequestFailed:) name:SINA_REQUESTFAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
   // [[NSUserDefaults standardUserDefaults] removeObjectForKey:ACCESS_TOKEN];
    NSString *token=[[NSUserDefaults standardUserDefaults] objectForKey:ACCESS_TOKEN];
    if (token==nil||([token length]<=0)) {
        [self.weiboEngine loginInViewController:self];
        return;
    }
    isNeedToLogin=[self.weiboEngine hasAccessTokenOutOfDate];
    if (isNeedToLogin) {
        [self.weiboEngine loginInViewController:self];
        return;
    }
    BOOL succeedGetData=[self getData];
    if (succeedGetData) {
        return;
    }else {
        [self.weiboEngine getHomeTimeLineWithCount:20 Page:1 feature:0];
        //[[SHKActivityIndicator currentIndicator] displayActivity:@"Loading" inView:self.view];
    }
    
    //[[SHKActivityIndicator currentIndicator] displayActivity:@"Loading" inView:self.view];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isFirstAppear) {
        self.isFirstAppear=NO;
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResponseError:) name:SINA_DIDGETRESPONSEERROR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetImage:) name:SINA_DID_GET_IMAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAccessToken:) name:DID_GET_ACCESS_TOKEN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRequestFailed:) name:SINA_REQUESTFAILED object:nil];

}

-(BOOL)getData
{
    SNWeiboCoreDataManager *coreDataManager=[SNWeiboCoreDataManager getInstance];
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading" inView:self.view];
    self.statuses=[coreDataManager readStatusFromCDisHomeLine:YES];
    if (self.statuses==nil||([self.statuses count]==0)) {
        return NO;
    }
    NSLog(@"Read %d status data from Core Data",[self.statuses count]);
    [self getImage];
    return YES;
}

-(void)applicationWillResignActive
{
    if (self.statuses==nil) {
        return;
    }
    NSLog(@"Application Will Resign Active,inserting status into Core Data");
    SNWeiboCoreDataManager *coreDataManager=[SNWeiboCoreDataManager getInstance];
    [coreDataManager clearStatusInCDisHomeLine:YES];
    for (NSInteger i=0; i<[self.statuses count]; i++) {
        [coreDataManager insertStatusToCD:[self.statuses objectAtIndex:i] withIndex:i isHomeLine:YES];
    }
}

-(void)handleRequestFailed:(NSNotification *)notification
{
    [[SHKActivityIndicator currentIndicator] hide];
    
}

-(void)handleResponseError:(NSNotification *)notification
{
    [[SHKActivityIndicator currentIndicator] hide];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:EXPIRE_IN_DATE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_ID];
    [self.weiboEngine loginInViewController:self];
}


-(void)didGetAccessToken:(NSNotification *)notification
{
    //NSDictionary *userInfo=[notification userInfo];
    //NSString *token=[userInfo objectForKey:ACCESS_TOKEN];
    [self.weiboEngine getHomeTimeLineWithCount:20 Page:1 feature:0];
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading" inView:self.view];
}
     
-(void)didGetHomeTimeLine:(NSNotification *)notification
{
    NSDictionary *userInfo=[notification userInfo];
    self.statuses=[userInfo objectForKey:HOMETIMELINE];
    NSLog(@"status count=%d",[self.statuses count]);
    [self getImage];
//    [self.tableView reloadData];
}

-(void)getImage
{
    if (self.statuses==nil) {
        NSLog(@"Error:FirstViewController:status is nil");
        return;
    }
    NSInteger count=[self.statuses count];
    for (NSInteger i=0; i<count; i++) {
        Status *item=[self.statuses objectAtIndex:i];
        
        [self.weiboEngine getImageWithURL:item.user.profileImageUrl withIndexnum:i];
        
        if (item.thumbnailPic&&([item.thumbnailPic length]>0)) {
            [self.weiboEngine getImageWithURL:item.thumbnailPic withIndexnum:i];
        }else if (item.retweetedStatus) {
            if (item.retweetedStatus.thumbnailPic&&([item.retweetedStatus.thumbnailPic length]>0)) {
                [self.weiboEngine getImageWithURL:item.retweetedStatus.thumbnailPic withIndexnum:i];
            }
        }
    }
}
     
     
-(void)didGetImage:(NSNotification *)notification
{
    NSDictionary *userInfo=[notification userInfo];
    NSString *key=[userInfo objectForKey:SNWeibo_ImageKey];
    NSData *imageData=[userInfo objectForKey:SNWeibo_ImageData];
    NSNumber *indexNum=[userInfo objectForKey:SNWeibo_ImageIndex];
    NSInteger index=[indexNum integerValue];
    
    Status *item=[self.statuses objectAtIndex:index];
    
    NSLog(@"SNWeiboFirstViewController:didGetImage:imageURL=%@,index=%d",key,index);
    
    if ([key isEqualToString:item.user.profileImageUrl]) {
        [self.avaterImages setObject:imageData forKey:key];
        self.statusCount++;
        NSLog(@"HAVE GET IMAGES = %d",self.statusCount);
        if ((self.statusCount==[self.statuses count])) {
            self.statusCount=0;
            [self.tableView reloadData];
        }
        
        return;
    }
    
    if ([key isEqualToString:item.thumbnailPic]) {
        [self.contentImages setObject:imageData forKey:key];
        
    }else if (item.retweetedStatus) {
        if ([key isEqualToString:item.retweetedStatus.thumbnailPic]) {
            [self.contentImages setObject:imageData forKey:key];
        }
    }
//    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
//    NSArray *indexPaths=[NSArray arrayWithObject:indexPath];
//    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:NO];
    
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_DIDGETRESPONSEERROR object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DID_GET_ACCESS_TOKEN object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_DID_GET_IMAGE object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_REQUESTFAILED object:nil];

    [super viewWillDisappear:animated];
}




- (void)viewDidUnload
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_DIDGETHOMETIMELINE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_DIDGETRESPONSEERROR object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DID_GET_ACCESS_TOKEN object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_DID_GET_IMAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SINA_REQUESTFAILED object:nil];
    self.tableView=nil;
    self.statuses=nil;
    self.avaterImages=nil;
    self.contentImages=nil;
    self.weiboEngine=nil;
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
    return [self.statuses count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Status Cell";
    StatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[StatusTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Status Cell"];
        
    }
    
    
    Status *item=[self.statuses objectAtIndex:indexPath.row];
    NSLog(@"SNWeiboFirstViewController:cellForRowAtIndexPaht:status count=%d",[self.statuses count]);

    NSData *avaterImage=[self.avaterImages objectForKey:item.user.profileImageUrl];
    NSData *contentImage=nil;
    if (item.thumbnailPic&&([item.thumbnailPic length]>0)) {
        contentImage=[self.contentImages    objectForKey:item.thumbnailPic];
    }
    
    if (item.retweetedStatus.thumbnailPic&&([item.retweetedStatus.thumbnailPic length]>0)) {
         contentImage=[self.contentImages    objectForKey:item.retweetedStatus.thumbnailPic];
    }
    
//    if (([self.avaterImages count]>0)&&(indexPath.row<[self.avaterImages count])) {
//        avaterImage=[self.avaterImages objectAtIndex:indexPath.row];
//    }
//    
//    if (([self.contentImages count]>0)&&(indexPath.row<[self.contentImages count])) {
//        contentImage=[self.contentImages objectAtIndex:indexPath.row];
//    }
    
    [cell setupCell:item withAvaterImageData:avaterImage withContentImageData:contentImage];
    
    if (self.isFirstCell) {
        [[SHKActivityIndicator currentIndicator] hide];
        self.isFirstCell=NO;
    }
    // Configure the cell...
    
    return cell;
}

-(CGFloat)heightForTV:(NSString *)contenttext withWidth:(CGFloat)width
{
    CGFloat height=0.0f;
    UIFont *font=[UIFont systemFontOfSize:14.0];
    CGSize size=[contenttext sizeWithFont:font constrainedToSize:CGSizeMake(width-UITEXTVIEW_PADDING_WIDTH, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
    height=size.height;
    height+=106.0f;
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height=0.0f;
    
    Status *item=[self.statuses objectAtIndex:indexPath.row];
    NSString *contentText=[NSString stringWithFormat:@"%@",item.text];
    height=[self heightForTV:contentText withWidth:280.0f];
    NSLog(@"height for context:%f  index:%d",height,indexPath.row);
    if (item.thumbnailPic&&([item.thumbnailPic length]>0)) {
        height+=IMAGE_HEIGHT;
    }else if (item.retweetedStatus) {
        NSString *repostText=[NSString stringWithFormat:@"%@:%@",item.retweetedStatus.user.screenName,item.retweetedStatus.text];
        height+=[self heightForTV:repostText withWidth:260.0f];
        height-=56.0f;
        //NSLog(@"height for retwitterText:%f index:%d",[self heightForTV:repostText withWidth:195.0f],indexPath.row);
        
        if (item.retweetedStatus.thumbnailPic&&([item.retweetedStatus.thumbnailPic length]>0)) {
            height+=IMAGE_HEIGHT;
            
        }
    }

    NSLog(@"cell index=%d,height=%f",indexPath.row,height);

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
    //Detail VC
    SNWeiboDetailViewController *detailViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"Detail VC"];
    detailViewController.status=[self.statuses objectAtIndex:indexPath.row];
    detailViewController.avaterImageData=[self.avaterImages objectForKey:detailViewController.status.user.profileImageUrl];
    detailViewController.contentImageData=nil;
    if (detailViewController.status.thumbnailPic&&([detailViewController.status.thumbnailPic length]>0)) {
       detailViewController.contentImageData=[self.contentImages    objectForKey:detailViewController.status.thumbnailPic];
    }
    
    if (detailViewController.status.retweetedStatus.thumbnailPic&&([detailViewController.status.retweetedStatus.thumbnailPic length]>0)) {
       detailViewController.contentImageData=[self.contentImages    objectForKey:detailViewController.status.retweetedStatus.thumbnailPic];
    }
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
