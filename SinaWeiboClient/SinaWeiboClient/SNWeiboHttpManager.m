//
//  SNWeiboHttpManager.m
//  SinaWeiboClient
//
//  Created by Lion User on 01/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNWeiboHttpManager.h"
#import "NSString+Utils.h"
#import "SNWeiboImageDownload.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJSON.h"
#import "Status.h"

@interface SNWeiboHttpManager() <ASIHTTPRequestDelegate>
@property (nonatomic,strong) NSOperationQueue *queue;
@end

@implementation SNWeiboHttpManager
@synthesize queue = _queue;
@synthesize delegate = _delegate;

-(id)init
{
    self=[super init];
    if (self) {
        self.queue=[[NSOperationQueue alloc] init];
    }
    return self;
}

+(SNWeiboHttpManager *)getInstance
{
    static SNWeiboHttpManager *instance=nil;
    if (instance==nil) {
        instance=[[SNWeiboHttpManager alloc] init];
    }
    return instance;
}

-(NSURL *)generateUrl:(NSString *)baseurl withParams:(NSDictionary *)params
{
    if (params==nil) {
        return [NSURL URLWithString:baseurl];
    }
    NSMutableArray *array=[NSMutableArray array];
    NSEnumerator *enumerator=[params keyEnumerator];
    for (NSString *key in enumerator) {
        NSString *value=[params valueForKey:key];
        
        [array addObject:[NSString stringWithFormat:@"%@=%@",key,[value encodeToPercentEscapeString]]];
    }
    NSString *query=[array componentsJoinedByString:@"&"];
        
    baseurl=[baseurl stringByAppendingFormat:@"?%@",query];
    NSLog(@"baseurl=%@\n",baseurl);
    
    
    return [NSURL URLWithString:baseurl];
}

-(void)setRequestUserInfo:(ASIHTTPRequest *)request withRequestType:(RequestType)type
{
    NSDictionary *userInfo=[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:type] forKey:USER_REQUEST_TYPE];
    [request setUserInfo:userInfo];
}


-(void)getHomeTimeLineWithCount:(NSInteger)count Page:(NSInteger)page feature:(NSInteger)feature
{
    //https://api.weibo.com/2/statuses/home_timeline.json
    NSString *baseURL=[NSString stringWithString:SINA_API_DOMAIN];
    baseURL=[baseURL stringByAppendingString:@"statuses/home_timeline.json"];
    NSString *token=[[NSUserDefaults standardUserDefaults] objectForKey:ACCESS_TOKEN];
    NSString *count2=[NSString stringWithFormat:@"%d",count];
    NSString *page2=[NSString stringWithFormat:@"%d",page];
    NSString *feature2=[NSString stringWithFormat:@"%d",feature];
    NSLog(@"hometimeline:token=%@",token);
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    token,@"access_token",
                                                                    count2,@"count",
                                                                    page2,@"page",
                                                                    feature2,@"feature",nil];
    NSURL *url=[self generateUrl:baseURL withParams:params];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    request.delegate=self;
    [self setRequestUserInfo:request withRequestType:Sinagethometimeline];
    [request setTimeOutSeconds:60];
    [self.queue addOperation:request];
}


-(void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"SNWeiboHttpManager:request started");
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"SNWeiboHttpManager:requestFinished:request have finished");
    NSDictionary *userInfo=[request userInfo];
    NSNumber *index=[userInfo objectForKey:USER_REQUEST_TYPE];
    RequestType requstType=[index integerValue];
    SBJSON *parser=[[SBJSON alloc] init];
    
    NSError *error;
    NSDictionary *responseObject=[parser objectWithString:[request responseString] error:&error];
    
    if (error) {
        NSLog(@"Error:SNWeiboHttpManager:requestFinished:response string parse error");
        return;
    }
    
    NSString *responseError=[responseObject objectForKey:@"error_code"];
    if (responseError&&([responseError length]>0)) {
        NSLog(@"Error:SNWeiboHttpManager:requestFinished:%@  %@",responseError,[responseObject objectForKey:@"error_description"]);
        [self.delegate didGetResponseError:responseObject];
    }
    
    if (requstType==Sinagethometimeline) {
        NSArray *statuObjtects=[responseObject objectForKey:@"statuses"];
        NSMutableArray *status=[NSMutableArray array];
        for (NSDictionary *statuObj in statuObjtects) {
            Status *statu=[[Status alloc] initWithJsonDictionary:statuObj];
            [status addObject:statu];
        }
        NSLog(@"Get HomeTimeLine's count=%d",[status count]);
        [self.delegate didGetHomeTimeLine:status];
        
    }
    
    
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error=[request error];
    NSLog(@"Error:SNWeiboHttpManager:requestFailed:%@",error.description);
    NSDictionary *errorInfo=[NSDictionary dictionaryWithObject:error forKey:USER_REQUEST_FAILE];
    [[NSNotificationCenter defaultCenter] postNotificationName:SINA_REQUESTFAILED object:self userInfo:errorInfo];
    
    
}


@end
