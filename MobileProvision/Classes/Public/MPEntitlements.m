//
//  MPEntitlements.m
//  RingTone
//
//  Created by 冷秋 on 2017/1/19.
//  Copyright © 2017年 Magic-Unique. All rights reserved.
//

#import "MPEntitlements.h"

@implementation MPEntitlements

@synthesize JSON = _JSON;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
	self = [super init];
	if (self) {
		_ApplicationIdentifier = dictionary[@"application-identifier"];
		_APsEnvironment = dictionary[@"aps-environment"];
		_BetaReportsActive = [dictionary[@"beta-reports-active"] boolValue];
		_AppleDeveloperTeamIdentifier = dictionary[@"com.apple.developer.team-identifier"];
		_GetTaskAllow = [dictionary[@"get-task-allow"] boolValue];
		_KeychainAccessGroups = dictionary[@"keychain-access-groups"];
        _JSON = dictionary;
	}
	return self;
}

+ (instancetype)entitlementsWithDictionary:(NSDictionary *)dictionary {
	return [[self alloc] initWithDictionary:dictionary];
}

@end
