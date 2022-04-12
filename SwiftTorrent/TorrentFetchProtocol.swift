//
//  TorrentFetchProtocol.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/07.
//

import Foundation

enum FetcherError: Error {
    case network(description: String)
    case parsing(description: String)
    case unauthorized
    case notFound
    case notValidTorrentFile(description: String)
    case unknown(description: String?)
}

protocol TorrentFetcherProtocol: AnyObject {
    var host: String { get set }
    var port: Int? { get set }
    
    func fetchTorrentList(_ loginToken: String?) async -> Result<[Torrent], FetcherError>
    func pause(torrents: [String], _ loginToken: String?)
    func resume(torrents: [String], _ loginToken: String?)
    func delete(torrents: [String], deleteFiles: Bool, _ loginToken: String?)
    func addTorrents(fromFiles files: [File], _ loginToken: String?) async -> VoidResult<FetcherError>
    func addTorrents(fromURLs urls: [URL], _ loginToken: String?) async -> VoidResult<FetcherError>
    
    func loginFetcher() -> LoginTokenFetcherProtocol
}

enum LoginError: Error {
    case network(description: String)
    case parsing(description: String)
    case custom(description: String)
}
protocol LoginTokenFetcherProtocol {
    func loginToken(
        username: String,
        password: String
    ) async -> Result<String, LoginError>
}

enum VoidResult<Failure> where Failure: Error {
    case success
    case failure(Failure)
}
