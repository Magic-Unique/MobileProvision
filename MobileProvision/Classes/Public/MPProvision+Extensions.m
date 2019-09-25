//
//  MPProvision+Extensions.m
//  MobileProvision-iOS
//
//  Created by 冷秋 on 2017/1/19.
//  Copyright © 2017年 Magic-Unique. All rights reserved.
//

#import "MPProvision+Extensions.h"
#import "MPEntitlements.h"

@implementation MPProvision (Extensions)

- (NSString *)bundleIdentifier {
    return [self.Entitlements.ApplicationIdentifier substringFromIndex:11];
}

- (BOOL)isWildcard {
    return [self.bundleIdentifier containsString:@"*"];
}

- (BOOL)canSignBundleIdentifier:(NSString *)bundleIdentifier validate:(BOOL)validate {
    if (!validate) {
        return YES;
    } else if (self.isWildcard) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCH %@", self.bundleIdentifier];
        return [predicate evaluateWithObject:bundleIdentifier];
    } else {
        return [self.bundleIdentifier isEqualToString:bundleIdentifier];
    }
}

- (MPProvisionType)type {
    /// -----------|-------------------|---------------|-----------|---------------
    /// Type       |   get-task-allow  |   beta-report |   devices |   alldevice
    /// -----------|-------------------|---------------|-----------|---------------
    /// dev        |   1               |   0           |    [ ]    |   0
    /// adhoc      |   0               |   0           |    [ ]    |   0
    /// appstore   |   0               |   1           |    nil    |   0
    /// inhouse    |   0               |   0           |    nil    |   1
    /// -----------|-------------------|---------------|-----------|---------------
    if (self.Entitlements.GetTaskAllow) {
        return MPProvisionTypeDevelopment;
    }
    if (self.Entitlements.BetaReportsActive) {
        return MPProvisionTypeAppStore;
    }
    if (self.ProvisionsAllDevices) {
        return MPProvisionTypeInHouse;
    }
    if (self.ProvisionedDevices) {
        return MPProvisionTypeAdHoc;
    }
    return MPProvisionTypeUnknow;
}

@end
