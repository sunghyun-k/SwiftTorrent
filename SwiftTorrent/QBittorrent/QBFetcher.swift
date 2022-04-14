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
    
    var host: String = "127.0.0.1"
    var port: Int?
    
    init() {
        let config = URLSessionConfiguration.default
        config.httpCookieAcceptPolicy = .never
        self.session = URLSession(configuration: config)
    }
}

extension QBFetcher: LoginTokenFetcherProtocol {
    
    // MARK: - Auth
    func loginToken(
        host: String, port: Int?,
        username: String, password: String
    ) async -> Result<String, LoginError> {
        self.host = host
        self.port = port
        guard let url = makeLoginComponents(username: username, password: password).url else {
            return .failure(.network(description: "Cannot create url."))
        }
        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await getData(from: url, nil)
        } catch let error {
            return .failure(.network(description: error.localizedDescription))
        }
        guard response.statusCode == 200 else {
            if response.statusCode == 403 {
                return .failure(.custom(description: "IP is banned for too many failed login attempts."))
            } else {
                return .failure(.custom(description: "Unknown error."))
            }
        }

        guard let result = String(data: data, encoding: .utf8),
              result == "Ok." else {
            return .failure(.custom(description: "Wrong username or password."))
        }
        guard let cookie = response.value(forHTTPHeaderField: "set-cookie"),
           let sidString = cookie.components(separatedBy: ";").first?
            .components(separatedBy: "="),
           sidString.count == 2 else {
            return .failure(.parsing(description: "Cannot parse user SID."))
        }
        return .success(sidString[1])
    }
    
    func logout(loginToken: String) {
        guard let url = makeLogoutComponents().url else {
            print("Cannot create logout url.")
            return
        }
        Task {
            do {
                _ = try await getData(from: url, loginToken)
            } catch let error {
                print(error)
            }
        }
    }
}

extension QBFetcher: TorrentFetcherProtocol {
    
    // MARK: - Torrents
    func fetchTorrentList(_ loginToken: String?) async -> Result<[Torrent], FetcherError> {
        guard let url = makeTorrentListComponents().url else {
            return .failure(.network(description: "Cannot create url"))
        }
        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await getData(from: url, loginToken)
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
    func pause(torrents: [String], _ loginToken: String?) {
        guard let url = makePauseTorrentsComponents(torrentIDs: torrents).url else {
            return
        }
        Task {
            do {
                _ = try await getData(from: url, loginToken)
            } catch {
                return
            }
        }
    }
    func resume(torrents: [String], _ loginToken: String?) {
        guard let url = makeResumeTorrentsComponents(torrentIDs: torrents).url else {
            return
        }
        Task {
            do {
                _ = try await getData(from: url, loginToken)
            } catch {
                return
            }
        }
    }
    func delete(torrents: [String], deleteFiles: Bool, _ loginToken: String?) {
        guard let url = makeDeleteTorrentsComponents(torrentIDs: torrents, deleteFiles: deleteFiles).url else {
            return
        }
        Task {
            do {
                _ = try await getData(from: url, loginToken)
            } catch {
                return
            }
        }
    }
    
    func addTorrents(fromFiles files: [File], _ loginToken: String?) async -> VoidResult<FetcherError> {
        guard let url = makeAddTorrentsComponents().url else {
            return .failure(.network(description: "Cannot create URL."))
        }
        let formData = files.map {
            FormData(key: "torrents", value: $0.data, filename: $0.name, contentType: "application/x-bittorrent")
        }
        let boundary = UUID().uuidString
        let body = makeFormData(parameters: formData, boundary: boundary)
        do {
            _ = try await postData(body, to: url, boundary: boundary, loginToken)
        } catch let error {
            print(error)
            return .failure(.network(description: error.localizedDescription))
        }
        return .success
    }
    
    func addTorrents(fromURLs urls: [String], _ loginToken: String?) async -> VoidResult<FetcherError> {
        guard let url = makeAddTorrentsComponents().url else {
            return .failure(.network(description: "Cannot create URL."))
        }
        let stringData = urls.compactMap { urlString in
            urlString.data(using: .utf8)
        }
        let joined = stringData.joined(separator: "\n".data(using: .utf8)!)
        let formData = FormData(key: "urls", value: Data(joined), filename: nil, contentType: nil)
        let boundary = UUID().uuidString
        let body = makeFormData(parameters: [formData], boundary: boundary)
        do {
            _ = try await postData(body, to: url, boundary: boundary, loginToken)
        } catch let error {
            print(error)
            return .failure(.network(description: error.localizedDescription))
        }
        return .success
    }
    
    func loginFetcher() -> LoginTokenFetcherProtocol {
        self
    }
}

// MARK: - Private
private extension QBFetcher {
    
    func getData(from url: URL, _ sid: String?) async throws -> (Data, HTTPURLResponse) {
//        print(url.absoluteString)
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
    
    func postData(_ data: Data, to url: URL, boundary: String, _ sid: String?) async throws -> (Data, HTTPURLResponse) {
        print(url.absoluteString)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let sid = sid {
            request.addValue("SID=\(sid)", forHTTPHeaderField: "Cookie")
        }
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        let (responseData, response) = try await session.upload(for: request, from: data)
        guard let response = response as? HTTPURLResponse else {
            throw FetcherError.network(description: "Couldn't get HTTP response")
        }
        return (responseData, response)
    }
    
    struct FormData {
        let key: String
        let value: Data
        let filename: String?
        let contentType: String?
    }
    func makeFormData(parameters: [FormData], boundary: String) -> Data {
        var data = Data()
        parameters.forEach { param in
            data += "--\(boundary)\r\n"
            var disposition = ""
            disposition += "Content-Disposition: form-data; name=\"\(param.key)\""
            if let filename = param.filename {
                disposition += "; filename=\"\(filename)\""
            } else {
                disposition += "\r\n"
            }
            disposition += "\r\n"
            data += disposition
            
            if let contentType = param.contentType {
                data += "Content-Type: \(contentType)\r\n\r\n"
            }
            data += param.value
            data += "\r\n"
        }
        data += "--\(boundary)-\r\n"
        return data
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
            static let logout = apiName + "/logout"
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
    func makeLogoutComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = Components.scheme
        components.host = host
        components.port = port
        components.path = Components.Auth.logout
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
    func makeAddTorrentsComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = Components.scheme
        components.host = host
        components.port = port
        components.path = Components.Torrents.add
        return components
    }
}
