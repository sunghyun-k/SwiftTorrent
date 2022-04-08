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
enum TorrentState {
    case error
    case uploading
    case finished
    case checking
    case downloading
    case paused
    case unknown
}
protocol TorrentProtocol: AnyObject {
    var addedOn: Date { get }
    /// bytes
    var amountLeft: Int { get }
    /// bytes
    var completed: Int { get }
    var completionOn: Date { get }
    /// bytes/s
    var downloadSpeed: Int { get }
    var eta: TimeInterval { get }
    var id: String { get }
    var name: String { get }
    /// percentage/100
    var progress: Float { get }
    /// bytes
    var size: Int { get }
    var state: TorrentState { get }
    /// bytes/s
    var uploadSpeed: Int { get }
}

protocol TorrentFetchProtocol: AnyObject {
    var host: String { get set }
    var port: Int? { get set }
    var sid: String? { get set }
    
    func login(
        username: String,
        password: String
    ) async -> VoidResult<LoginError>
    
    func fetchTorrentList() async -> Result<[TorrentProtocol], FetcherError>
    func pause(torrents: [String])
    func resume(torrents: [String])
    func delete(torrents: [String])
    func addTorrents(fromFiles files: [Data]) async -> VoidResult<FetcherError>
    func addTorrents(fromURLs urls: [URL]) async -> VoidResult<FetcherError>
}

enum VoidResult<Failure> where Failure: Error {
    case success
    case failure(Failure)
}
