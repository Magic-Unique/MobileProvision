//
//  MPCertificate.h
//  MobileProvisionTool
//
//  Created by Magic-Unique on 2018/6/10.
//  Copyright © 2018年 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPComponent.h"

@interface MPValidity : NSObject <MPComponent>

@property (nonatomic, strong, readonly) NSDate *notBefore;

@property (nonatomic, strong, readonly) NSDate *notAfter;

@end

@interface MPFingerprints : NSObject <MPComponent>

@property (nonatomic, strong, readonly) NSString *SHA1;

@property (nonatomic, strong, readonly) NSString *SHA256;

@end

@interface MPOrganization : NSObject <MPComponent>

@property (nonatomic, strong, readonly) NSString *name;

@property (nonatomic, strong, readonly) NSString *unitName;

@property (nonatomic, strong, readonly) NSString *commonName;

@property (nonatomic, strong, readonly) NSString *countryName;

@end


@interface MPCertificate : NSObject <MPComponent>

@property (nonatomic, assign, readonly) NSInteger version;

@property (nonatomic, strong, readonly) NSString *name;

@property (nonatomic, strong, readonly) NSString *serialNumber;

@property (nonatomic, strong, readonly) MPValidity *validity;

@property (nonatomic, strong, readonly) MPOrganization *subject;

@property (nonatomic, strong, readonly) MPOrganization *issuer;

@property (nonatomic, strong, readonly) NSData *signature;



@property (nonatomic, strong, readonly) NSData *data;

@property (nonatomic, strong, readonly) MPFingerprints *fingerprints;

@property (nonatomic, assign, readonly) BOOL isValid;

+ (instancetype)certificateWithData:(NSData *)data;

- (BOOL)isValid:(NSDate *)date;

@end


@interface MPCertificate (OCSP)

@property (nonatomic, strong, readonly) NSData *serialNumberData;

@end
