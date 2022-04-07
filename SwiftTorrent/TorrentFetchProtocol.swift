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
    case unknown(description: String?)
}
enum FetcherError: Error {
    case network(description: String)
    case parsing(description: String)
    case unauthorized
    case notFound
    case unknown(description: String?)
}
enum TorrentState {
    case error
    case missingFiles
    case uploading
    case finished
    case checking
    case downloading
    case paused
}
protocol TorrentProtocol {
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

protocol TorrentFetchProtocol {
    var host: String { get set }
    var port: Int? { get set }
    var sid: String? { get set }
    
    func login(
        username: String,
        password: String
    ) async -> Result<Void, LoginError>
    
    func torrentsInfo() async -> Result<[TorrentProtocol], FetcherError>
    
}
