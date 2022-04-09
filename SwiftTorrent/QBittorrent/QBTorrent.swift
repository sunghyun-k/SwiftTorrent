//
//  QBTorrent.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/07.
//

import Foundation

struct QBTorrentResponse: Decodable {
    let addedOn: Date?
    let amountLeft: Int?
    let autoTmm: Bool?
    let availability: Double?
    let category: String?
    let completed: Int?
    let completionOn: Date?
    let contentPath: String?
    let dlLimit, dlspeed, downloaded, downloadedSession: Int?
    let eta: Int?
    let fLPiecePrio, forceStart: Bool?
    let hash: String?
    let lastActivity: Date?
    let magnetURI: String?
    let maxRatio: Float?
    let maxSeedingTime: Int?
    let name: String?
    let numComplete, numIncomplete, numLeechs, numSeeds: Int?
    let priority: Int?
    let progress: Float?
    let ratio, ratioLimit: Float?
    let savePath: String?
    let seedingTime, seedingTimeLimit: Int?
    let seenComplete: Date?
    let seqDL: Bool?
    let size: Int?
    let state: State?
    let superSeeding: Bool?
    let tags: String?
    let timeActive, totalSize: Int?
    let tracker: String?
    let trackersCount, upLimit, uploaded, uploadedSession: Int?
    let upspeed: Int?

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
    
    enum State: String, Decodable {
        case error
        case missingFiles
        case uploading
        case pausedUP
        case queuedUP
        case stalledUP
        case checkingUP
        case forcedUP
        case allocating
        case downloading
        case metaDL
        case pausedDL
        case queuedDL
        case stalledDL
        case checkingDL
        case forcedDL
        case checkingResumeData
        case moving
        case unknown
    }
}

extension Torrent {
    init?(_ tor: QBTorrentResponse) {
        guard
            let id = tor.hash,
            let name = tor.name,
            let qbState = tor.state,
            let downloadSpeed = tor.dlspeed,
            let uploadSpeed = tor.upspeed,
            let size = tor.size,
            let amountLeft = tor.amountLeft,
            let completed = tor.completed,
            let progress = tor.progress,
            let eta = tor.eta,
            let addedOn = tor.addedOn,
            let completionOn = tor.completionOn else {
            return nil
        }
        
        self.init(
            id: id, name: name, state: convertState(qbState),
            downloadSpeed: downloadSpeed, uploadSpeed: uploadSpeed, size: size,
            amountLeft: amountLeft, completed: completed,
            progress: progress,
            eta: TimeInterval(eta),
            addedOn: addedOn, completionOn: completionOn
        )
    }
    
    mutating func update(_ tor: QBTorrentResponse) {
        if let id = tor.hash {
            self.id = id
        }
        if let name = tor.name {
            self.name = name
        }
        if let qbState = tor.state {
            self.state = convertState(qbState)
        }
        if let downloadSpeed = tor.dlspeed {
            self.downloadSpeed = downloadSpeed
        }
        if let uploadSpeed = tor.upspeed {
            self.uploadSpeed = uploadSpeed
        }
        if let size = tor.size {
            self.size = size
        }
        if let amountLeft = tor.amountLeft {
            self.amountLeft = amountLeft
        }
        if let completed = tor.completed {
            self.completed = completed
        }
        if let progress = tor.progress {
            self.progress = progress
        }
        if let eta = tor.eta {
            self.eta = Double(eta)
        }
        if let addedOn = tor.addedOn {
            self.addedOn = addedOn
        }
        if let completionOn = tor.completionOn {
            self.completionOn = completionOn
        }
    }
}

private func convertState(_ state: QBTorrentResponse.State) -> Torrent.State {
    switch state {
    case .checkingDL, .checkingUP, .checkingResumeData, .allocating, .metaDL:
        return .checking
    case .downloading, .forcedDL, .stalledDL:
        return .downloading
    case .error, .missingFiles:
        return .error
    case .pausedDL, .queuedDL:
        return .paused
    case .pausedUP:
        return .finished
    case .unknown, .moving:
        return .unknown
    case .uploading, .forcedUP, .stalledUP, .queuedUP:
        return .uploading
    }
}
