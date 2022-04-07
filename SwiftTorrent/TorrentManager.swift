//
//  TorrentManager.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/07.
//

import Foundation
import Combine

class TorrentManager: ObservableObject {
    @Published var downloadList: [TorrentProtocol] = []
    
    private let fetcher: TorrentFetchProtocol
    private var disposables = Set<AnyCancellable>()
    
    init(fetcher: TorrentFetchProtocol) {
        self.fetcher = fetcher
    }
    
    enum LoginState {
        case success
        case fail
    }
    func login(username: String, password: String) async -> Result<Void, LoginError> {
        await fetcher.login(username: username, password: password)
    }
}
