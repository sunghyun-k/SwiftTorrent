//
//  Data+String.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/12.
//

import Foundation


extension Data {
    static func +=(data: inout Data, string: String) {
        if let stringData = string.data(using: .utf8) {
            data.append(stringData)
        }
    }
}
