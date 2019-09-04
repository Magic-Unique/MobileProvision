//
//  ASN1Node.m
//  MobileProvision_Example
//
//  Created by 冷秋 on 2019/8/31.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "ASN1.h"

@implementation ASN1Identifier

- (instancetype)initWithRowValue:(Byte)rawValue {
    self = [super init];
    if (self) {
        self.rawValue = rawValue;
        if (self.rawValue > ASN1TagNumberBmpString) {
            _tagNumber = ASN1TagNumberEndOfContent;
        } else {
            _tagNumber = self.rawValue;
        }
        _primitive = (self.rawValue & 0x20) == 0;
        _construct = (self.rawValue & 0x20) != 0;
        _typeClass = [ASN1Identifier typeClassWithRawValue:rawValue];
    }
    return self;
}

+ (ASN1TypeClass)typeClassWithRawValue:(Byte)rawValue {
#define ASN1CheckClass(c) if ((rawValue & c) == c) return c;
    ASN1CheckClass(ASN1TypeClassApplication);
    ASN1CheckClass(ASN1TypeClassContextSpecific);
    ASN1CheckClass(ASN1TypeClassPrivate);
#undef ASN1CheckClass
    return ASN1TypeClassUniversal;
}

+ (NSString *)typeClassName:(ASN1TypeClass)typeClass {
#define ASN1CheckClass(c) if ((typeClass) == ASN1TypeClass##c) return @#c;
    ASN1CheckClass(Application);
    ASN1CheckClass(ContextSpecific);
    ASN1CheckClass(Private);
#undef ASN1CheckClass
    return nil;
}

+ (NSString *)tagNumberName:(ASN1TagNumber)tagNumber {
#define ASN1CheckClass(c) if ((tagNumber) == ASN1TagNumber##c) return @#c;
    ASN1CheckClass(EndOfContent)
    ASN1CheckClass(Boolean)
    ASN1CheckClass(Integer)
    ASN1CheckClass(BitString)
    ASN1CheckClass(OctetString)
    ASN1CheckClass(Null)
    ASN1CheckClass(ObjectIdentifier)
    ASN1CheckClass(ObjectDescriptor)
    ASN1CheckClass(External)
    ASN1CheckClass(Read)
    ASN1CheckClass(Enumerated)
    ASN1CheckClass(EmbeddedPdv)
    ASN1CheckClass(Utf8String)
    ASN1CheckClass(RelativeOid)
    ASN1CheckClass(Sequence)
    ASN1CheckClass(Set)
    ASN1CheckClass(NumericString)
    ASN1CheckClass(PrintableString)
    ASN1CheckClass(T61String)
    ASN1CheckClass(VideotexString)
    ASN1CheckClass(Ia5String)
    ASN1CheckClass(UtcTime)
    ASN1CheckClass(GeneralizedTime)
    ASN1CheckClass(GraphicString)
    ASN1CheckClass(VisibleString)
    ASN1CheckClass(GeneralString)
    ASN1CheckClass(UniversalString)
    ASN1CheckClass(CharacterString)
    ASN1CheckClass(BmpString)
#undef ASN1CheckClass
    return nil;
}

- (NSString *)description {
    if (self.typeClass == ASN1TypeClassUniversal) {
        // return String(describing: tagNumber())
        return [ASN1Identifier tagNumberName:self.tagNumber];
    }
    else {
        return [NSString stringWithFormat:@"%@(%02X)",[ASN1Identifier typeClassName:self.typeClass], self.rawValue];
        // return "\(typeClass())(\(tagNumber().rawValue))" .
    }
}

@end

@implementation ASN1Node

- (ASN1Node *)findOID:(NSString *)OID {
    for (ASN1Node *child in self.sub) {
        if (child.identifier.tagNumber == ASN1TagNumberObjectIdentifier) {
            if ([child.value isEqualToString:OID]) {
                return child;
            }
        } else {
            ASN1Node *result = [child findOID:OID];
            if (result) {
                return result;
            }
        }
    }
    return nil;
}

- (id)firstLeafValue {
    if (self.sub.count) {
        return self.sub.firstObject.firstLeafValue;
    } else {
        return self.value;
    }
}

