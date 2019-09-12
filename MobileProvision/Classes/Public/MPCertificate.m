//
//  MPCertificate.m
//  MobileProvisionTool
//
//  Created by Magic-Unique on 2018/6/10.
//  Copyright © 2018年 Magic-Unique. All rights reserved.
//

#import "MPCertificate.h"
#import "X509Certificate.h"
#import "ASN1Decoder.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MPValidity

- (void)setNotBefore:(NSDate *)notBefore {
    _notBefore = notBefore;
}

- (void)setNotAfter:(NSDate *)notAfter {
    _notAfter = notAfter;
}

- (NSDictionary *)JSON {
    NSMutableDictionary *JSON = [NSMutableDictionary dictionary];
    JSON[@"notBefore"] = self.notBefore;
    JSON[@"notAfter"] = self.notAfter;
    return JSON;
}

@end


@implementation MPFingerprints

- (void)setSHA1:(NSString *)SHA1 {
    _SHA1 = [SHA1 copy];
}

- (void)setSHA256:(NSString *)SHA256 {
    _SHA256 = [SHA256 copy];
}

- (NSDictionary *)JSON {
    NSMutableDictionary *JSON = [NSMutableDictionary dictionary];
    JSON[@"SHA1"] = self.SHA1;
    JSON[@"SHA256"] = self.SHA256;
    return JSON;
}

@end

@implementation MPOrganization

@synthesize JSON = _JSON;

- (NSString *)name {
    return self.JSON[@"2.5.4.10"];
}

- (NSString *)unitName {
    return self.JSON[@"2.5.4.11"];
}

- (NSString *)commonName {
    return self.JSON[@"2.5.4.3"];
}

- (NSString *)countryName {
    return self.JSON[@"2.5.4.6"];
}

- (instancetype)initWithJSON:(NSDictionary *)JSON {
    self = [super init];
    if (self) {
        _JSON = [JSON copy];
    }
    return self;
}

@end

static NSString *MPSHA1FromData(NSData *data) {
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return [output copy];
}

static NSString *MPSHA256FromData(NSData *data) {
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (unsigned int)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i=0; i<CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return [output copy];
}

@interface MPCertificate () {
    X509Certificate *_certificate;
}
@end

@implementation MPCertificate

- (instancetype)initWithX509Certificate:(X509Certificate *)certificate {
    self = [super init];
    if (self) {
        _certificate = certificate;
        @try {
            [self read];
        } @catch (NSException *exception) {} @finally {}
    }
    return self;
}

- (void)read {
    _version = NSData2NSUInteger(_certificate.block1.firstLeafValue) + 1;
    _serialNumber = ({
        NSData *data = _certificate.block1.sub[X509BlockPositionSerialNumber].value;
        NSString *serialNumber = data.description;
        serialNumber = [serialNumber stringByReplacingOccurrencesOfString:@"<" withString:@""];
        serialNumber = [serialNumber stringByReplacingOccurrencesOfString:@">" withString:@""];
        serialNumber = [serialNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        serialNumber;
    });
    
    _validity = [[MPValidity alloc] init];
    _validity.notBefore = _certificate.block1.sub[X509BlockPositionDateValidity].sub[0].value;
    _validity.notAfter = _certificate.block1.sub[X509BlockPositionDateValidity].sub[1].value;
    
    _issuer = ({
        NSMutableDictionary *names = [NSMutableDictionary dictionary];
        ASN1Node *subject = _certificate.block1.sub[X509BlockPositionIssuer];
        for (ASN1Node *sub in subject.sub) {
            NSString *OID = sub.firstLeafValue;
            NSString *name = [self issuerWithOID:OID];
            names[OID] = name;
        }
        [[MPOrganization alloc] initWithJSON:names];
    });
    
    _subject = ({
        NSMutableDictionary *names = [NSMutableDictionary dictionary];
        ASN1Node *subject = _certificate.block1.sub[X509BlockPositionSubject];
        for (ASN1Node *sub in subject.sub) {
            NSString *OID = sub.firstLeafValue;
            NSString *name = [self subjectNameWithOID:OID];
            names[OID] = name;
        }
        [[MPOrganization alloc] initWithJSON:names];
    });
    
    _signature = _certificate.asn1[0].sub[2].value;
    
    _name = self.subject.name;
    
    _fingerprints = [[MPFingerprints alloc] init];
    _fingerprints.SHA1 = MPSHA1FromData(self.data);
    _fingerprints.SHA256 = MPSHA256FromData(self.data);
}

+ (instancetype)certificateWithData:(NSData *)data {
    X509Certificate *certificate = nil;
    @try {
        certificate = [X509Certificate certificateWithData:data];
    } @catch (NSException *exception) {} @finally {}
    
    if (certificate) {
        return [[self alloc] initWithX509Certificate:certificate];
    } else {
        return nil;
    }
}

- (BOOL)isValid {
    return [self isValid:[NSDate date]];
}

- (BOOL)isValid:(NSDate *)date {
    BOOL valid = YES;
    valid &= date.timeIntervalSince1970 > self.validity.notBefore.timeIntervalSince1970;
    valid &= date.timeIntervalSince1970 < self.validity.notAfter.timeIntervalSince1970;
    return valid;
}

- (NSString *)issuerWithOID:(NSString *)OID {
    ASN1Node *subject = _certificate.block1.sub[X509BlockPositionIssuer];
    ASN1Node *find = [subject findOID:OID];
    return find.parent.sub.lastObject.value;
}

- (NSString *)subjectNameWithOID:(NSString *)OID {
    ASN1Node *subject = _certificate.block1.sub[X509BlockPositionSubject];
    ASN1Node *find = [subject findOID:OID];
    return find.parent.sub.lastObject.value;
}

- (NSData *)data {
    return _certificate.data;
}

- (NSDictionary *)JSON {
    NSMutableDictionary *JSON = [NSMutableDictionary dictionary];
    JSON[@"name"] = self.name;
    JSON[@"version"] = @(self.version);
    JSON[@"serialNumber"] = self.serialNumber;
    JSON[@"validity"] = self.validity.JSON;
    JSON[@"fingerprints"] = self.fingerprints.JSON;
    JSON[@"issuerNames"] = self.issuer.JSON;
    JSON[@"subjectNames"] = self.subject.JSON;
    JSON[@"signature"] = self.signature;
    return [JSON copy];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p %@>", [self class], self, self.JSON];
}

@end
