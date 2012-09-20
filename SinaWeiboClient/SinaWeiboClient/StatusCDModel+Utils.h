//
//  StatusCDModel+Utils.h
//  SinaWeiboClient
//
//  Created by Lion User on 18/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatusCDModel.h"
#import "Status.h"


@interface StatusCDModel (Utils)
-(void)updateStatusCDModelWithStatus:(Status *)status withIndex:(NSInteger)index isHomeLine:(BOOL)isHomeLine;
@end
