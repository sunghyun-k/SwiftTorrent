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
    var amountLeft: Int { get }
    var completed: Int { get }
    var completionOn: Int { get }
    var downloadSpeed: Int { get }
    var eta: TimeInterval { get }
    var id: String { get }
    var name: String { get }
    var progress: Float { get }
    var size: Int { get }
    var state: TorrentState { get }
    var uploadSpeed: Int { get }
}

protocol TorrentFetchProtocol {
    var host: String { get set }
    var port: Int? { get set }
    
    func login(
        username: String,
        password: String
    ) async -> Result<Void, LoginError>
    
    func torrentList() async -> Result<[TorrentProtocol], FetcherError>
    
}
