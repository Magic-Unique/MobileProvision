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

@implementation MPValidity

- (void)setNotBefore:(NSDate *)notBefore {
    _notBefore = notBefore;
}

- (void)setNotAfter:(NSDate *)notAfter {
    _notAfter = notAfter;
}

@end


@interface MPCertificate () {
    X509Certificate *_certificate;
}
@end

@implementation MPCertificate

@synthesize JSON = _JSON;

- (instancetype)initWithX509Certificate:(X509Certificate *)certificate {
    self = [super init];
    if (self) {
        _certificate = certificate;
        @try {
            [self read];
            [self write];
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
    
    _issuerNames = ({
        NSMutableDictionary *names = [NSMutableDictionary dictionary];
        ASN1Node *subject = _certificate.block1.sub[X509BlockPositionIssuer];
        for (ASN1Node *sub in subject.sub) {
            NSString *OID = sub.firstLeafValue;
            NSString *name = [self issuerWithOID:OID];
            names[OID] = name;
        }
        names;
    });
    
    _subjectNames = ({
        NSMutableDictionary *names = [NSMutableDictionary dictionary];
        ASN1Node *subject = _certificate.block1.sub[X509BlockPositionSubject];
        for (ASN1Node *sub in subject.sub) {
            NSString *OID = sub.firstLeafValue;
            NSString *name = [self subjectNameWithOID:OID];
            names[OID] = name;
        }
        names;
    });
    
    _signature = _certificate.asn1[0].sub[2].value;
    
    _name = self.subjectNames[@"2.5.4.3"];
}

- (void)write {
    NSMutableDictionary *JSON = [NSMutableDictionary dictionary];
    JSON[@"name"] = self.name;
    JSON[@"version"] = @(self.version);
    JSON[@"serialNumber"] = self.serialNumber;
    JSON[@"validity"] = ({
        NSMutableDictionary *validity = [NSMutableDictionary dictionary];
        validity[@"notBefore"] = self.validity.notBefore;
        validity[@"notAfter"] = self.validity.notAfter;
        validity;
    });
    JSON[@"issuerNames"] = self.issuerNames;
    JSON[@"subjectNames"] = self.subjectNames;
    JSON[@"signature"] = self.signature;
    _JSON = [JSON copy];
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

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p %@>", [self class], self, self.JSON];
}

@end
