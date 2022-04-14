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
    @Published var torrents: [Torrent] = []
    @Published var loginToken: String? {
        didSet {
            if loginToken == nil {
                cancellable?.cancel()
                cancellable = nil
            } else {
                fetchTorrents()
                cancellable = timer.connect()
            }
        }
    }
    
    private let fetcher: TorrentFetcherProtocol
    
    private let timer = Timer.TimerPublisher(interval: 1.5, runLoop: .main, mode: .default)
    private var cancellable: Cancellable?
    private var disposables = Set<AnyCancellable>()
    
    init(fetcher: TorrentFetcherProtocol) {
        self.fetcher = fetcher
        timer.sink { [weak self] _ in
            guard let self = self else { return }
            self.fetchTorrents()
        }
        .store(in: &disposables)
    }
    
    func loginFetcher() -> LoginTokenFetcherProtocol {
        fetcher.loginFetcher()
    }
    
    func login(username: String, password: String) async -> VoidResult<LoginError> {
        let result = await fetcher.loginFetcher().loginToken(username: username, password: password)
        switch result {
        case .success(let token):
            self.loginToken = token
            return .success
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func loadStoredLoginToken() {
        
    }
    
    func fetchTorrents() {
        Task { [weak self] in
            guard let self = self else { return }
            let result = await fetcher.fetchTorrentList(loginToken)
            switch result {
            case .success(let torrents):
                self.torrents = torrents
            case .failure(let error):
                switch error {
                case .unauthorized:
                    loginToken = nil
                default:
                    return
                }
            }
        }
    }
    
    func pauseResumeTorrent(_ torrent: Torrent) {
        switch torrent.state {
        case .paused, .finished:
            fetcher.resume(torrents: [torrent.id], loginToken)
        case .downloading, .uploading, .checking:
            fetcher.pause(torrents: [torrent.id], loginToken)
        default:
            break
        }
    }
    
    func deleteTorrents(_ torrents: [String]) {
        fetcher.delete(torrents: torrents, deleteFiles: false, loginToken)
    }
    
    func pauseTorrents(_ torrents: [String]) {
        fetcher.pause(torrents: torrents, loginToken)
    }
    
    func resumeTorrents(_ torrents: [String]) {
        fetcher.resume(torrents: torrents, loginToken)
    }
    
    func addTorrents(_ torrents: [File]) {
        Task {
            let result = await fetcher.addTorrents(fromFiles: torrents, loginToken)
        }
    }
    
    func addTorrents(_ links: [String]) {
        Task {
            await fetcher.addTorrents(fromURLs: links ,loginToken)
        }
    }
}
