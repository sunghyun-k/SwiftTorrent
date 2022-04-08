//
//  TorrentRow.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/07.
//

import SwiftUI

struct TorrentRow: View {
    @EnvironmentObject var manager: TorrentManager
    let torrent: TorrentProtocol
    var body: some View {
        HStack {
            switch torrent.state {
            case .downloading:
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.blue)
            case .uploading:
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(.green)
            case .finished:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .paused:
                Image(systemName: "pause.circle.fill")
                    .foregroundColor(.orange)
            case .checking:
                Image(systemName: "gearshape.circle.fill")
                    .foregroundColor(.blue)
            case .error:
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
            case .unknown:
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(.yellow)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(torrent.name)
                    .lineLimit(1)
                    .font(.system(size: 14))
                VStack(alignment: .leading, spacing: 3) {
                    if torrent.progress < 1 {
                        ProgressView(value: torrent.progress)
                            .tint({
                                if torrent.state == .downloading {
                                    return Color.accentColor
                                }
                                return Color.gray
                            }())
                    }
                    switch torrent.state {
                    case .finished, .uploading:
                        Text("\(torrent.size.byteFormat)")
                            .font(.system(size: 10))
                    default:
                        Text("\(torrent.completed.byteFormat)/\(torrent.size.byteFormat) (\(torrent.downloadSpeed.byteFormat)/s)")
                            .font(.system(size: 10))
                    }
                }
                .frame(height: 20)
            }
            Spacer(minLength: 20)
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
        .padding([.top, .bottom], 2)
    }
}

//struct TorrentRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TorrentRow(torrent: QBTorrent.sample()[0])
//    }
//}
