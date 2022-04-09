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
    
    var estimatedTime: TimeInterval
    var addedOn: Date
    var completionOn: Date
}

extension Torrent {
    mutating func update(_ torrent: TorrentProtocol) {
        guard self.id == torrent.id else {
            return
        }
        if let name = torrent.name {
            self.name = name
        }
        if let state = torrent.state {
            self.state = state
        }
        if let downloadSpeed = torrent.downloadSpeed {
            self.downloadSpeed = downloadSpeed
        }
        if let uploadSpeed = torrent.uploadSpeed {
            self.uploadSpeed = uploadSpeed
        }
        if let size = torrent.size {
            self.size = size
        }
        if let amountLeft = torrent.amountLeft {
            self.amountLeft = amountLeft
        }
        if let completed = torrent.completed {
            self.completed = completed
        }
        if let progress = torrent.progress {
            self.progress = progress
        }
        if let estimatedTime = torrent.estimatedTime {
            self.estimatedTime = Double(estimatedTime)
        }
        if let addedOn = torrent.addedOn {
            self.addedOn = addedOn
        }
        if let completionOn = torrent.completionOn {
            self.completionOn = completionOn
        }
    }
}
