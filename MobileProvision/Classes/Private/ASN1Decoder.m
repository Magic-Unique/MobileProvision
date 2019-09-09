//
//  ASN1Decoder.m
//  MobileProvision_Example
//
//  Created by 冷秋 on 2019/8/31.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "ASN1Decoder.h"

NSUInteger NSData2NSUInteger(NSData *data) {
    if (data.length > 8) { // check if suitable for UInt64
        return 0;
    }
    
    NSUInteger value = 0;
    Byte *bytes = (Byte *)data.bytes;
    for (NSUInteger i = 0; i < data.length; i++) {
        Byte b = bytes[i];
        NSUInteger v = (NSUInteger)b << (NSUInteger)(8 * (data.length - i - 1));
        value += v;
    }
    return value;
}

static Byte NSDataGetByte(NSData *data, NSUInteger index) {
    Byte *bytes = (Byte *)data.bytes;
    if (index >= data.length) {
        return 0;
    } else {
        return bytes[index];
    }
}

static NSData *NSDataRemovePrefix(NSData *data, NSUInteger length) {
    if (data.length == 0) {
        return data;
    }
    NSData *result = [NSData dataWithBytes:data.bytes + length length:data.length - length];
    return result;
}

@interface ASN1DataIterator : NSObject

@property (nonatomic, strong, readonly) NSData *data;

@property (nonatomic, assign, readonly) Byte next;

@property (nonatomic, assign, readonly) BOOL hasNext;

@property (nonatomic, assign, readonly) NSUInteger index;

@property (nonatomic, assign, readonly) NSUInteger length;

- (instancetype)initWithData:(NSData *)data;

@end

@implementation ASN1DataIterator

+ (instancetype)iteratorWithData:(NSData *)data {
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _data = data;
    }
    return self;
}

- (Byte)next {
    if (self.index >= self.length) {
        return 0;
    } else {
        Byte *bytes = (Byte *)self.data.bytes;
        Byte next = bytes[_index++];
        return next;
    }
}

- (BOOL)hasNext {
    if (self.index >= self.length) {
        return NO;
    } else {
        return YES;
    }
}

- (NSUInteger)length {
    return self.data.length;
}

@end

@implementation ASN1Decoder

+ (instancetype)decode:(NSData *)data {
    ASN1Decoder *decoder = [[ASN1Decoder alloc] init];
    [decoder decode:data];
    return decoder;
}

- (void)decode:(NSData *)data {
    ASN1DataIterator *iterator = [ASN1DataIterator iteratorWithData:data];
    _nodes = [self parse:iterator];
}

