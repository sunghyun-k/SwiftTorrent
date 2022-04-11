//
//  QBittorrentAPI.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/06.
//

import Foundation

class QBFetcher {
    private let session: URLSession
    private let decoder = Decoder()
    
    private var isFetching = false
    
    var host: String
    var port: Int?
    /// 기존 로그인 토큰
    var sid: String?
    
    init(
        host: String,
        port: Int? = nil
    ) {
        self.host = host
        self.port = port
        
        let config = URLSessionConfiguration.default
        config.httpCookieAcceptPolicy = .never
        self.session = URLSession(configuration: config)
    }
}

extension QBFetcher: TorrentFetchProtocol {
    
    // MARK: - Auth
    func login(username: String, password: String) async -> VoidResult<LoginError> {
        guard let url = makeLoginComponents(username: username, password: password).url else {
            return .failure(.network(description: "Cannot create url."))
        }
        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await getData(from: url)
        } catch let error {
            return .failure(.network(description: error.localizedDescription))
        }
        guard response.statusCode == 200 else {
            if response.statusCode == 403 {
                return .failure(.bannedIP)
            } else {
                return .failure(.unknown(description: nil))
            }
        }
        
        guard let result = String(data: data, encoding: .utf8),
              result == "Ok." else {
            return .failure(.wrongInfo)
        }
        if let cookie = response.value(forHTTPHeaderField: "set-cookie"),
           let sidString = cookie.components(separatedBy: ";").first?
            .components(separatedBy: "="),
           sidString.count == 2 {
            sid = sidString[1]
        }
        return .success
    }
    
    // MARK: - Torrents
    func fetchTorrentList() async -> Result<[Torrent], FetcherError> {
        guard let url = makeTorrentListComponents().url else {
            return .failure(.network(description: "Cannot create url"))
        }
        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await getData(from: url)
        } catch let error {
            return .failure(.network(description: error.localizedDescription))
        }
        guard response.statusCode == 200 else {
            if response.statusCode == 403 {
                return .failure(.unauthorized)
            } else {
                return .failure(.unknown(description: nil))
            }
        }
        let torrents: [QBTorrentResponse]
        do {
            torrents = try await decoder.decode(data)
        } catch let error {
            print(error)
            return .failure(.parsing(description: error.localizedDescription))
        }
        return .success(torrents.compactMap(Torrent.init))
    }
    func pause(torrents: [String]) {
        guard let url = makePauseTorrentsComponents(torrentIDs: torrents).url else {
            return
        }
        Task {
            do {
                _ = try await getData(from: url)
            } catch {
                return
            }
        }
    }
    func resume(torrents: [String]) {
        guard let url = makeResumeTorrentsComponents(torrentIDs: torrents).url else {
            return
        }
        Task {
            do {
                _ = try await getData(from: url)
            } catch {
                return
            }
        }
    }
    func delete(torrents: [String], deleteFiles: Bool) {
        guard let url = makeDeleteTorrentsComponents(torrentIDs: torrents, deleteFiles: deleteFiles).url else {
            return
        }
        Task {
            do {
                _ = try await getData(from: url)
            } catch {
                return
            }
        }
    }
    
    func addTorrents(fromFiles files: [Data]) async -> VoidResult<FetcherError> {
        fatalError()
    }
    
    func addTorrents(fromURLs urls: [URL]) async -> VoidResult<FetcherError> {
        fatalError()
    }
    
}

// MARK: - Private
private extension QBFetcher {
    
    func getData(from url: URL) async throws -> (Data, HTTPURLResponse) {
        print(url.absoluteString)
        guard !isFetching else {
            throw FetcherError.network(description: "Fetching data.")
        }
        isFetching = true
        defer { isFetching = false }
        var request = URLRequest(url: url)
        if let sid = sid {
            request.addValue("SID=\(sid)", forHTTPHeaderField: "Cookie")
        }
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw FetcherError.network(description: "Couldn't get HTTP response")
        }
        return (data, response)
        
    }
    
    func postData(_ data: Data, to url: URL) async throws -> (Data, HTTPURLResponse) {
        print(url.absoluteString)
        guard !isFetching else {
            throw FetcherError.network(description: "Fetching data.")
        }
        isFetching = true
        defer { isFetching = false }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let sid = sid {
            request.addValue("SID=\(sid)", forHTTPHeaderField: "Cookie")
        }
        let (responseData, response) = try await session.upload(for: request, from: data)
        guard let response = response as? HTTPURLResponse else {
            throw FetcherError.network(description: "Couldn't get HTTP response")
        }
        return (responseData, response)
    }
    
    struct FormData {
        let key: String
        let value: Any
        let filename: String?
        let contentType: String?
    }
    func makeFormData(parameters: [FormData], boundary: String) -> Data {
        var data = ""
        parameters.forEach { param in
            data += "--\(boundary)\r\n"
            var disposition = ""
            disposition += "Content-Disposition: form-data; name=\"\(param.key)\""
            if let filename = param.filename {
                disposition += "; filename=\"\(filename)\""
            }
            disposition += "\r\n"
            data += disposition
            
            if let contentType = param.contentType {
                data += "Content-Type: \(contentType)\r\n\r\n"
            }
            data += String(data: param.value as! Data, encoding: .utf8)!
            data += "\r\n"
        }
        data += "--\(boundary)\r\n-"
        return data.data(using: .utf8)!
    }
}

// MARK: - qBittorrent API
private extension QBFetcher {
    struct Components {
        static let scheme = "http"
        static let api = "/api/v2"
        struct Auth {
            private static let apiName = Components.api + "/auth"
            static let login = apiName + "/login"
        }
        struct Torrents {
            private static let apiName = Components.api + "/torrents"
            static let info = apiName + "/info"
            static let pause = apiName + "/pause"
            static let resume = apiName + "/resume"
            static let delete = apiName + "/delete"
            static let add = apiName + "/add"
        }
    }
    
    // MARK: - Auth
    func makeLoginComponents(username: String, password: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = Components.scheme
        components.host = host
        components.port = port
        components.path = Components.Auth.login
        components.queryItems = [
            .init(name: "username", value: username),
            .init(name: "password", value: password)
        ]
        return components
    }
    // MARK: - Torrents
    func makeTorrentListComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = Components.scheme
        components.host = host
        components.port = port
        components.path = Components.Torrents.info
        return components
    }
    
    func makeManageTorrentsComponents(path: String, torrentIDs: [String]) -> URLComponents {
        var components = URLComponents()
        components.scheme = Components.scheme
        components.host = host
        components.port = port
        components.path = path
        let torrents = torrentIDs.joined(separator: "|")
        components.queryItems = [
            .init(name: "hashes", value: torrents)
        ]
        return components
    }
    func makePauseTorrentsComponents(torrentIDs: [String]) -> URLComponents {
        makeManageTorrentsComponents(path: Components.Torrents.pause, torrentIDs: torrentIDs)
    }
    func makeResumeTorrentsComponents(torrentIDs: [String]) -> URLComponents {
        makeManageTorrentsComponents(path: Components.Torrents.resume, torrentIDs: torrentIDs)
    }
    func makeDeleteTorrentsComponents(torrentIDs: [String], deleteFiles: Bool) -> URLComponents {
        var components = makeManageTorrentsComponents(path: Components.Torrents.delete, torrentIDs: torrentIDs)
        components.queryItems?.append(.init(name: "deleteFiles", value: String(deleteFiles)))
        return components
    }
}
