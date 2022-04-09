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
