//
//  TorrentManager.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/07.
//

import Foundation
import Combine

@MainActor
class TorrentManager: ObservableObject {
    @Published var torrents: [TorrentProtocol] = []
    @Published var isNotLoggedIn: Bool = true
    
    private let fetcher: TorrentFetchProtocol
    private var disposables = Set<AnyCancellable>()
    
    init(fetcher: TorrentFetchProtocol) {
        self.fetcher = fetcher
    }
    
    func login(username: String, password: String) async -> Result<Void, LoginError> {
        let result = await fetcher.login(username: username, password: password)
        switch result {
        case .success(_): isNotLoggedIn = false
        case .failure(_): isNotLoggedIn = true
        }
        return result
    }
    
    func fetchTorrents() {
        Task {
            let result = await fetcher.fetchTorrentList()
            switch result {
            case .success(let torrents):
                self.torrents = torrents
            case .failure(let error):
                self.torrents = []
            }
        }
        
    }
}
