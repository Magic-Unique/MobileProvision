//
//  MPViewController.m
//  MobileProvision
//
//  Created by 冷秋 on 08/30/2019.
//  Copyright (c) 2019 Magic-Unique. All rights reserved.
//

#import "MPViewController.h"
#import <MobileProvision/MobileProvision.h>


@interface LDCodeSignItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *value;
@end
@implementation LDCodeSignItem @end

static LDCodeSignItem *LDCodeSignMakeItem(NSString *title, NSString *value) {
    LDCodeSignItem *item = [LDCodeSignItem new];
    item.title = title;
    item.value = value;
    return item;
}

@interface MPViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, readonly) UITableView *tableView;

@property (nonatomic, strong, readonly) MPProvision *provision;

@property (nonatomic, strong, readonly) NSArray *provisionInfos;
@property (nonatomic, strong, readonly) NSArray *certificateInfos;
@property (nonatomic, strong, readonly) NSArray *entitlementsInfos;
@property (nonatomic, strong, readonly) NSArray *deviceInfos;
@property (nonatomic, assign, readonly) BOOL displayDeviceList;

@property (nonatomic, strong, readonly) NSDateFormatter *dateFormatter;

@end

@implementation MPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Provision";
    
    self.tableView.frame = self.view.frame;
    [self.view addSubview:self.tableView];
    
    _provision = [MPProvision embeddedProvision];
    
    if (_provision) {
        NSMutableArray *provisionInfos = [NSMutableArray array];
        [provisionInfos addObject:LDCodeSignMakeItem(@"Provision Name", _provision.Name)];
        [provisionInfos addObject:LDCodeSignMakeItem(@"App ID Name", _provision.AppIDName)];
        [provisionInfos addObject:LDCodeSignMakeItem(@"Team Name", _provision.TeamName)];
        [provisionInfos addObject:LDCodeSignMakeItem(@"Team Identifier",({
            [[_provision.TeamIdentifier valueForKeyPath:@"description"] componentsJoinedByString:@", "];
        }))];
        [provisionInfos addObject:LDCodeSignMakeItem(@"Creation Date", ({
            [self.dateFormatter stringFromDate:_provision.CreationDate];
        }))];
        [provisionInfos addObject:LDCodeSignMakeItem(@"Expiration Date", ({
            [self.dateFormatter stringFromDate:_provision.ExpirationDate];
        }))];
        [provisionInfos addObject:LDCodeSignMakeItem(@"UUID", _provision.UUID)];
        _provisionInfos = [provisionInfos copy];
        
        NSMutableArray *certificateInfos = [NSMutableArray arrayWithCapacity:_provision.DeveloperCertificates.count];
        for (MPCertificate *certificate in _provision.DeveloperCertificates) {
            NSMutableArray *array = [NSMutableArray array];
            [array addObject:LDCodeSignMakeItem(@"Common Name", certificate.subject.commonName)];
            [array addObject:LDCodeSignMakeItem(@"Subject Name", certificate.subject.name)];
            [array addObject:LDCodeSignMakeItem(@"Serial Number", certificate.serialNumber)];
            [array addObject:LDCodeSignMakeItem(@"Not Before", [self.dateFormatter stringFromDate:certificate.validity.notBefore])];
            [array addObject:LDCodeSignMakeItem(@"Not After", [self.dateFormatter stringFromDate:certificate.validity.notAfter])];
            [array addObject:LDCodeSignMakeItem(@"SHA1", certificate.fingerprints.SHA1)];
            [certificateInfos addObject:array];
        }
        _certificateInfos = [certificateInfos copy];
        
        NSMutableArray *entitlementsInfos = [NSMutableArray array];
        [self.provision.Entitlements.JSON enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            LDCodeSignItem *item = [[LDCodeSignItem alloc] init];
            item.title = key;
            if ([obj isKindOfClass:[NSArray class]]) {
                NSMutableArray *list = [NSMutableArray array];
                for (id value in obj) {
                    [list addObject:[NSString stringWithFormat:@"%@", value]];
                }
                item.value = [list componentsJoinedByString:@", "];
            } else if ([obj isKindOfClass:[NSNumber class]]) {
                NSNumber *number = obj;
                if (strcmp(number.objCType, @encode(char)) == 0) {
                    item.value = number.boolValue ? @"true" : @"false";
                } else {
                    item.value = [NSString stringWithFormat:@"%@", obj];
                }
            } else {
                item.value = [NSString stringWithFormat:@"%@", obj];
            }
            [entitlementsInfos addObject:item];
        }];
        _entitlementsInfos = [entitlementsInfos copy];
        
        NSMutableArray *deviceInfos = [NSMutableArray array];
        if (self.provision.ProvisionedDevices) {
            NSArray *devices = [self.provision.ProvisionedDevices sortedArrayUsingSelector:@selector(compare:)];
            NSString *lastChar = nil;
            for (NSString *device in devices) {
                LDCodeSignItem *item = [[LDCodeSignItem alloc] init];
                NSString *currentChar = [device substringWithRange:NSMakeRange(0, 1)];
                if (![currentChar isEqualToString:lastChar]) {
                    lastChar = currentChar;
                    item.title = [NSString stringWithFormat:@"%@: %@", currentChar, device];
                } else {
                    item.title = [NSString stringWithFormat:@"   %@", device];
                }
                [deviceInfos addObject:item];
            }
            _displayDeviceList = YES;
        } else {
            LDCodeSignItem *item = [[LDCodeSignItem alloc] init];
            item.title = @"Support All Devices";
            item.value = self.provision.ProvisionsAllDevices ? @"true" : @"false";
            [deviceInfos addObject:item];
            _displayDeviceList = NO;
        }
        _deviceInfos = [deviceInfos copy];
    } else {
        UILabel *label = [UILabel new];
        label.text = @"Can not read the provision.";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        label.font = [UIFont fontWithName:@"Heiti" size:23];
        self.tableView.backgroundView = label;
    }
}

