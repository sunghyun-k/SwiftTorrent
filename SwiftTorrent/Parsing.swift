//
//  Parsing.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/07.
//

import Foundation

class Decoder {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()
    
    func decode<T: Decodable>(_ data: Data) async throws -> T {
        return try decoder.decode(T.self, from: data)
    }
}

