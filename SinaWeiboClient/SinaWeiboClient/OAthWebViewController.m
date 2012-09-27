//
//  OAthWebViewController.m
//  SinaWeiboClient
//
//  Created by Lion User on 01/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OAthWebViewController.h"
#import "SNWeiboHttpManager.h"
#import "SHKActivityIndicator.h"


@interface OAthWebViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic,strong) SNWeiboHttpManager *httpManager;

@property (nonatomic,strong) UIActivityIndicatorView *spinner;
@end

@implementation OAthWebViewController
@synthesize webView=_webView;
@synthesize httpManager = _httpManager;
@synthesize spinner = _spinner;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSString *)getValueFromURL:(NSString *)url needle:(NSString *)needle
{
    NSString *returnValue=nil;
    NSRange range=[url rangeOfString:needle];
    if (range.location!=NSNotFound) {
        NSRange end=[[url substringFromIndex:range.location+range.length] rangeOfString:@"&"];
        returnValue=end.location==NSNotFound? [url substringFromIndex:range.location+range.length] : [url substringWithRange:NSMakeRange(range.location+range.length, end.location)];
                                                
        
    }
    NSLog(@"urlreturnvalue=%@",returnValue);
    return returnValue;
}

-(void)authorizeSucceedWithUrl:(NSString *)url
{
    NSString *error=[self getValueFromURL:url needle:@"error_code="];
    if (error&&[error isEqualToString:@"21330"]) {
        NSLog(@"user cancel authorize");
    }
    
    NSString *token=[self getValueFromURL:url needle:@"access_token="];
    NSString *uid=[self getValueFromURL:url needle:@"uid="];
    NSString *expire_in=[self getValueFromURL:url needle:@"expires_in="];
    
    NSLog(@"token=%@\nexpire_in=%@\nuid=%@",token,expire_in,uid);
    
    
    NSDate *expiredate=[NSDate dateWithTimeIntervalSinceNow:[expire_in intValue]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] setObject:expiredate forKey:EXPIRE_IN_DATE];
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:USER_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.delegate didGetAccessToken:token withUid:uid];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.httpManager=[[SNWeiboHttpManager alloc] init];
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:
                          @"3667763959",@"client_id",
                          @"https://api.weibo.com/oauth2/default.html",@"redirect_uri",
                          @"token",@"response_type",
                          @"mobile",@"display",
                          nil];
    
    NSURL *url=[self.httpManager generateUrl:@"https://api.weibo.com/oauth2/authorize" withParams:params];
    NSLog(@"url=%@",url);
    self.webView.delegate=self;
    //self.webView.scalesPageToFit=YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //在授权页面点击授权后，这里会遍历多个url，其中我们设置的重定向url和返回值之间用#分隔
    NSString *url=[request.URL absoluteString];
    NSLog(@"webView url=%@",url);
    NSArray *array=[url componentsSeparatedByString:@"#"];
    if ([array count]>1) {
        [self authorizeSucceedWithUrl:url];
        return NO;
    }
    return YES;
       
    
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading" inView:self.view];  
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[SHKActivityIndicator currentIndicator] hide]; 
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[SHKActivityIndicator currentIndicator] hide];
    
    //NSLog(@"webView Fail To Load Error:%@",error.description);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
