
import Foundation

public struct Provision {
    
    public struct Certificate {
        
    }
    
    public struct Entitlements {
        
    }
    
    public let AppIDName: String = { "" }()
    public let ApplicationIdentifierPrefix: [String] = { [] }()
    
    public let CreationDate: Date = { Date() }()
    public let ExpirationDate: Date = { Date() }()
    
    public let DeveloperCertificates: [Certificate] = { [] }()
    public let Entitlements: Entitlements? = { nil }()

    public let Name: String = { "" }()

    public let Platform: [String] = { [] }()

    /** Enable in Enterprice */
    public let ProvisionsAllDevices: Bool = { false }()

    /** Enable in Development */
    public let ProvisionedDevices: [String] = { [] }()

    public let TeamIdentifier: [String] = { [] }()

    public let TeamName: String = { "" }()

    public let TimeToLive: TimeInterval = { 0 }()

    public let uuid: UUID = { UUID() }()

    public let Version: UInt = 0
    
    #if os(iOS)
    public static var embedded: Provision? { .init(contentsOf: Bundle.main.bundlePath + "/embedded.mobileprovision") }
    #endif
    
    public init?(contentsOf path: String) {
        guard FileManager.default.fileExists(atPath: path) else {
            return nil
        }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return nil
        }
        
        data.range
        guard let prefix = data.range(of: "<plist".data(using: .utf8)!),
              let suffix = data.range(of: "plist>".data(using: .utf8)!) else {
            return nil
        }
        let range = prefix + suffix
        let subdata = data.subdata(in: <#T##Range<Data.Index>#>)
        return nil
    }
}
