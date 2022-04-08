//
//  TorrentManager.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/07.
//

import Foundation

@MainActor
class TorrentManager: ObservableObject {
    @Published var torrents: [TorrentProtocol] = []
    @Published var currentUser: String?
    @Published var isConnected: Bool = false
    
    private let fetcher: TorrentFetchProtocol
    
    init(fetcher: TorrentFetchProtocol) {
        self.fetcher = fetcher
    }
    
    func login(username: String, password: String) async -> Result<Void, LoginError> {
        let result = await fetcher.login(username: username, password: password)
        switch result {
        case .success(_):
            currentUser = username
            isConnected = true
        case .failure(_):
            currentUser = nil
        }
        return result
    }
    
    func fetchTorrents() {
        guard isConnected else { return }
        Task {
            let result = await fetcher.fetchTorrentList()
            switch result {
            case .success(let torrents):
                self.torrents = torrents
            case .failure(let error):
                switch error {
                case .network(_):
                    isConnected = false
                case .notFound:
                    fatalError()
                case .parsing(let description):
                    fatalError()
                case .unauthorized:
                    currentUser = nil
                    isConnected = false
                case .unknown(let description):
                    fatalError()
                }
            }
        }
        
    }
}
