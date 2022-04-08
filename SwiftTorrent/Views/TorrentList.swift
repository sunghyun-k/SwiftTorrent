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
            Button {
                manager.fetchTorrents()
            } label: {
                Text("Refresh")
            }
            
            ForEach(manager.torrents, id: \.id) { torrent in
                TorrentRow(torrent: torrent)
            }
        }
    }
}

struct TorrentList_Previews: PreviewProvider {
    static var previews: some View {
        TorrentList()
    }
}
