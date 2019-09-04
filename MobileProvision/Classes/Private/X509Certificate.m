//
//  X509Certificate.m
//  MobileProvision_Example
//
//  Created by 冷秋 on 2019/8/31.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "X509Certificate.h"
#import "ASN1Decoder.h"

@implementation X509Certificate

+ (instancetype)certificateWithData:(NSData *)data {
    ASN1Decoder *decoder = [ASN1Decoder decode:data];
    if (decoder.error) {
        return nil;
    } else {
        return [[self alloc] initWithData:data nodes:decoder.nodes];
    }
}

- (instancetype)initWithData:(NSData *)data nodes:(NSArray<ASN1Node *> *)nodes {
    self = [super init];
    if (self) {
        _data = data;
        _asn1 = nodes;
        _block1 = _asn1.firstObject.sub.firstObject;
    }
    return self;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString string];
    for (ASN1Node *item in self.asn1) {
        [string appendFormat:@"%@", item];
    }
    return string;
}

@end
