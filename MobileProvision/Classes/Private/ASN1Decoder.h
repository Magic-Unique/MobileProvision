//
//  ASN1Decoder.h
//  MobileProvision_Example
//
//  Created by 冷秋 on 2019/8/31.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASN1.h"

NS_ASSUME_NONNULL_BEGIN

@interface ASN1Decoder : NSObject

@property (nonatomic, strong, readonly) NSDateFormatter *dateFormatter;

@property (nonatomic, strong, readonly) NSArray<ASN1Node *> *nodes;

@property (nonatomic, strong, readonly) NSError *error;

@property (nonatomic, strong, readonly) NSData *data;

+ (instancetype)decode:(NSData *)data;

@end

FOUNDATION_EXTERN NSUInteger NSData2NSUInteger(NSData *data);

NS_ASSUME_NONNULL_END
