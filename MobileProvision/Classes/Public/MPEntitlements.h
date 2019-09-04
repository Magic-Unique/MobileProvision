//
//  MPEntitlements.h
//  RingTone
//
//  Created by 冷秋 on 2017/1/19.
//  Copyright © 2017年 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPComponent.h"

@interface MPEntitlements : NSObject <MPComponent>

@property (nonatomic, copy, readonly) NSString *ApplicationIdentifier;

/** Enable for APNs */
@property (nonatomic, copy) NSString *APsEnvironment;

/** Enable in Production */
@property (nonatomic, assign) BOOL BetaReportsActive;

@property (nonatomic, copy) NSString *AppleDeveloperTeamIdentifier;

@property (nonatomic, assign) BOOL GetTaskAllow;

@property (nonatomic, copy) NSArray<NSString *> *KeychainAccessGroups;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)entitlementsWithDictionary:(NSDictionary *)dictionary;

@end
