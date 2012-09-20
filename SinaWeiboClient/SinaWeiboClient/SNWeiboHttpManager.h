//
//  SNWeiboHttpManager.h
//  SinaWeiboClient
//
//  Created by Lion User on 01/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SINA_API_DOMAIN @"https://api.weibo.com/2/"
#define SINA_AUTHORIZE_DOMAIN @"https://api.weibo.com/oauth2/authorize"

#define APP_KEY @"3667763959"
#define App_SECRET @"1612119aebb49acbe350d7ac0ccefe52"



#define ACCESS_TOKEN @"ACCESS_TOKEN"
#define EXPIRE_IN_DATE @"EXPIRE_IN_DATE"
#define USER_ID @"USER_ID"

#define SINA_REQUESTFAILED @"SINA_REQUESTFAILED"

#define SINA_DIDGETHOMETIMELINE @"SINA_DIDGETHOMETIMELINE"
#define SINA_DIDGETRESPONSEERROR @"SINA_DIDGETRESPONSEERROR"

#define USER_REQUEST_TYPE @"RequestType"

#define USER_REQUEST_FAILE @"RequestFailed"

typedef enum {
    Sinaauthorize=0,
    Sinaaccesstoken,
    Sinagethometimeline,    //获取当前登陆用户所关注的微博
    Sinagetcommentstome,    //获取当前登陆用户收到的评论
    Sinarepost,             //
    Sinaupdate,             //
    Sinagetusertimeline     //获取某个用户最新发表的微博列表
    
}RequestType;

@protocol SNWeiboHttpManagerDelegate <NSObject>

-(void)didGetHomeTimeLine:(NSMutableArray *)statusArr;

-(void)didGetResponseError:(NSDictionary *)responseError;

@end


@interface SNWeiboHttpManager : NSObject

@property (nonatomic,strong) id<SNWeiboHttpManagerDelegate> delegate;


+(SNWeiboHttpManager *)getInstance;
-(NSURL *)generateUrl:(NSString *)baseurl withParams:(NSDictionary *)params;
-(void)getUrlReturnValue:(NSString *)url;
-(void)getHomeTimeLineWithCount:(NSInteger)count Page:(NSInteger)page feature:(NSInteger)feature;
@end
