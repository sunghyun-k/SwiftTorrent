//
//  Torrent.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/09.
//

import Foundation

struct Torrent: Identifiable {
    
    var id: String
    var name: String
    
    enum State {
        case error
        case uploading
        case finished
        case checking
        case downloading
        case paused
        case unknown
    }
    var state: State
    
    /// bytes/s
    var downloadSpeed: Int
    /// bytes/s
    var uploadSpeed: Int
    
    /// bytes
    var size: Int
    /// bytes
    var amountLeft: Int
    /// bytes
    var completed: Int
    /// percentage/100
    var progress: Float
    
    var eta: TimeInterval
    var addedOn: Date
    var completionOn: Date
}

