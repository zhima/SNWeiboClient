//
//  NSString+Utils.m
//  SinaWeiboClient
//
//  Created by Lion User on 04/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)
- (NSString *)encodeToPercentEscapeString
{
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    NSString *outputStr = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                        (CFStringRef)self,
                                                                                        NULL,
                                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                        kCFStringEncodingUTF8);
    return outputStr;
}



- (NSString *)decodeFromPercentEscapeString
{
    NSMutableString *outputStr = [NSMutableString stringWithString:self];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


@end
