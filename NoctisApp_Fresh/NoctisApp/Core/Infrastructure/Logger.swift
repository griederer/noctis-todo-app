import Foundation
import os.log

class Logger {
    static let shared = Logger()
    
    private let subsystem = Bundle.main.bundleIdentifier ?? "com.noctis.app"
    private let categoryGeneral = "General"
    private let categoryAuth = "Authentication"
    private let categoryData = "Data"
    private let categoryUI = "UI"
    private let categoryNetwork = "Network"
    
    private lazy var generalLogger = OSLog(subsystem: subsystem, category: categoryGeneral)
    private lazy var authLogger = OSLog(subsystem: subsystem, category: categoryAuth)
    private lazy var dataLogger = OSLog(subsystem: subsystem, category: categoryData)
    private lazy var uiLogger = OSLog(subsystem: subsystem, category: categoryUI)
    private lazy var networkLogger = OSLog(subsystem: subsystem, category: categoryNetwork)
    
    private init() {}
    
    // MARK: - General Logging
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        os_log("%{public}@:%d %{public}@() - %{public}@", log: generalLogger, type: .debug, fileName, line, function, message)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        os_log("%{public}@:%d %{public}@() - %{public}@", log: generalLogger, type: .info, fileName, line, function, message)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        os_log("%{public}@:%d %{public}@() - %{public}@", log: generalLogger, type: .error, fileName, line, function, message)
    }
    
    func fault(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        os_log("%{public}@:%d %{public}@() - %{public}@", log: generalLogger, type: .fault, fileName, line, function, message)
    }
    
    // MARK: - Category-specific Logging
    func authInfo(_ message: String) {
        os_log("%{public}@", log: authLogger, type: .info, message)
    }
    
    func authError(_ message: String) {
        os_log("%{public}@", log: authLogger, type: .error, message)
    }
    
    func dataInfo(_ message: String) {
        os_log("%{public}@", log: dataLogger, type: .info, message)
    }
    
    func dataError(_ message: String) {
        os_log("%{public}@", log: dataLogger, type: .error, message)
    }
    
    func uiInfo(_ message: String) {
        os_log("%{public}@", log: uiLogger, type: .info, message)
    }
    
    func networkInfo(_ message: String) {
        os_log("%{public}@", log: networkLogger, type: .info, message)
    }
    
    func networkError(_ message: String) {
        os_log("%{public}@", log: networkLogger, type: .error, message)
    }
}