- (id)switchSection:(NSInteger)section
      caseProvision:(id (^)(MPProvision *provision))caseProvision
    caseCertificate:(id (^)(MPCertificate *certificate))caseCertificate
   caseEntitlements:(id (^)(MPEntitlements *entitlements))caseEntitlements
         caseDevice:(id (^)(NSArray *devices, BOOL ProvisionsAllDevices))caseDevice {
    if (section == 0) {
        return !caseProvision?nil:caseProvision(self.provision);
    }
    if (section <= self.certificateInfos.count) {
        MPCertificate *certificate = self.provision.DeveloperCertificates[section - 1];
        return !caseCertificate?nil:caseCertificate(certificate);
    }
    if (section == self.certificateInfos.count + 1) {
        return !caseEntitlements?nil:caseEntitlements(self.provision.Entitlements);
    }
    return !caseDevice?nil:caseDevice(self.provision.ProvisionedDevices, self.provision.ProvisionsAllDevices);
}

- (UITableViewCell *)dequeueSubvalueStyleCell {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SUBVALUE"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SUBVALUE"];
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    }
    return cell;
}

- (CGFloat)heightForSubvalueStyleCell {
    return 65;
}

#pragma mark -  Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.provision) {
        return 3 + self.certificateInfos.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSNumber *number = [self switchSection:section caseProvision:^id(MPProvision *provision) {
        return @(self.provisionInfos.count);
    } caseCertificate:^id(MPCertificate *certificate) {
        NSArray *certInfo = self.certificateInfos[section - 1];
        return @(certInfo.count);
    } caseEntitlements:^id(MPEntitlements *entitlements) {
        return @(self.entitlementsInfos.count);
    } caseDevice:^id(NSArray *devices, BOOL ProvisionsAllDevices) {
        return @(self.deviceInfos.count);
    }];
    return number.integerValue;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self switchSection:section caseProvision:^id(MPProvision *provision) {
        return @"Provision";
    } caseCertificate:^id(MPCertificate *certificate) {
        return @"Certificate";
    } caseEntitlements:^id(MPEntitlements *entitlements) {
        return @"Entitlements";
    } caseDevice:^id(NSArray *devices, BOOL ProvisionsAllDevices) {
        return @"Devices";
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *height = [self switchSection:indexPath.section caseProvision:^id(MPProvision *provision) {
        return @([self heightForSubvalueStyleCell]);
    } caseCertificate:^id(MPCertificate *certificate) {
        return @([self heightForSubvalueStyleCell]);
    } caseEntitlements:^id(MPEntitlements *entitlements) {
        return @([self heightForSubvalueStyleCell]);
    } caseDevice:^id(NSArray *devices, BOOL ProvisionsAllDevices) {
        return self.displayDeviceList ? @(25) : @(44);
    }];
    return height.doubleValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
#define LDToString(obj) [NSString stringWithFormat:@"%@", obj]
    return [self switchSection:indexPath.section caseProvision:^id(MPProvision *provision) {
        UITableViewCell *cell = [self dequeueSubvalueStyleCell];
        LDCodeSignItem *provisionInfo = self.provisionInfos[indexPath.row];
        NSString *title = provisionInfo.title;
        NSString *value = provisionInfo.value;
        cell.textLabel.text = title;
        cell.detailTextLabel.text = LDToString(value);
        return cell;
    } caseCertificate:^id(MPCertificate *certificate) {
        UITableViewCell *cell = [self dequeueSubvalueStyleCell];
        LDCodeSignItem *provisionInfo = self.certificateInfos[indexPath.section - 1][indexPath.row];
        NSString *title = provisionInfo.title;
        NSString *value = provisionInfo.value;
        cell.textLabel.text = title;
        cell.detailTextLabel.text = LDToString(value);
        return cell;
    } caseEntitlements:^id(MPEntitlements *entitlements) {
        UITableViewCell *cell = [self dequeueSubvalueStyleCell];
        LDCodeSignItem *provisionInfo = self.entitlementsInfos[indexPath.row];
        NSString *title = provisionInfo.title;
        NSString *value = provisionInfo.value;
        cell.textLabel.text = title;
        cell.detailTextLabel.text = LDToString(value);
        return cell;
    } caseDevice:^id(NSArray *devices, BOOL ProvisionsAllDevices) {
        if (self.displayDeviceList) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DEVICE"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DEVICE"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.font = [UIFont fontWithName:@"Courier" size:13];
            }
            LDCodeSignItem *provisionInfo = self.deviceInfos[indexPath.row];
            NSString *title = provisionInfo.title;
            cell.textLabel.text = title;
            if (@available(iOS 13.0, *)) {
                cell.backgroundColor = indexPath.row % 2 ? [UIColor secondarySystemBackgroundColor] : [UIColor tertiarySystemBackgroundColor];
            } else {
                cell.backgroundColor = indexPath.row % 2 ? [UIColor colorWithWhite:0.96 alpha:1] : [UIColor whiteColor];
            }
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ALL_DEVICE"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ALL_DEVICE"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            LDCodeSignItem *provisionInfo = self.deviceInfos[indexPath.row];
            cell.textLabel.text = provisionInfo.title;
            cell.detailTextLabel.text = provisionInfo.value;
            return cell;
        }
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [self switchSection:section caseProvision:^id(MPProvision *provision) {
        return nil;
    } caseCertificate:^id(MPCertificate *certificate) {
        return nil;
    } caseEntitlements:^id(MPEntitlements *entitlements) {
        return nil;
    } caseDevice:^id(NSArray *devices, BOOL ProvisionsAllDevices) {
        if (self.displayDeviceList) {
            return [NSString stringWithFormat:@"Support %@ devices", @(self.deviceInfos.count)];
        } else {
            return self.provision.ProvisionsAllDevices ? @"Support all devices" : @"Unsupport device";
        }
    }];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - lazy init

@synthesize tableView = _tableView;
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = UIColor.clearColor;
    }
    return _tableView;
}

@synthesize dateFormatter = _dateFormatter;
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return _dateFormatter;
}

@end

