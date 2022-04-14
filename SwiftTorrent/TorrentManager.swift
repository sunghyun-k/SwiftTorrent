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
                UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.loginToken)
                UserDefaults.standard.synchronize()
            } else {
                fetchTorrents()
                cancellable = timer.connect()
                UserDefaults.standard.set(loginToken, forKey: UserDefaultsKeys.loginToken)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    struct UserDefaultsKeys {
        static let loginToken = "loginToken"
        static let loginInfo = "loginInfo"
    }
    
    private let fetcher: TorrentFetcherProtocol = QBFetcher()
    
    private let timer = Timer.TimerPublisher(interval: 1.5, runLoop: .main, mode: .default)
    private var cancellable: Cancellable?
    private var disposables = Set<AnyCancellable>()
    
    init() {
        if let info = loadLoginInfo() {
            fetcher.host = info.host
            fetcher.port = info.port
        }
        timer.sink { [weak self] _ in
            guard let self = self else { return }
            self.fetchTorrents()
        }
        .store(in: &disposables)
        
        loadLoginToken()
    }
    
    func login(
        host: String, port: Int?,
        username: String, password: String
    ) async -> VoidResult<LoginError> {
        let result = await fetcher.loginFetcher().loginToken(
            host: host, port: port,
            username: username, password: password
        )
        switch result {
        case .success(let token):
            saveLoginInfo(LoginInfo(host: host, port: port, username: username, password: password))
            self.loginToken = token
            return .success
        case .failure(let error):
            removeLoginInfo()
            return .failure(error)
        }
    }
    
    func logout() {
        guard let token = loginToken else {
            return
        }
        fetcher.loginFetcher().logout(loginToken: token)
        loginToken = nil
        torrents = []
    }
    
    private func saveLoginInfo(_ info: LoginInfo) {
        let data: Data
        do {
            data = try PropertyListEncoder().encode(info)
        } catch let error {
            print(error)
            return
        }
        UserDefaults.standard.set(data, forKey: UserDefaultsKeys.loginInfo)
        UserDefaults.standard.synchronize()
    }
    
    private func removeLoginInfo() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.loginInfo)
        UserDefaults.standard.synchronize()
    }
    
    func loadLoginInfo() -> LoginInfo? {
        guard let data = UserDefaults.standard.value(forKey: UserDefaultsKeys.loginInfo) as? Data else {
            return nil
        }
        do {
            return try PropertyListDecoder().decode(LoginInfo.self, from: data)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    private func loadLoginToken() {
        self.loginToken = UserDefaults.standard.string(forKey: UserDefaultsKeys.loginToken)
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
