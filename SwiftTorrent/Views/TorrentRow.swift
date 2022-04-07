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
            VStack(alignment: .leading) {
                Text(torrent.name)
                    .lineLimit(1)
                Text("\(torrent.size) Bytes")
                    .font(.system(size: 10))
            }
            Spacer()
            Image(systemName: "magnifyingglass")
        }
    }
}

//struct TorrentRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TorrentRow(torrent: QBTorrent.sample()[0])
//    }
//}
