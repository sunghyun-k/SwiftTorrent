//
//  Int+ByteFormatter.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/08.
//

import Foundation
private let formatter: ByteCountFormatter = {
    let formatter = ByteCountFormatter()
    formatter.allowsNonnumericFormatting = false
    
    return formatter
}()
extension Int {
    var byteFormat: String {
        return formatter.string(fromByteCount: Int64(self)).replacingOccurrences(of: " ", with: "")
    }
}
