//
//  SwiftTorrentApp.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/06.
//

import SwiftUI

@main
struct SwiftTorrentApp: App {
    @StateObject private var fetcher = QBittorrentFetcher(host: "127.0.0.1", port: 8080)
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(fetcher)
        }
    }
}
