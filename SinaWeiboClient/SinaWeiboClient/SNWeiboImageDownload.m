//
//  SNWeiboImageDownload.m
//  SinaWeiboClient
//
//  Created by Lion User on 11/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNWeiboImageDownload.h"
#import "ASIHTTPRequest.h"
#import "SNWeiboCoreDataManager.h"

@interface SNWeiboImageDownload()<ASIHTTPRequestDelegate>
@property (nonatomic,strong) SNWeiboCoreDataManager *coreDataManager;
@end

@implementation SNWeiboImageDownload

@synthesize coreDataManager = _coreDataManager;


-(id)init
{
    self=[super init];
    if (self) {
        self.coreDataManager=[SNWeiboCoreDataManager getInstance];
    }
    return self;
}



+(SNWeiboImageDownload *)getInstance
{
    static SNWeiboImageDownload *instance=nil;
    if (instance==nil) {
        instance=[[SNWeiboImageDownload alloc] init];
    }
    return instance;
}


-(void)sendNotificationWithKey:(NSString *)url Data:(NSData *)data index:(NSNumber *)index
{
    NSDictionary *notificationObject=[NSDictionary dictionaryWithObjectsAndKeys:
                                                        url,SNWeibo_ImageKey,
                                                        data,SNWeibo_ImageData,
                                                        index,SNWeibo_ImageIndex,nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SINA_DID_GET_IMAGE object:self userInfo:notificationObject];
}


-(void)getImageWithURL:(NSString *)url withIndexnum:(NSInteger)index
{
    
    if (url&&[url length]>0) {
        NSData *image=[[SNWeiboCoreDataManager getInstance] readImageFromCD:url];
        
        if (image) {
            [self sendNotificationWithKey:url Data:image index:[NSNumber numberWithInteger:index]];
            return;
        }
        
        
        ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
        request.delegate=self;
        if (index>=0) {
            NSNumber *indexNumber=[NSNumber numberWithInteger:index];
            
            [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:url,@"url",indexNumber,@"index", nil]];
        }else {
            [request setUserInfo:[NSDictionary dictionaryWithObject:url forKey:@"url"]];
        }
        [request startAsynchronous];
     
    }
}


-(void)getImageWithURL:(NSString *)url
{
    if (url&&[url length]>0) {
        [self getImageWithURL:url withIndexnum:-1];
    }
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary *userInfo=[request userInfo];
    NSString *url=[userInfo objectForKey:@"url"];
    NSNumber *index=[userInfo objectForKey:@"index"];
    
    NSLog(@"imageurl=%@   imageindex=%@",url,index);
    
    NSData *imageData=[request responseData];
    [[SNWeiboCoreDataManager getInstance] insertImageToCD:imageData withKey:url];
    [self sendNotificationWithKey:url Data:imageData index:index];
}



@end
