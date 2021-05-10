//
//  File.swift
//  
//
//  Created by 吴双 on 2021/5/10.
//

import Foundation
import MobileProvision

let path = "/Users/wushuang/Library/Mobile Documents/com~apple~CloudDocs/Certificates/1-MUAD/Wildcard_MU1.mobileprovision"

let data = try Data(contentsOf: URL(fileURLWithPath: path))

let cer = try X509Certificate(data: data)
print(cer)
