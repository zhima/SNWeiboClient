//
//  SNWeiboDefines.h
//  SinaWeiboClient
//
//  Created by Lion User on 21/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef SinaWeiboClient_SNWeiboDefines_h
#define SinaWeiboClient_SNWeiboDefines_h

#define SINA_DIDGETHOMETIMELINE @"SINA_DIDGETHOMETIMELINE"
#define SINA_DIDGETCOMMENTSTOSHOW @"SINA_DIDGETCOMMENTSTOSHOW"  //根据微博ID返回某条微博的评论列表
#define SINA_DIDSUCCEEDPOSTUPDATE @"SINA_DIDSUCCEEDPOSTUPDATE"
#define SINA_DIDSUCCEEDPOSTUPLOAD @"SINA_DIDSUCCEEDPOSTUPLOAD"
#define SINA_DIDGETFRIENDSHIPSFOLLOWERS @"SINA_DIDGETFRIENDSHIPSFOLLOWERS"

#define HOMETIMELINE @"HOMETIMELINE"
#define COMMENTSTOSHOW @"COMMENTSTOSHOW"
#define FRIENDSHIPSFOLLOWERS @"FRIENDSHIPSFOLLOWERS"


#define SINA_DIDGETRESPONSEERROR @"SINA_DIDGETRESPONSEERROR"
#define SINA_REQUESTFAILED @"SINA_REQUESTFAILED"

#define ACCESS_TOKEN @"ACCESS_TOKEN"
#define EXPIRE_IN_DATE @"EXPIRE_IN_DATE"
#define USER_ID @"USER_ID"

#define USER_REQUEST_TYPE @"RequestType"

#define USER_REQUEST_FAILE @"RequestFailed"

typedef enum {
    Sinaauthorize=0,
    Sinaaccesstoken,
    Sinagethometimeline,    //获取当前登陆用户所关注的微博
    Sinagetcommentstome,    //获取当前登陆用户收到的评论
    Sinarepost,             //转发一条微博
    Sinaupdate,             //发布一条新微博
    Sinaupload,             //上传图片并发布一条新微博
    Sinagetusertimeline,    //获取某个用户最新发表的微博列表
    Sinagetcommentstoshow,   //根据微博ID返回某条微博的评论列表
    Sinagetfollowers          //获取用户的粉丝列表
}RequestType;
#endif
