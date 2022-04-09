//
//  TorrentFetchProtocol.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/07.
//

import Foundation

enum LoginError: Error {
    case bannedIP
    case wrongInfo
    case network(description: String)
    case unknown(description: String?)
}
enum FetcherError: Error {
    case network(description: String)
    case parsing(description: String)
    case unauthorized
    case notFound
    case notValidTorrentFile(description: String)
    case unknown(description: String?)
}

protocol TorrentProtocol {
    var id: String { get }
    var name: String? { get }
    var state: Torrent.State? { get }
    /// bytes/s
    var downloadSpeed: Int? { get }
    /// bytes/s
    var uploadSpeed: Int? { get }
    /// bytes
    var size: Int? { get }
    /// bytes
    var amountLeft: Int? { get }
    /// bytes
    var completed: Int? { get }
    /// percentage/100
    var progress: Float? { get }
    var estimatedTime: TimeInterval? { get }
    var addedOn: Date? { get }
    var completionOn: Date? { get }
}

protocol TorrentFetchProtocol: AnyObject {
    var host: String { get set }
    var port: Int? { get set }
    var sid: String? { get set }
    
    func login(
        username: String,
        password: String
    ) async -> VoidResult<LoginError>
    
    func fetchTorrentList() async -> Result<[Torrent], FetcherError>
    func pause(torrents: [String])
    func resume(torrents: [String])
    func delete(torrents: [String], deleteFiles: Bool)
    func addTorrents(fromFiles files: [Data]) async -> VoidResult<FetcherError>
    func addTorrents(fromURLs urls: [URL]) async -> VoidResult<FetcherError>
}

enum VoidResult<Failure> where Failure: Error {
    case success
    case failure(Failure)
}

extension TorrentProtocol {
    func torrent() -> Torrent? {
        guard
            let name = self.name,
            let state = self.state,
            let downloadSpeed = self.downloadSpeed,
            let uploadSpeed = self.uploadSpeed,
            let size = self.size,
            let amountLeft = self.amountLeft,
            let completed = self.completed,
            let progress = self.progress,
            let estimatedTime = self.estimatedTime,
            let addedOn = self.addedOn,
            let completionOn = self.completionOn else {
            return nil
        }
        return Torrent(
            id: self.id, name: name, state: state,
            downloadSpeed: downloadSpeed, uploadSpeed: uploadSpeed,
            size: size, amountLeft: amountLeft, completed: completed,
            progress: progress,
            estimatedTime: TimeInterval(estimatedTime),
            addedOn: addedOn, completionOn: completionOn
        )
    }
}
