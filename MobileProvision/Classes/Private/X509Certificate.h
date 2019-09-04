//
//  X509Certificate.h
//  MobileProvision_Example
//
//  Created by 冷秋 on 2019/8/31.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASN1.h"

typedef NS_ENUM(NSUInteger, X509BlockPosition) {
    X509BlockPositionVersion = 0,
    X509BlockPositionSerialNumber = 1,
    X509BlockPositionSignatureAlg = 2,
    X509BlockPositionIssuer = 3,
    X509BlockPositionDateValidity = 4,
    X509BlockPositionSubject = 5,
    X509BlockPositionPublicKey = 6,
    X509BlockPositionExtensions = 7,
};

@interface X509Certificate : NSObject

@property (nonatomic, strong, readonly) NSArray<ASN1Node *> *asn1;

@property (nonatomic, strong, readonly) ASN1Node *block1;

@property (nonatomic, strong, readonly) NSData *data;

+ (instancetype)certificateWithData:(NSData *)data;

@end
