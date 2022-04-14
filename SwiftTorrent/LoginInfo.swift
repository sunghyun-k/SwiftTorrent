//
//  LoginInfo.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/14.
//

import Foundation

struct LoginInfo: Codable {
    var host: String
    var port: Int?
    var username: String
    var password: String
}
