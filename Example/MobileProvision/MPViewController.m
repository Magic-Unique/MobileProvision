//
//  MPViewController.m
//  MobileProvision
//
//  Created by 冷秋 on 08/30/2019.
//  Copyright (c) 2019 Magic-Unique. All rights reserved.
//

#import "MPViewController.h"
#import <MobileProvision/MPProvision.h>

@interface MPViewController ()

@property (nonatomic, strong, readonly) MPProvision *provision;

@end

@implementation MPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _provision = [MPProvision embeddedMobileProvision];
//    _provision = [MPProvision localMobileProvision];
    MPCertificate *certificate = _provision.DeveloperCertificates.firstObject;
    NSLog(@"%@",_provision.ApplicationIdentifierPrefix);
    
//    Byte *bytes = (Byte *)data.bytes;
//    X509 *m_pX509 = d2i_X509(NULL, (const unsigned char **)&bytes, data.length);
//    if (m_pX509) {
//        NSLog(@"Success");
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//        NSLog(@"%@", formatter.timeZone.name);
//        NSLog(@"%@", [formatter stringFromDate:NSDateFromASN1(X509_get_notBefore(m_pX509))]);
//        NSLog(@"%@", [formatter stringFromDate:NSDateFromASN1(X509_get_notAfter(m_pX509))]);
//    } else {
//        NSLog(@"Failed");
//    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
