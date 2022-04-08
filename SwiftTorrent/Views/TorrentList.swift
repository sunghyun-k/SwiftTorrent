//
//  TorrentList.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/07.
//

import SwiftUI

struct TorrentList: View {
    @EnvironmentObject var manager: TorrentManager
    
    var body: some View {
        List {
            ForEach(manager.torrents, id: \.id) { torrent in
                TorrentRow(torrent: torrent)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            manager.deleteTorrents([torrent])
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
            }
        }
        .listStyle(.plain)
    }
}

struct TorrentList_Previews: PreviewProvider {
    static var previews: some View {
        TorrentList()
    }
}
