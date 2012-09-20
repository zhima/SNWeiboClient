//
//  Status.m
//  WeiboPad
//
//  Created by junmin liu on 10-10-6.
//  Copyright 2010 Openlab. All rights reserved.
//

#import "Status.h"
#import "NSDictionaryAdditions.h"


@implementation Status
@synthesize statusId, createdAt, text, source, sourceUrl, favorited, truncated, longitude, latitude, inReplyToStatusId;
@synthesize inReplyToUserId, inReplyToScreenName, thumbnailPic, bmiddlePic, originalPic, user;
@synthesize commentsCount, retweetsCount, retweetedStatus, unread, hasReply;
@synthesize statusKey;


-(void)updateStatusWithStatusCDModel:(StatusCDModel *)statusCDModel
{
    self.statusId=statusCDModel.statusId.longLongValue;
    self.statusKey=statusCDModel.statusId;
    self.createdAt=statusCDModel.createdAt.timeIntervalSince1970;
    self.text=statusCDModel.text;
    self.source=statusCDModel.source;
    self.sourceUrl=statusCDModel.sourceUrl;
    self.favorited=statusCDModel.favorited.boolValue;
    self.truncated=statusCDModel.truncated.boolValue;
    self.latitude=statusCDModel.latitude.doubleValue;
    self.longitude=statusCDModel.longitude.doubleValue;
    self.inReplyToStatusId=statusCDModel.inReplyToStatusId.longLongValue;
    self.inReplyToUserId=statusCDModel.inReplyToUserId.intValue;
    self.inReplyToScreenName=statusCDModel.inReplyToScreenName;
    self.thumbnailPic=statusCDModel.thumbnailPic;
    self.bmiddlePic=statusCDModel.bmiddlePic;
    self.originalPic=statusCDModel.originalPic;
    self.commentsCount=statusCDModel.commentsCount.intValue;
    self.retweetsCount=statusCDModel.retweetsCount.intValue;
    
    if (statusCDModel.retweetedStatus) {
        
        self.retweetedStatus=[[Status alloc] init];
        [self.retweetedStatus updateStatusWithStatusCDModel:statusCDModel.retweetedStatus];
    }
    
    self.user=[[User alloc] init];
    [self.user updateUserWithUserCDModel:statusCDModel.user];
    
}

