//
//  Torrent.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/09.
//

import Foundation
import SwiftUI

struct Torrent: Identifiable {
    var id: String
    var name: String
    
    enum State {
        case unknown
        case error
        case checking
        case downloading
        case uploading
        case paused
        case finished
    }
    var state: State
    
    /// bytes/s
    var downloadSpeed: Int
    /// bytes/s
    var uploadSpeed: Int
    
    /// bytes
    var size: Int
    /// bytes
    var amountLeft: Int
    /// bytes
    var completed: Int
    /// percentage/100
    var progress: Float
    
    var eta: TimeInterval
    var addedOn: Date
    var completionOn: Date
}

extension Torrent.State {
    @ViewBuilder
    var image: some View {
        switch self {
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
            Image(systemName: "circle.fill")
                .foregroundColor(.blue)
                .overlay {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.7)
                }
        case .error:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
        case .unknown:
            Image(systemName: "questionmark.circle.fill")
                .foregroundColor(.yellow)
        }
    }
}

extension Torrent {
    var sizeDescription: String {
        switch state {
        case .finished, .uploading:
            return "\(size.byteFormat) (↑ \(uploadSpeed.byteFormat)/s)"
        default:
            return "\(completed.byteFormat)/\(size.byteFormat) (\(downloadSpeed.byteFormat)/s)"
        }
    }
}

extension Torrent.State: Comparable { }
