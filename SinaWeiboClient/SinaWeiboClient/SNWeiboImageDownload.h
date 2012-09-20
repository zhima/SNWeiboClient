//
//  SNWeiboImageDownload.h
//  SinaWeiboClient
//
//  Created by Lion User on 11/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SINA_DID_GET_IMAGE @"SINA_DID_GET_IMAGE"
#define SNWeibo_ImageData @"SNWeibo_ImageData"
#define SNWeibo_ImageKey @"SNWeibo_ImageKey"
#define SNWeibo_ImageIndex @"SNWeibo_ImageIndex"
#define IMAGE_HEIGHT 80.0f

@interface SNWeiboImageDownload : NSObject

-(void)getImageWithURL:(NSString *)url withIndexnum:(NSInteger)index;
-(void)getImageWithURL:(NSString *)url;
+(SNWeiboImageDownload *)getInstance;

@end
