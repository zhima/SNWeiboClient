//
//  NSString+Utils.h
//  SinaWeiboClient
//
//  Created by Lion User on 04/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)
- (NSString *)encodeToPercentEscapeString;
- (NSString *)decodeFromPercentEscapeString;
@end
