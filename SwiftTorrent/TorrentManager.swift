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
    @Published var currentUser: String?
    
    private let fetcher: TorrentFetchProtocol
    
    private let timer = Timer.TimerPublisher(interval: 1.5, runLoop: .main, mode: .default)
    private var cancellable: Cancellable?
    private var disposables = Set<AnyCancellable>()
    
    init(fetcher: TorrentFetchProtocol) {
        self.fetcher = fetcher
        timer.sink { [weak self] _ in
            guard let self = self else { return }
            self.fetchTorrents()
        }
        .store(in: &disposables)
    }
    
    func login(username: String, password: String) async -> VoidResult<LoginError> {
        let result = await fetcher.login(username: username, password: password)
        switch result {
        case .success:
            currentUser = username
            cancellable = timer.connect()
            fetchTorrents()
        case .failure(_):
            currentUser = nil
            cancellable = nil
        }
        return result
    }
    
    func fetchTorrents() {
        Task { [weak self] in
            guard let self = self else { return }
            let result = await fetcher.fetchTorrentList()
            switch result {
            case .success(let torrents):
                self.torrents = torrents
            case .failure(let error):
                switch error {
                case .unauthorized:
                    currentUser = nil
                default:
                    return
                }
            }
        }
    }
    
    func pauseResumeTorrent(_ torrent: Torrent) {
        switch torrent.state {
        case .paused, .finished:
            fetcher.resume(torrents: [torrent.id])
        case .downloading, .uploading, .checking:
            fetcher.pause(torrents: [torrent.id])
        default:
            break
        }
    }
    
    func deleteTorrents(_ torrents: [Torrent]) {
        fetcher.delete(torrents: torrents.map { $0.id }, deleteFiles: false)
    }
}
