//
//  MPProvision.m
//  RingTone
//
//  Created by 冷秋 on 2017/1/19.
//  Copyright © 2017年 Magic-Unique. All rights reserved.
//

#import "MPProvision.h"
#import "MPEntitlements.h"
#import "MPCertificate.h"

@implementation MPProvision

@synthesize JSON = _JSON;

+ (instancetype)embeddedProvision {
    NSString *path = [NSBundle.mainBundle pathForResource:@"embedded" ofType:@"mobileprovision"];
    if (path) {
        return [self provisionWithContentsOfFile:path];
    } else {
        return nil;
    }
}

+ (instancetype)provisionWithContentsOfFile:(NSString *)file {
	NSDictionary *JSON = [self __serializeDataWithFile:file];
	if (!JSON) {
		return nil;
	}
	return [[self alloc] initWithDictionary:JSON];
}

+ (NSDictionary *)__serializeDataWithFile:(NSString *)file {
    NSDictionary *mobileprovision = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        @autoreleasepool {
            NSData *data = [NSData dataWithContentsOfFile:file];
            NSRange dataRange = NSMakeRange(0, data.length);
            
            NSString *prefix = @"<plist";
            NSString *suffix = @"plist>";
            NSRange prefixRange = [data rangeOfData:[prefix dataUsingEncoding:NSUTF8StringEncoding]
                                            options:kNilOptions
                                              range:dataRange];
            NSRange suffixRange = [data rangeOfData:[suffix dataUsingEncoding:NSUTF8StringEncoding]
                                            options:kNilOptions
                                              range:dataRange];
            NSRange enableRange;
            enableRange.location = prefixRange.location;
            enableRange.length = NSMaxRange(suffixRange) - enableRange.location;
            
            NSData *plist = [data subdataWithRange:enableRange];
            mobileprovision = [NSPropertyListSerialization propertyListWithData:plist
                                                                        options:kNilOptions
                                                                         format:NULL
                                                                          error:nil];
        }
    }
    return mobileprovision;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
#define SetVar(k) _##k = dictionary[@#k]
        SetVar(AppIDName);
        SetVar(ApplicationIdentifierPrefix);
        SetVar(CreationDate);
        SetVar(ExpirationDate);
        SetVar(Name);
        SetVar(Platform);
        SetVar(ProvisionedDevices);
        SetVar(TeamIdentifier);
        SetVar(TeamName);
        SetVar(UUID);
#undef SetVar
        _ProvisionsAllDevices = [dictionary[@"ProvisionsAllDevices"] boolValue];
        _TimeToLive = [dictionary[@"TimeToLive"] unsignedIntegerValue];
        _Version = [dictionary[@"Version"] unsignedIntegerValue];
        _JSON = dictionary;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p %@>", [self class], self, self.JSON];
}

@synthesize DeveloperCertificates = _DeveloperCertificates;
- (NSArray<MPCertificate *> *)DeveloperCertificates {
    if (!_DeveloperCertificates) {
        NSArray<NSData *> *datas = self.JSON[@"DeveloperCertificates"];
        if (datas) {
            NSMutableArray *certs = nil;
            certs = [NSMutableArray arrayWithCapacity:datas.count];
            for (NSData *data in datas) {
                MPCertificate *cert = [MPCertificate certificateWithData:data];
                [certs addObject:cert];
            }
            _DeveloperCertificates = [certs copy];
        }
    }
    return _DeveloperCertificates;
}

@synthesize Entitlements = _Entitlements;
- (MPEntitlements *)Entitlements {
    if (!_Entitlements) {
        _Entitlements = [MPEntitlements entitlementsWithDictionary:self.JSON[@"Entitlements"]];
    }
    return _Entitlements;
}

@end
