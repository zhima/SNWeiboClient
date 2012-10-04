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
#import "Comment.h"


#define MAX_IMAGE_BYTES_LENGTH 5242880
#define SINA_API_DOMAIN @"https://api.weibo.com/2/"
#define SINA_UPLOAD_API_DOMAIN @"https://upload.api.weibo.com/2/"
#define SINA_AUTHORIZE_DOMAIN @"https://api.weibo.com/oauth2/authorize"

#define APP_KEY @"3667763959"
#define App_SECRET @"1612119aebb49acbe350d7ac0ccefe52"





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

-(void)postRequestWithURL:(NSURL *)url withParams:(NSDictionary *)params withType:(RequestType)type
{
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    request.delegate=self;
    [request setRequestMethod:@"POST"];
    
    
    [self setRequestUserInfo:request withRequestType:type];
    [request startAsynchronous];
    
}

-(void)postStatus:(NSString *)text
{
    //https://api.weibo.com/2/statuses/update.json
    NSString *token=[[NSUserDefaults standardUserDefaults] objectForKey:ACCESS_TOKEN];
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setValue:token forKey:@"access_token"];
    [params setValue:text forKey:@"status"];
    NSString *url=[SINA_API_DOMAIN stringByAppendingString:@"statuses/update.json"];
    NSLog(@"update URL is:%@",url);
    NSString *contents=[NSString stringWithFormat:@"access_token=%@&status=%@",token,text];
    //[self postRequestWithURL:[NSURL URLWithString:url] withParams:params withType:Sinaupdate];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    request.delegate=self;
    [request setRequestMethod:@"POST"];
    [request addPostValue:token forKey:@"access_token"];
    [request addPostValue:text forKey:@"status"];
    
    [self setRequestUserInfo:request withRequestType:Sinaupdate];
    [request startAsynchronous];
}

-(void)postStatus:(NSString *)text withImage:(UIImage *)image
{
    //https://upload.api.weibo.com/2/statuses/upload.json
    //multipart/form-data
    NSString *token=[[NSUserDefaults standardUserDefaults] objectForKey:ACCESS_TOKEN];
    NSString *url=[SINA_UPLOAD_API_DOMAIN stringByAppendingString:@"statuses/upload.json"];
    NSLog(@"upload URL is:%@",url);
    NSData *imageData=UIImagePNGRepresentation(image);
    if ([imageData length]>MAX_IMAGE_BYTES_LENGTH) {
        NSLog(@"image length is greater than 5M");
    }
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    request.delegate=self;
    [request setRequestMethod:@"POST"];
    [request addPostValue:token forKey:@"access_token"];
    [request addPostValue:text forKey:@"status"];
    [request addData:imageData forKey:@"pic"];
    [request addRequestHeader:@"Content-type" value:@"multipart/form-data"];
    [self setRequestUserInfo:request withRequestType:Sinaupload];
    [request startAsynchronous];

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

-(void)getCommentsToShowWithStatusId:(NSNumber *)statusId Count:(NSInteger)count  Page:(NSInteger)page filter:(NSInteger)filter_by_author
{
    //https://api.weibo.com/2/comments/show.json
    NSString *baseURL=[NSString stringWithString:SINA_API_DOMAIN];
    baseURL=[baseURL stringByAppendingString:@"comments/show.json"];
    NSString *token=[[NSUserDefaults standardUserDefaults] objectForKey:ACCESS_TOKEN];
    NSString *statuId=[NSString stringWithFormat:@"%@",statusId];
    NSString *countstr=[NSString stringWithFormat:@"%d",count];
    NSString *pagestr=[NSString stringWithFormat:@"%d",page];
    NSString *filterstr=[NSString stringWithFormat:@"%d",filter_by_author];
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    token,@"access_token",
                                                                    statuId,@"id",
                                                                    countstr,@"count",
                                                                    pagestr,@"page",
                                                                    filterstr,@"filter_by_author",nil];
    NSURL *url=[self generateUrl:baseURL withParams:params];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    request.delegate=self;
    [self setRequestUserInfo:request withRequestType:Sinagetcommentstoshow];
    [request setTimeOutSeconds:60];
    [self.queue addOperation:request];
    
}

- (void)getFriendshipsFollowersWithCount:(NSInteger)count cursor:(NSInteger)cursor trim_status:(NSInteger)trimed
{
    //https://api.weibo.com/2/friendships/followers.json
    NSString *baseURL=[NSString stringWithString:SINA_API_DOMAIN];
    baseURL=[baseURL stringByAppendingString:@"friendships/followers.json"];
    NSString *token=[[NSUserDefaults standardUserDefaults] objectForKey:ACCESS_TOKEN];
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID];
    NSString *followersCount=[NSString stringWithFormat:@"%d",count];
    NSString *followersCursor=[NSString stringWithFormat:@"%d",cursor];
    NSString *followersTrimed=[NSString stringWithFormat:@"%d",trimed];
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    token,@"access_token",
                                                                    userId,@"uid",
                                                                    followersCount,@"count",
                                                                    followersCursor,@"cursor",
                                                                    followersTrimed,@"trim_status", nil];
    NSURL *url=[self generateUrl:baseURL withParams:params];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    request.delegate=self;
    [self setRequestUserInfo:request withRequestType:Sinagetfollowers];
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
    
    //NSInteger responseError=[[responseObject objectForKey:@"error_code"] integerValue];
    NSString *responseError=[responseObject objectForKey:@"error"];
    if (responseError) {
        NSLog(@"Error:SNWeiboHttpManager:requestFinished:responseError:%@  %@",responseError,[responseObject objectForKey:@"error_code"]);
        [self.delegate didGetResponseError:responseObject];
        return;
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
        
    }else if (requstType==Sinagetcommentstoshow) {
        NSArray *commentsObjects=[responseObject objectForKey:@"comments"];
        NSMutableArray *comments=[NSMutableArray array];
        for (NSDictionary *commentsObj in commentsObjects) {
            Comment *comment=[[Comment alloc] initWithJsonDictionary:commentsObj];
            
            [comments addObject:comment];
        }
        NSLog(@"Get Comments count=%d",[comments count]);
        [self.delegate didGetCommentsToShow:comments];
        
    }else if (requstType==Sinaupdate) {
        NSString *statusId=[responseObject objectForKey:@"id"];
        if (statusId) {
            [self.delegate didSucceedPostUpdate];
        }
    }else if (requstType==Sinaupload) {
        NSString *statusId=[responseObject objectForKey:@"id"];
        if (statusId) {
            [self.delegate didSucceedPostUpload];
        }
    }else if (requstType==Sinagetfollowers) {
        NSArray *followerObjects=[responseObject objectForKey:@"users"];
        NSMutableArray *followers=[NSMutableArray array];
        for (NSDictionary *followerObj in followerObjects) {
            User *user=[[User alloc] initWithJsonDictionary:followerObj];
            NSLog(@"user description :%@",user.description);
            [followers addObject:user];
        }
        NSLog(@"Get Followers count=%d",[followers count]);
        [self.delegate didGetFriendshipsFollowers:followers];
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
