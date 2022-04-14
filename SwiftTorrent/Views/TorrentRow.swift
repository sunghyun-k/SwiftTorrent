//
//  TorrentRow.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/07.
//

import SwiftUI

struct TorrentRow: View {
    @EnvironmentObject var manager: TorrentManager
    var torrent: Torrent
    
    @Binding var isEditing: Bool
    
    var body: some View {
        HStack {
            torrent.state.image
                .font(.title2)
            VStack(alignment: .leading, spacing: 3) {
                Text(torrent.name)
                    .lineLimit(1)
                    .font(.body)
                VStack(alignment: .leading, spacing: 4) {
                    if torrent.progress < 1 {
                        ProgressView(value: torrent.progress)
                            .tint({
                                if torrent.state == .downloading {
                                    return Color.accentColor
                                }
                                return Color.gray
                            }())
                            .animation(.default, value: torrent.progress)
                    }
                    Text(torrent.sizeDescription)
                        .font(.footnote)
                }
                .frame(height: 25)
                .animation(.default, value: torrent.state)
            }
            Spacer(minLength: 20)
            if !isEditing {
                Button {
                    manager.pauseResumeTorrent(torrent)
                } label: {
                    switch torrent.state {
                    case .paused, .finished:
                        Image(systemName: "play.fill")
                    case .downloading, .uploading, .checking:
                        Image(systemName: "pause.fill")
                    default:
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 12)
            }
        }
        .padding([.top, .bottom], 2)
    }
}

//struct TorrentRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TorrentRow(torrent: QBTorrent.sample()[0])
//    }
//}
