//
//  Samples.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/07.
//

import Foundation

extension QBTorrent {
    static func sample() -> [QBTorrent] {
        let response: [QBTorrentResponse] = load("torrentList.json")
        return response.map(QBTorrent.init)
    }
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
