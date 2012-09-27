//
//  SNWeiboCoreDataManager.h
//  SinaWeiboClient
//
//  Created by Lion User on 12/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Status.h"
#import "User.h"
#import "StatusCDModel.h"
#import "UserCDModel.h"

@interface SNWeiboCoreDataManager : NSObject

@property (nonatomic,strong) NSManagedObjectContext *managedContext;


+(SNWeiboCoreDataManager *)getInstance;
-(void)insertImageToCD:(NSData *)imageData withKey:(NSString *)key;
-(NSData *)readImageFromCD:(NSString *)key;

-(void)insertStatusToCD:(Status *)status withIndex:(NSInteger)index isHomeLine:(BOOL)isHomeLine;
-(NSMutableArray *)readStatusFromCDisHomeLine:(BOOL)isHomeLine;
-(void)clearStatusInCDisHomeLine:(BOOL)isHomeLine;
@end
