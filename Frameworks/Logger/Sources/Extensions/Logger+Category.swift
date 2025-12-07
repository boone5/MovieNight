//
//  Logger+Category.swift
//  Logger
//
//  Created by Ayren King on 12/5/25.
//

import OSLog

extension Logger {
    init(category: LoggerCategory) {
        self.init(subsystem: ProcessInfo.processInfo.processName, category: category.categoryName)
    }
}
