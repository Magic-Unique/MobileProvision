//
//  MPProvision.h
//  RingTone
//
//  Created by 冷秋 on 2017/1/19.
//  Copyright © 2017年 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPComponent.h"

@class MPEntitlements, MPCertificate;

/**
 描述文件类
 */
@interface MPProvision : NSObject <MPComponent>

@property (nonatomic, strong, readonly) NSString *AppIDName;

@property (nonatomic, strong, readonly) NSArray<NSString *> *ApplicationIdentifierPrefix;

@property (nonatomic, strong, readonly) NSDate *CreationDate;

@property (nonatomic, strong, readonly) NSArray<MPCertificate *> *DeveloperCertificates;

@property (nonatomic, strong, readonly) MPEntitlements *Entitlements;

@property (nonatomic, strong, readonly) NSDate *ExpirationDate;

@property (nonatomic, strong, readonly) NSString *Name;

@property (nonatomic, strong, readonly) NSArray<NSString *> *Platform;

/** Enable in Enterprice */
@property (nonatomic, assign, readonly) BOOL ProvisionsAllDevices;

/** Enable in Development */
@property (nonatomic, strong, readonly) NSArray<NSString *> *ProvisionedDevices;

@property (nonatomic, strong, readonly) NSArray<NSString *> *TeamIdentifier;

@property (nonatomic, strong, readonly) NSString *TeamName;

@property (nonatomic, assign, readonly) NSUInteger TimeToLive;

@property (nonatomic, strong, readonly) NSString *UUID;

@property (nonatomic, assign, readonly) NSUInteger Version;

/**
 Read embedded.mobileprovision in App bundle.

 @return MPProvision
 */
+ (instancetype)embeddedProvision;

/**
 Read *.mobileprovision for specify path.

 @param file Path of *.mobileprovision
 @return MPProvision
 */
+ (instancetype)provisionWithContentsOfFile:(NSString *)file;

@end
