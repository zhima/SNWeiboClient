#import "User.h"
#import "GlobalCore.h"


@implementation User

@synthesize userId;
@synthesize screenName;
@synthesize username;
@synthesize name;
@synthesize province;
@synthesize city;
@synthesize location;
@synthesize description;
@synthesize url;
@synthesize profileImageUrl;
@synthesize profileLargeImageUrl;
@synthesize domain;
@synthesize gender;
@synthesize followersCount;
@synthesize friendsCount;
@synthesize statusesCount;
@synthesize favoritesCount;
@synthesize createdAt;
@synthesize following;
@synthesize followedBy;
@synthesize verified;
@synthesize allowAllActMsg;
@synthesize geoEnabled;
@synthesize userKey;




- (User*)initWithJsonDictionary:(NSDictionary*)dic
{
	self = [super init];
    
    [self updateWithJSonDictionary:dic];
	
	return self;
}

-(void)updateUserWithUserCDModel:(UserCDModel *)userCDModel
{
    self.userId=userCDModel.userId.longLongValue;
    self.userKey=userCDModel.userId;
    self.username=userCDModel.username;
    self.name=userCDModel.name;
    self.createdAt=userCDModel.createdAt.timeIntervalSince1970;
    self.screenName=userCDModel.screenName;
    self.location=userCDModel.location;
    self.description=userCDModel.descriptions;
    self.url=userCDModel.url;
    self.profileImageUrl=userCDModel.profileImageUrl;
    self.profileLargeImageUrl=userCDModel.profileLargeImageUrl;
    self.domain=userCDModel.domain;
    self.gender=userCDModel.gender.shortValue;
    self.followersCount=userCDModel.followersCount.intValue;
    self.friendsCount=userCDModel.friendsCount.intValue;
    self.statusesCount=userCDModel.statusesCount.intValue;
    self.favoritesCount=userCDModel.favoritesCount.intValue;
    self.following=userCDModel.following.boolValue;
    self.verified=userCDModel.verified.boolValue;
    self.allowAllActMsg=userCDModel.allowAllActMsg.boolValue;
    self.geoEnabled=userCDModel.geoEnabled.boolValue;
    
}

- (void)updateWithJSonDictionary:(NSDictionary*)dic
{
	[userKey release];
	[username release];
    [screenName release];
    [name release];
	[province release];
	[city release];
    [location release];
    [description release];
    [url release];
    [profileImageUrl release];
	[domain release];
	[profileLargeImageUrl release];
    
    userId          = [[dic objectForKey:@"id"] longLongValue];
    userKey			= [[NSNumber alloc] initWithLongLong:userId];
	screenName      = [dic objectForKey:@"screen_name"];
    name            = [dic objectForKey:@"name"];
	
	//int provinceId = [[dic objectForKey:@"province"] intValue];
	//int cityId = [[dic objectForKey:@"city"] intValue];
	//province		= provinceId > 0 ? [ProvinceDataSource getProvinceName:provinceId] : @"";
	//city			= cityId > 0 ? [ProvinceDataSource getCityNameWithProvinceId:provinceId
	//														 withCityId:cityId] : @"";
    province=@"";
    city=@"";
	
	location        = [dic objectForKey:@"location"];
	description     = [dic objectForKey:@"description"];
	url             = [dic objectForKey:@"url"];
    profileImageUrl = [dic objectForKey:@"profile_image_url"];
	domain			= [dic objectForKey:@"domain"];
	
	NSString *genderChar = [dic objectForKey:@"gender"];
	if ([genderChar isEqualToString:@"m"]) {
		gender = GenderMale;
	}
	else if ([genderChar isEqualToString:@"f"]) {
		gender = GenderFemale;
	}
	else {
		gender = GenderUnknow;
	}

	
    followersCount  = ([dic objectForKey:@"followers_count"] == [NSNull null]) ? 0 : [[dic objectForKey:@"followers_count"] longValue];
    friendsCount    = ([dic objectForKey:@"friends_count"]   == [NSNull null]) ? 0 : [[dic objectForKey:@"friends_count"] longValue];
    statusesCount   = ([dic objectForKey:@"statuses_count"]  == [NSNull null]) ? 0 : [[dic objectForKey:@"statuses_count"] longValue];
    favoritesCount  = ([dic objectForKey:@"favourites_count"]  == [NSNull null]) ? 0 : [[dic objectForKey:@"favourites_count"] longValue];

    following       = ([dic objectForKey:@"following"]       == [NSNull null]) ? 0 : [[dic objectForKey:@"following"] boolValue];
    verified		= ([dic objectForKey:@"verified"]       == [NSNull null]) ? 0 : [[dic objectForKey:@"verified"] boolValue];
    allowAllActMsg	= ([dic objectForKey:@"allow_all_act_msg"]       == [NSNull null]) ? 0 : [[dic objectForKey:@"allow_all_act_msg"] boolValue];  
    geoEnabled		= ([dic objectForKey:@"geo_enabled"]   == [NSNull null]) ? 0 : [[dic objectForKey:@"geo_enabled"] boolValue];
    
	NSString *stringOfCreatedAt   = [dic objectForKey:@"created_at"];
    if ((id)stringOfCreatedAt == [NSNull null]) {
        stringOfCreatedAt = @"";
    }
	createdAt = convertTimeStamp(stringOfCreatedAt);
	
    if ((id)screenName == [NSNull null]) screenName = @"";
    if ((id)name == [NSNull null]) name = @"";
    if ((id)province == [NSNull null]) province = @"";
    if ((id)city == [NSNull null]) city = @"";
    if ((id)location == [NSNull null]) location = @"";
    if ((id)description == [NSNull null]) description = @"";
    if ((id)url == [NSNull null]) url = @"";
    if ((id)profileImageUrl == [NSNull null]) profileImageUrl = @"";
    if ((id)domain == [NSNull null]) domain = @"";
    
	username = [screenName copy];
    [screenName retain];
    [name retain];
	[province retain];
	[city retain];
    //location = [[location unescapeHTML] retain];
   // description = [[description unescapeHTML] retain];
    location=@"";
    description=@"";
    [url retain];
    [profileImageUrl retain];
	[domain retain];
	profileLargeImageUrl = [[profileImageUrl stringByReplacingOccurrencesOfString:@"/50/" withString:@"/180/"] copy];
}


+ (User*)userWithJsonDictionary:(NSDictionary*)dic
{
	User *u;
    
    u = [[User alloc] initWithJsonDictionary:dic];
    
    return [u autorelease];
}


- (void)dealloc
{
	[userKey release];
	[username release];
    [screenName release];
    [name release];
	[province release];
	[city release];
    [location release];
    [description release];
    [url release];
    [profileImageUrl release];
	[profileLargeImageUrl release];
	[domain release];
   	[super dealloc];
}




@end
