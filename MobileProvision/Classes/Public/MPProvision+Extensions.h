//
//  MPProvision+Extensions.h
//  MobileProvision-iOS
//
//  Created by 冷秋 on 2017/1/19.
//  Copyright © 2017年 Magic-Unique. All rights reserved.
//

#import "MPProvision.h"

typedef NS_ENUM(NSUInteger, MPProvisionType) {
    MPProvisionTypeUnknow,
    MPProvisionTypeDevelopment,
    MPProvisionTypeAdHoc,
    MPProvisionTypeAppStore,
    MPProvisionTypeInHouse,
};

@interface MPProvision (Extensions)

@property (nonatomic, assign, readonly) MPProvisionType type;

@property (nonatomic, strong, readonly) NSString *bundleIdentifier;

@property (nonatomic, assign, readonly) BOOL isWildcard;

- (BOOL)canSignBundleIdentifier:(NSString *)bundleIdentifier validate:(BOOL)validate;

@end
