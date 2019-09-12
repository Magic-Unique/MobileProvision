//
//  main.m
//  MobileProvisionCLI
//
//  Created by 冷秋 on 2019/9/3.
//  Copyright © 2019 冷秋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileProvision/MobileProvision.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *path = @"embedded.mobileprovision";
        MPProvision *provision = [MPProvision provisionWithContentsOfFile:path];
        NSLog(@"%@",provision);
    }
    return 0;
}
