//
//  SwiftTorrentApp.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/06.
//

import SwiftUI

@main
struct SwiftTorrentApp: App {
    @StateObject private var manager: TorrentManager = {
        let fetcher = QBFetcher(host: "192.168.1.162", port: 8080)
        let manager = TorrentManager(fetcher: fetcher)
        Task {
            let result = await fetcher.loginToken(username: "brm0821", password: "ksh980821")
            switch result {
            case .success(let token):
                manager.loginToken = token
            default:
                break
            }
        }
        return manager
    }()
    var body: some Scene {
        WindowGroup {
            TorrentList()
                .environmentObject(manager)
                .onOpenURL { url in
                    if url.scheme == "file" {
                        guard let data = try? Data(contentsOf: url) else {
                            print("Cannot read file")
                            return
                        }
                        let file = File(name: url.lastPathComponent, data: data)
                        manager.addTorrents([file])
                    } else {
                        manager.addTorrents([url.absoluteString])
                    }
                }
        }
    }
}
