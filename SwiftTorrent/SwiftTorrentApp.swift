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
        let fetcher = QBFetcher(host: "127.0.0.1", port: 8080)
        return TorrentManager(fetcher: fetcher)
    }()
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(manager)
        }
    }
}
