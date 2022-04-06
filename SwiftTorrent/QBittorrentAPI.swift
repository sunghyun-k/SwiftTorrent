//
//  QBittorrentAPI.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/06.
//

import Foundation

class QBittorrentFetcher {
    private let session: URLSession
    private let cookieStorage: HTTPCookieStorage
    
    var host: String
    var port: Int?
    
    init(
        host: String,
        port: Int? = nil
    ) {
        self.host = host
        self.port = port
        self.cookieStorage = HTTPCookieStorage()
        
        let config = URLSessionConfiguration.background(withIdentifier: "QBittorrentFetcher")
        config.httpCookieAcceptPolicy = .never
        config.httpCookieStorage = cookieStorage
        self.session = URLSession(configuration: config)
    }
    
    enum FetcherError: Error {
        case network(description: String)
        case parsing(description: String)
        
        enum Login: Error {
            case bannedIP
            case wrongUsernameOrPassword
            case unknown
        }
    }
    /// 기존 로그인 정보를 쿠키에 저장한다.
    func setSID(_ sid: String) {
        let cookie = HTTPCookie(properties: [
            .name : "SID",
            .value: sid
        ])
        cookieStorage.setCookie(cookie!)
    }
    func login(username: String, password: String) async throws {
        let components = makeLoginComponents(username: username, password: password)
        let response: HTTPURLResponse
        do {
            (_, response) = try await data(for: components)
        } catch InternalError.server(statusCode: let code) {
            switch code {
            case 403:
                throw FetcherError.Login.bannedIP
            default:
                throw FetcherError.Login.unknown
            }
        }
        guard
            let cookie = response.value(forHTTPHeaderField: "set-cookie"),
            let sidString = cookie.components(separatedBy: ";").first?
                .components(separatedBy: "="),
            sidString.count == 2 else {
            throw FetcherError.parsing(description: "Couldn't get login token")
        }
        setSID(sidString[1])
    }
    
    private enum InternalError: Error {
        case server(statusCode: Int)
    }
    private func data(for components: URLComponents) async throws -> (Data, HTTPURLResponse) {
        guard let url = components.url else {
            throw FetcherError.network(description: "Couldn't create URL")
        }
        let (data, response) = try await session.data(from: url)
        guard let response = response.httpResponse else {
            throw FetcherError.network(description: "Couldn't get HTTP Response")
        }
        guard response.statusCode == 200 else {
            throw InternalError.server(statusCode: response.statusCode)
        }
        return (data, response)
    }
}

// MARK: - qBittorrent API
private extension QBittorrentFetcher {
    struct Paths {
        static let api = "/api/v2"
        struct Auth {
            private static let apiName = Paths.api + "/auth"
            static let login = apiName + "/login"
        }
    }
    
    func makeLoginComponents(username: String, password: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = "http"
        components.host = host
        components.port = port
        components.path = Paths.Auth.login
        components.queryItems = [
            .init(name: "username", value: username),
            .init(name: "password", value: password)
        ]
        return components
    }
}

extension URLResponse {
    var httpResponse: HTTPURLResponse? {
        self as? HTTPURLResponse
    }
}
