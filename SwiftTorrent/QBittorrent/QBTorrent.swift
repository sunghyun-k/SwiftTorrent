//
//  QBTorrent.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/07.
//

import Foundation

struct QBTorrent {
    private let data: QBTorrentResponse
    init(_ data: QBTorrentResponse) {
        self.data = data
    }
}

extension QBTorrent: TorrentProtocol {
    var addedOn: Date {
        data.addedOn
    }
    
    var amountLeft: Int {
        data.amountLeft
    }
    
    var completed: Int {
        data.completed
    }
    
    var completionOn: Date {
        data.completionOn
    }
    
    var downloadSpeed: Int {
        data.dlspeed
    }
    
    var eta: TimeInterval {
        TimeInterval(data.eta)
    }
    
    var id: String {
        data.hash
    }
    
    var name: String {
        data.name
    }
    
    var progress: Float {
        data.progress
    }
    
    var size: Int {
        data.size
    }
    
    var state: TorrentState {
        .error
    }
    
    var uploadSpeed: Int {
        data.upspeed
    }
    
}

struct QBTorrentResponse: Decodable {
    let addedOn: Date
    let amountLeft: Int
    let autoTmm: Bool
    let availability: Double
    let category: String
    let completed: Int
    let completionOn: Date
    let contentPath: String
    let dlLimit, dlspeed, downloaded, downloadedSession: Int
    let eta: Int
    let fLPiecePrio, forceStart: Bool
    let hash: String
    let lastActivity: Date
    let magnetURI: String
    let maxRatio: Float
    let maxSeedingTime: Int
    let name: String
    let numComplete, numIncomplete, numLeechs, numSeeds: Int
    let priority: Int
    let progress: Float
    let ratio, ratioLimit: Float
    let savePath: String
    let seedingTime, seedingTimeLimit: Int
    let seenComplete: Date
    let seqDL: Bool
    let size: Int
    let state: String
    let superSeeding: Bool
    let tags: String
    let timeActive, totalSize: Int
    let tracker: String
    let trackersCount, upLimit, uploaded, uploadedSession: Int
    let upspeed: Int

    enum CodingKeys: String, CodingKey {
        case addedOn = "added_on"
        case amountLeft = "amount_left"
        case autoTmm = "auto_tmm"
        case availability, category, completed
        case completionOn = "completion_on"
        case contentPath = "content_path"
        case dlLimit = "dl_limit"
        case dlspeed, downloaded
        case downloadedSession = "downloaded_session"
        case eta
        case fLPiecePrio = "f_l_piece_prio"
        case forceStart = "force_start"
        case hash
        case lastActivity = "last_activity"
        case magnetURI = "magnet_uri"
        case maxRatio = "max_ratio"
        case maxSeedingTime = "max_seeding_time"
        case name
        case numComplete = "num_complete"
        case numIncomplete = "num_incomplete"
        case numLeechs = "num_leechs"
        case numSeeds = "num_seeds"
        case priority, progress, ratio
        case ratioLimit = "ratio_limit"
        case savePath = "save_path"
        case seedingTime = "seeding_time"
        case seedingTimeLimit = "seeding_time_limit"
        case seenComplete = "seen_complete"
        case seqDL = "seq_dl"
        case size, state
        case superSeeding = "super_seeding"
        case tags
        case timeActive = "time_active"
        case totalSize = "total_size"
        case tracker
        case trackersCount = "trackers_count"
        case upLimit = "up_limit"
        case uploaded
        case uploadedSession = "uploaded_session"
        case upspeed
    }
}
