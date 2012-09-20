//
//  ImageCDItem.h
//  SinaWeiboClient
//
//  Created by Lion User on 12/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ImageCDItem : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSDate * date;

@end
