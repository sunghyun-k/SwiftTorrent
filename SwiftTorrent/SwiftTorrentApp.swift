//
//  SwiftTorrentApp.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/06.
//

import SwiftUI

@main
struct SwiftTorrentApp: App {
    @StateObject private var manager: TorrentManager = TorrentManager()
    
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
