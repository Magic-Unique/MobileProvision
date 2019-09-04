//
//  MPCertificate.h
//  MobileProvisionTool
//
//  Created by Magic-Unique on 2018/6/10.
//  Copyright © 2018年 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPComponent.h"

@interface MPValidity : NSObject

@property (nonatomic, strong, readonly) NSDate *notBefore;

@property (nonatomic, strong, readonly) NSDate *notAfter;

@end


@interface MPCertificate : NSObject <MPComponent>

@property (nonatomic, strong, readonly) NSString *name;

@property (nonatomic, strong, readonly) NSString *serialNumber;

@property (nonatomic, strong, readonly) MPValidity *validity;

@property (nonatomic, assign, readonly) NSInteger version;

@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSString *> *subjectNames;

@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSString *> *issuerNames;

@property (nonatomic, strong, readonly) NSData *signature;



@property (nonatomic, strong, readonly) NSData *data;

@property (nonatomic, assign, readonly) BOOL isValid;

+ (instancetype)certificateWithData:(NSData *)data;

- (BOOL)isValid:(NSDate *)date;

@end