- (Status*)initWithJsonDictionary:(NSDictionary*)dic {
	if (self = [super init]) {
		commentsCount = -1;
		retweetsCount = -1;
		statusId = [dic getLongLongValueValueForKey:@"id" defaultValue:-1];
		statusKey = [[NSNumber alloc]initWithLongLong:statusId];
		createdAt = [dic getTimeValueForKey:@"created_at" defaultValue:0];
		text = [[dic getStringValueForKey:@"text" defaultValue:@""] retain];
        
        retweetsCount=[dic getIntValueForKey:@"reposts_count" defaultValue:-1];
        commentsCount=[dic getIntValueForKey:@"comments_count" defaultValue:-1];
		
		// parse source parameter
		NSString *src = [dic getStringValueForKey:@"source" defaultValue:@""];
		NSRange r = [src rangeOfString:@"<a href"];
		NSRange end;
		if (r.location != NSNotFound) {
			NSRange start = [src rangeOfString:@"<a href=\""];
			if (start.location != NSNotFound) {
				int l = [src length];
				NSRange fromRang = NSMakeRange(start.location + start.length, l-start.length-start.location);
				end   = [src rangeOfString:@"\"" options:NSCaseInsensitiveSearch 
											 range:fromRang];
				if (end.location != NSNotFound) {
					r.location = start.location + start.length;
					r.length = end.location - r.location;
					sourceUrl = [src substringWithRange:r];
				}
				else {
					sourceUrl = @"";
				}
			}
			else {
				sourceUrl = @"";
			}			
			start = [src rangeOfString:@"\">"];
			end   = [src rangeOfString:@"</a>"];
			if (start.location != NSNotFound && end.location != NSNotFound) {
				r.location = start.location + start.length;
				r.length = end.location - r.location;
				source = [src substringWithRange:r];
			}
			else {
				source = @"";
			}
		}
		else {
			source = src;
		}
		source = [source retain];
		sourceUrl = [sourceUrl retain];
		
		favorited = [dic getBoolValueForKey:@"favorited" defaultValue:NO];
		truncated = [dic getBoolValueForKey:@"truncated" defaultValue:NO];
		
		NSDictionary* geoDic = [dic objectForKey:@"geo"];
		if (geoDic && [geoDic isKindOfClass:[NSDictionary class]]) {
			NSArray *coordinates = [geoDic objectForKey:@"coordinates"];
			if (coordinates && coordinates.count == 2) {
				longitude = [[coordinates objectAtIndex:1] doubleValue];
				latitude = [[coordinates objectAtIndex:0] doubleValue];
			}
		}
		
		inReplyToStatusId = [dic getLongLongValueValueForKey:@"in_reply_to_status_id" defaultValue:-1];
		inReplyToUserId = [dic getIntValueForKey:@"in_reply_to_user_id" defaultValue:-1];
		inReplyToScreenName = [[dic getStringValueForKey:@"in_reply_to_screen_name" defaultValue:@""] retain];
		thumbnailPic = [[dic getStringValueForKey:@"thumbnail_pic" defaultValue:@""] retain];
		bmiddlePic = [[dic getStringValueForKey:@"bmiddle_pic" defaultValue:@""] retain];
		originalPic = [[dic getStringValueForKey:@"original_pic" defaultValue:@""] retain];
		
		NSDictionary* userDic = [dic objectForKey:@"user"];
		if (userDic) {
			user = [[User userWithJsonDictionary:userDic] retain];
		}
		
		NSDictionary* retweetedStatusDic = [dic objectForKey:@"retweeted_status"];
		if (retweetedStatusDic) {
			retweetedStatus = [[Status statusWithJsonDictionary:retweetedStatusDic] retain];
		}
	}
	return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
 	[encoder encodeInt64:statusId forKey:@"statusId"];
	[encoder encodeInt:createdAt forKey:@"createdAt"];
	[encoder encodeObject:text forKey:@"text"];
	[encoder encodeObject:source forKey:@"source"];
	[encoder encodeObject:sourceUrl forKey:@"sourceUrl"];
	[encoder encodeBool:favorited forKey:@"favorited"];
	[encoder encodeBool:truncated forKey:@"truncated"];
	[encoder encodeDouble:latitude forKey:@"latitude"];
	[encoder encodeDouble:longitude forKey:@"longitude"];
	[encoder encodeInt64:inReplyToStatusId forKey:@"inReplyToStatusId"];
	[encoder encodeInt:inReplyToUserId forKey:@"inReplyToUserId"];
	[encoder encodeObject:inReplyToScreenName forKey:@"inReplyToScreenName"];
	[encoder encodeObject:thumbnailPic forKey:@"thumbnailPic"];
	[encoder encodeObject:bmiddlePic forKey:@"bmiddlePic"];
	[encoder encodeObject:originalPic forKey:@"originalPic"];
	[encoder encodeObject:user forKey:@"user"];
	[encoder encodeObject:retweetedStatus forKey:@"retweetedStatus"];
	[encoder encodeInt:commentsCount forKey:@"commentsCount"];
	[encoder encodeInt:retweetsCount forKey:@"retweetsCount"];
	[encoder encodeBool:unread forKey:@"unread"];
	[encoder encodeBool:hasReply forKey:@"hasReply"]; 
}


+ (Status*)statusWithJsonDictionary:(NSDictionary*)dic
{
	return [[[Status alloc] initWithJsonDictionary:dic] autorelease];
}


- (NSString*)timestamp
{
	NSString *_timestamp;
    // Calculate distance time string
    //
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now, createdAt);
    if (distance < 0) distance = 0;
    
    if (distance < 60) {
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"秒前" : @"秒前"];
    }
    else if (distance < 60 * 60) {  
        distance = distance / 60;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"分钟前" : @"分钟前"];
    }  
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"小时前" : @"小时前"];
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"天前" : @"天前"];
    }
    else if (distance < 60 * 60 * 24 * 7 * 4) {
        distance = distance / 60 / 60 / 24 / 7;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"周前" : @"周前"];
    }
    else {
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        }
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:createdAt];        
        _timestamp = [dateFormatter stringFromDate:date];
    }
    return _timestamp;
}

- (NSString *)timeString {
	if (!_timeString) {
		static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        }
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:createdAt];        
        _timeString = [[dateFormatter stringFromDate:date] copy];
	}
	return _timeString;
}

- (NSString *)commentsCountText {
	return commentsCount > 0 ? [NSString stringWithFormat:@"(%d)", commentsCount] : @"";
}

- (NSString *)retweetsCountText {
	return retweetsCount > 0 ? [NSString stringWithFormat:@"(%d)", retweetsCount] : @"";
}

- (void)dealloc {
	[text release];
	[source release];
	[sourceUrl release];
	[inReplyToScreenName release];
	[thumbnailPic release];
	[bmiddlePic release];
	[originalPic release];
	[user release];
	[retweetedStatus release];
	[statusKey release];
	[_timeString release];
	[super dealloc];
}







@end