- (NSString *)description {
    NSMutableString *output = [NSMutableString string];
    [output appendFormat:@"%@", self.identifier];
    [output appendFormat:@": %@", self.value?:@""];
    if (self.identifier.typeClass == ASN1TypeClassUniversal
        &&
        self.identifier.tagNumber == ASN1TagNumberObjectIdentifier) {
        if (self.value && [ASN1Node map][self.value]) {
            [output appendFormat:@"(%@)", [ASN1Node map][self.value]];
        }
    }
    if (self.sub.count) {
        [output appendFormat:@" {\n"];
        for (ASN1Node *item in self.sub) {
            NSArray *lines = [item.description componentsSeparatedByString:@"\n"];
            for (NSString *line in lines) {
                [output appendFormat:@"\t%@\n", line];
            }
        }
        [output appendString:@"}"];
    }
    return output;
}

+ (NSDictionary *)map {
    return @{
             @"0.4.0.1862.1.1" : @"etsiQcsCompliance",
             @"0.4.0.1862.1.3" : @"etsiQcsRetentionPeriod",
             @"0.4.0.1862.1.4" : @"etsiQcsQcSSCD",
             @"1.2.840.10040.4.1" : @"dsa",
             @"1.2.840.10045.2.1" : @"ecPublicKey",
             @"1.2.840.10045.3.1.7" : @"prime256v1",
             @"1.2.840.10045.4.3.2" : @"ecdsaWithSHA256",
             @"1.2.840.10045.4.3.4" : @"ecdsaWithSHA512",
             @"1.2.840.113549.1.1.1" : @"rsaEncryption",
             @"1.2.840.113549.1.1.4" : @"md5WithRSAEncryption",
             @"1.2.840.113549.1.1.5" : @"sha1WithRSAEncryption",
             @"1.2.840.113549.1.1.11" : @"sha256WithRSAEncryption",
             @"1.2.840.113549.1.7.1" : @"data",
             @"1.2.840.113549.1.7.2" : @"signedData",
             @"1.2.840.113549.1.9.1" : @"emailAddress",
             @"1.2.840.113549.1.9.16.2.47" : @"signingCertificateV2",
             @"1.2.840.113549.1.9.3" : @"contentType",
             @"1.2.840.113549.1.9.4" : @"messageDigest",
             @"1.2.840.113549.1.9.5" : @"signingTime",
             @"1.3.6.1.4.1.11129.2.4.2" : @"certificateExtension",
             @"1.3.6.1.4.1.311.60.2.1.2" : @"jurisdictionOfIncorporationSP",
             @"1.3.6.1.4.1.311.60.2.1.3" : @"jurisdictionOfIncorporationC",
             @"1.3.6.1.5.5.7.1.1" : @"authorityInfoAccess",
             @"1.3.6.1.5.5.7.1.3" : @"qcStatements",
             @"1.3.6.1.5.5.7.2.1" : @"cps",
             @"1.3.6.1.5.5.7.2.2" : @"unotice",
             @"1.3.6.1.5.5.7.3.1" : @"serverAuth",
             @"1.3.6.1.5.5.7.3.2" : @"clientAuth",
             @"1.3.6.1.5.5.7.48.1" : @"ocsp",
             @"1.3.6.1.5.5.7.48.2" : @"caIssuers",
             @"1.3.6.1.5.5.7.9.1" : @"dateOfBirth",
             @"2.16.840.1.101.3.4.2.1" : @"sha-256",
             @"2.16.840.1.113733.1.7.23.6" : @"VeriSign EV policy",
             @"2.23.140.1.1" : @"extendedValidation",
             @"2.23.140.1.2.2" : @"extendedValidation",
             @"2.5.29.14" : @"subjectKeyIdentifier",
             @"2.5.29.15" : @"keyUsage",
             @"2.5.29.17" : @"subjectAltName",
             @"2.5.29.18" : @"issuerAltName",
             @"2.5.29.19" : @"basicConstraints",
             @"2.5.29.31" : @"cRLDistributionPoints",
             @"2.5.29.32" : @"certificatePolicies",
             @"2.5.29.35" : @"authorityKeyIdentifier",
             @"2.5.29.37" : @"extKeyUsage",
             @"2.5.29.9" : @"subjectDirectoryAttributes",
             @"2.5.4.10" : @"organizationName",
             @"2.5.4.11" : @"organizationalUnitName",
             @"2.5.4.15" : @"businessCategory",
             @"2.5.4.17" : @"postalCode",
             @"2.5.4.3" : @"commonName",
             @"2.5.4.4" : @"surname",
             @"2.5.4.42" : @"givenName",
             @"2.5.4.46" : @"dnQualifier",
             @"2.5.4.5" : @"serialNumber",
             @"2.5.4.6" : @"countryName",
             @"2.5.4.7" : @"localityName",
             @"2.5.4.8" : @"stateOrProvinceName",
             @"2.5.4.9" : @"streetAddress"
             };
}

@end
