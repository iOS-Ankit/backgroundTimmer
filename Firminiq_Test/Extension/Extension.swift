//
//  Extension.swift
//  Firminiq_Test
//
//  Created by Ankit on 12/02/21.
//

import Foundation

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension Int64 {
    var miliSecondsToSeconds: Double { Double(self) / 1000 }
}

