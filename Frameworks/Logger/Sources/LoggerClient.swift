//
//  LoggerClient.swift
//  Logger
//
//  Created by Ayren King on 12/5/25.
//

import Dependencies
import OSLog

public struct LoggerClient {
    public var log: @Sendable (
        _ category: LoggerCategory,
        _ type: OSLogType,
        _ message: String
    ) -> Void
}

private enum LoggerClientKey: DependencyKey {
    private static let loggers: [LoggerCategory: Logger] = {[
        .networking: Logger(category: .networking),
        .imageLoading: Logger(category: .imageLoading),
        .movieProvider: Logger(category: .movieProvider),
    ]}()

    static var liveValue: LoggerClient {
        let loggers = loggers
        return LoggerClient { category, type, message in
            let logger = loggers[category]
            logger?.log(level: type, "\(message)")
        }
    }

    static var previewValue: LoggerClient { LoggerClient { _, _, _ in /* no-op */ } }
    static var testValue: LoggerClient { LoggerClient { _, _, _ in /* no-op */ } }
}

public extension DependencyValues {
    /// A client for logging messages with different categories and log levels.
    var logger: LoggerClient {
        get { self[LoggerClientKey.self] }
        set { self[LoggerClientKey.self] = newValue }
    }
}


public enum LoggerCategory {
    case networking
    case imageLoading
    case movieProvider

    var categoryName: String {
        switch self {
        case .networking:
            return "Networking"
        case .imageLoading:
            return "ImageLoading"
        case .movieProvider:
            return "MovieProvider"
        }
    }
}