- (NSArray<ASN1Node *> *)parse:(ASN1DataIterator *)iterator {
    NSMutableArray<ASN1Node *> *result = [NSMutableArray array];
    Byte next = 0;
#define ASN1ReturnIfError if (_error) return nil
    while (iterator.hasNext) {
        next = iterator.next;
        ASN1Node *asn1obj = [ASN1Node new];
        asn1obj.identifier = [[ASN1Identifier alloc] initWithRowValue:next];
        
        if (asn1obj.identifier.isConstructed) {
            NSData *contentData = [self loadSubContent:iterator];
            ASN1ReturnIfError;
            if (contentData.length == 0) {
                asn1obj.sub = [self parse:iterator];
            } else {
                ASN1DataIterator *subIterator = [[ASN1DataIterator alloc] initWithData:contentData];
                asn1obj.sub = [self parse:subIterator];
            }
            ASN1ReturnIfError;
            asn1obj.value = nil;
            asn1obj.rawValue = contentData;
            for (ASN1Node *item in asn1obj.sub) {
                item.parent = asn1obj;
            }
        } else {
            if (asn1obj.identifier.typeClass == ASN1TypeClassUniversal) {
                NSData *contentData = [self loadSubContent:iterator];
                ASN1ReturnIfError;
                
                asn1obj.rawValue = contentData;
                
                // decode the content data with come more convenient format
                switch (asn1obj.identifier.tagNumber) {
                    case ASN1TagNumberEndOfContent:
                        return result;
                    case ASN1TagNumberBoolean: {
                        Byte value = NSDataGetByte(contentData, 0);
                        if (value) {
                            asn1obj.value = @YES;
                        } else {
                            asn1obj.value = @NO;
                        }
                        break;
                    }
                    case ASN1TagNumberInteger:
                        while (contentData.length > 0 && NSDataGetByte(contentData, 0) == 0) {
                            contentData = NSDataRemovePrefix(contentData, 1);
                        }
                        asn1obj.value = contentData;
                        break;
                    case ASN1TagNumberNull:
                        asn1obj.value = nil;
                        break;
                    case ASN1TagNumberObjectIdentifier:
                        asn1obj.value = [self decodeOID:contentData];
                        break;
                    case ASN1TagNumberUtf8String:
                    case ASN1TagNumberPrintableString:
                    case ASN1TagNumberNumericString:
                    case ASN1TagNumberGeneralString:
                    case ASN1TagNumberUniversalString:
                    case ASN1TagNumberCharacterString:
                    case ASN1TagNumberT61String:
                        asn1obj.value = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
                        break;
                    case ASN1TagNumberBmpString:
                        asn1obj.value = [[NSString alloc] initWithData:contentData encoding:NSUnicodeStringEncoding];
                        break;
                    case ASN1TagNumberVisibleString:
                    case ASN1TagNumberIa5String:
                        asn1obj.value = [[NSString alloc] initWithData:contentData encoding:NSASCIIStringEncoding];
                        break;
                    case ASN1TagNumberUtcTime:
                        asn1obj.value = [self dateFormatter:contentData formats:@[@"yyMMddHHmmssZ", @"yyMMddHHmmZ"]];
                        break;
                    case ASN1TagNumberGeneralizedTime:
                        asn1obj.value = [self dateFormatter:contentData formats:@[@"yyyyMMddHHmmssZ"]];
                        break;
                    case ASN1TagNumberBitString:
                        if (contentData.length > 0) {
                            contentData = NSDataRemovePrefix(contentData, 1);
                        }
                        asn1obj.value = contentData;
                        break;
                    case ASN1TagNumberOctetString: {
                        ASN1DataIterator *subIterator = [[ASN1DataIterator alloc] initWithData:contentData];
                        asn1obj.sub = [self parse:subIterator];
                        if (_error) {
                            NSString *str = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
                            if (str) {
                                asn1obj.value = str;
                            } else {
                                asn1obj.value = contentData;
                            }
                            _error = nil;
                        }
                        break;
                    }
                    default:
                        //                        print("unsupported tag: \(asn1obj.identifier!.tagNumber())")
                        asn1obj.value = contentData;
                }
            } else {
                // custom/private tag
                NSData *contentData = [self loadSubContent:iterator];
                ASN1ReturnIfError;
                NSString *str = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
                if (str) {
                    asn1obj.value = str;
                } else {
                    asn1obj.value = contentData;
                }
            }
        }
        [result addObject:asn1obj];
    }
    return result;
}


// Decode the number of bytes of the content
- (NSUInteger)getContentLength:(ASN1DataIterator *)iterator {
    if (!iterator.hasNext) {
        return 0;
    }
    
    Byte first = iterator.next;
    if ((first & 0x80) != 0) { // long
        Byte octetsToRead = first - 0x80;
        NSMutableData *data = [NSMutableData data];
        for (NSUInteger i = 0; i < octetsToRead; i++) {
            if (iterator.hasNext) {
                Byte n = iterator.next;
                [data appendBytes:&n length:1];
            }
        }
        return NSData2NSUInteger(data);
    } else { // short
        return (NSUInteger)first;
    }
}

- (NSData *)loadSubContent:(ASN1DataIterator *)iterator {
    NSUInteger len = [self getContentLength:iterator];
    
    if (len > NSIntegerMax) {
        return [NSData data];
    }
    
    NSMutableData *byteArray = [NSMutableData data];
    
    for (NSUInteger i = 0; i < len; i++) {
        if (iterator.hasNext) {
            Byte n = iterator.next;
            [byteArray appendBytes:&n length:1];
        } else {
            _error = [NSError errorWithDomain:@"my" code:1 userInfo:@{}];
            return nil;
        }
    }
    return byteArray;
}

// Decode DER OID bytes to String with dot notation
- (NSString *)decodeOID:(NSData *)contentData {
    if (contentData.length == 0) {
        return @"";
    }
    
    Byte *bytes = (Byte *)contentData.bytes;
    
    NSMutableString *OID = [NSMutableString string];
    NSInteger first = (NSInteger)bytes[0];
    [OID appendFormat:@"%@.%@", @(first / 40), @(first % 40)];
    
    NSUInteger t = 0;
    for (NSUInteger i = 1; i < contentData.length; i++) {
        NSInteger n = (NSInteger)bytes[i];
        t = (t << 7) | (n & 0x7F);
        if ((n & 0x80) == 0) {
            [OID appendFormat:@".%@", @(t)];
            t = 0;
        }
    }
    return OID;
}

- (NSDate *)dateFormatter:(NSData *)data formats:(NSArray<NSString *> *)formats {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (str) {
        for (NSString *format in formats) {
            self.dateFormatter.dateFormat = format;
            NSDate *dt = [self.dateFormatter dateFromString:str];
            if (dt) {
                return dt;
            }
        }
    }
    return nil;
}

@synthesize dateFormatter = _dateFormatter;
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    }
    return _dateFormatter;
}

@end
