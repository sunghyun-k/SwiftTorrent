//
//  TorrentRow.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/07.
//

import SwiftUI

struct TorrentRow: View {
    let torrent: TorrentProtocol
    var body: some View {
        HStack {
            Image(systemName: "doc.fill")
            VStack {
                Text(torrent.name)
                Text("\(torrent.size) Bytes")
            }
            Image(systemName: "magnifyingglass")
        }
    }
}

//struct TorrentRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TorrentRow(torrent: QBTorrent.sample()[0])
//    }
//}
