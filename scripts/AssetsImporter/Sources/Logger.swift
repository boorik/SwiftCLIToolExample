
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier ?? "no bundle identifier"
    static let importer = Logger(subsystem: subsystem, category: "importer")
}
