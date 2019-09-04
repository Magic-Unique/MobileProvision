//
//  ASN1Node.h
//  MobileProvision_Example
//
//  Created by 冷秋 on 2019/8/31.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(Byte, ASN1TagNumber) {
    ASN1TagNumberEndOfContent = 0x00,
    ASN1TagNumberBoolean = 0x01,
    ASN1TagNumberInteger = 0x02,
    ASN1TagNumberBitString = 0x03,
    ASN1TagNumberOctetString = 0x04,
    ASN1TagNumberNull = 0x05,
    ASN1TagNumberObjectIdentifier = 0x06,
    ASN1TagNumberObjectDescriptor = 0x07,
    ASN1TagNumberExternal = 0x08,
    ASN1TagNumberRead = 0x09,
    ASN1TagNumberEnumerated = 0x0A,
    ASN1TagNumberEmbeddedPdv = 0x0B,
    ASN1TagNumberUtf8String = 0x0C,
    ASN1TagNumberRelativeOid = 0x0D,
    ASN1TagNumberSequence = 0x10,
    ASN1TagNumberSet = 0x11,
    ASN1TagNumberNumericString = 0x12,
    ASN1TagNumberPrintableString = 0x13,
    ASN1TagNumberT61String = 0x14,
    ASN1TagNumberVideotexString = 0x15,
    ASN1TagNumberIa5String = 0x16,
    ASN1TagNumberUtcTime = 0x17,
    ASN1TagNumberGeneralizedTime = 0x18,
    ASN1TagNumberGraphicString = 0x19,
    ASN1TagNumberVisibleString = 0x1A,
    ASN1TagNumberGeneralString = 0x1B,
    ASN1TagNumberUniversalString = 0x1C,
    ASN1TagNumberCharacterString = 0x1D,
    ASN1TagNumberBmpString = 0x1E,
};

typedef NS_ENUM(NSUInteger, ASN1TypeClass) {
    ASN1TypeClassUniversal = 0x00,
    ASN1TypeClassApplication = 0x40,
    ASN1TypeClassContextSpecific = 0x80,
    ASN1TypeClassPrivate = 0xC0,
};

@interface ASN1Identifier : NSObject

@property (nonatomic, assign) Byte rawValue;

@property (nonatomic, assign, readonly) ASN1TagNumber tagNumber;

@property (nonatomic, assign, readonly) ASN1TypeClass typeClass;

@property (nonatomic, assign, readonly, getter=isPrimitive) BOOL primitive;

@property (nonatomic, assign, readonly, getter=isConstructed) BOOL construct;

- (instancetype)initWithRowValue:(Byte)rawValue;

@end

@interface ASN1Node : NSObject

@property (nonatomic, strong) NSData *rawValue;

@property (nonatomic, strong) id value;

@property (nonatomic, strong) ASN1Identifier *identifier;

@property (nonatomic, strong) NSArray<ASN1Node *> *sub;

@property (nonatomic, weak) ASN1Node *parent;

- (ASN1Node *)findOID:(NSString *)OID;

@property (nonatomic, strong, readonly) id firstLeafValue;

@end
