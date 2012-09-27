//
//  SNWeiboEngine.m
//  SinaWeiboClient
//
//  Created by Lion User on 13/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNWeiboEngine.h"


#import "SNWeiboHttpManager.h"
#import "SHKActivityIndicator.h"



@interface SNWeiboEngine ()<SNWeiboHttpManagerDelegate,OAuthorizeDelegate>
@property (nonatomic,weak) UIViewController * viewController;
@property (nonatomic,strong) SNWeiboHttpManager *httpManager;
@property (nonatomic,weak) OAthWebViewController *authorizeViewController;
@end

@implementation SNWeiboEngine

@synthesize viewController = _viewController;
@synthesize httpManager = _httpManager;
@synthesize authorizeViewController = _authorizeViewController;

-(id)init
{
    self=[super init];
    if (self) {
        self.httpManager=[[SNWeiboHttpManager alloc] init];
        self.httpManager.delegate=self;
        
    }
    return self;
}

+(SNWeiboEngine *)getInstance
{
    static SNWeiboEngine *instance=nil;
    if (instance==nil) {
        instance=[[self alloc] init];
    }
    return instance;
}

-(BOOL)hasAccessTokenOutOfDate
{
    NSDate *expireDate=[[NSUserDefaults standardUserDefaults] objectForKey:EXPIRE_IN_DATE];
    if (expireDate==nil) {
        return YES;
    }
    
    if (NSOrderedAscending==[expireDate compare:[NSDate date]]) {
        return YES;
    }
    return NO;
}

-(void)loginInViewController:(UIViewController *)viewController
{
    self.viewController=viewController;
    self.authorizeViewController=[self.viewController.storyboard instantiateViewControllerWithIdentifier:@"OAthWebView"];
    self.authorizeViewController.delegate=self;
    [self.viewController presentModalViewController:self.authorizeViewController animated:YES];
}

-(void)getImageWithURL:(NSString *)url withIndexnum:(NSInteger)index
{
    [[SNWeiboImageDownload getInstance] getImageWithURL:url withIndexnum:index];
}

-(void)getImageWithURL:(NSString *)url
{
    [[SNWeiboImageDownload getInstance] getImageWithURL:url];
}

-(void)getHomeTimeLineWithCount:(NSInteger)count Page:(NSInteger)page feature:(NSInteger)feature
{
    [self.httpManager getHomeTimeLineWithCount:count Page:page feature:feature];
}

-(void)getCommentsToShowWithStatusId:(NSNumber *)statusId Count:(NSInteger)count  Page:(NSInteger)page filter:(NSInteger)filter_by_author
{
    [self.httpManager getCommentsToShowWithStatusId:statusId Count:count Page:page filter:filter_by_author];
}


-(void)postStatus:(NSString *)text withImage:(UIImage *)image
{
    if (image) {
        [self.httpManager postStatus:text withImage:image];
    }else {
        [self.httpManager postStatus:text];
    }
}



-(void)didGetAccessToken:(NSString *)token withUid:(NSString *)uid
{
    [self.viewController dismissModalViewControllerAnimated:YES];
    
    NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:
                                                                        token,ACCESS_TOKEN,
                                                                        uid,USER_ID,nil];
    NSNotification *notification=[NSNotification notificationWithName:DID_GET_ACCESS_TOKEN object:self userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(void)didGetResponseError:(NSDictionary *)responseError
{
    NSNotification *notification=[NSNotification notificationWithName:SINA_DIDGETRESPONSEERROR object:self userInfo:responseError];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


-(void)didGetHomeTimeLine:(NSMutableArray *)statusArr
{
    NSDictionary *userInfo=[NSDictionary dictionaryWithObject:statusArr forKey:HOMETIMELINE];
    NSNotification *notification=[NSNotification notificationWithName:SINA_DIDGETHOMETIMELINE object:self userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(void)didGetCommentsToShow:(NSMutableArray *)commentsArr
{
    NSDictionary *userInfo=[NSDictionary dictionaryWithObject:commentsArr forKey:COMMENTSTOSHOW];
    NSNotification *notification=[NSNotification notificationWithName:SINA_DIDGETCOMMENTSTOSHOW object:self userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


-(void)didSucceedPostUpdate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SINA_DIDSUCCEEDPOSTUPDATE object:self];
}

-(void)didSucceedPostUpload
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SINA_DIDSUCCEEDPOSTUPLOAD object:self];
}

@end
