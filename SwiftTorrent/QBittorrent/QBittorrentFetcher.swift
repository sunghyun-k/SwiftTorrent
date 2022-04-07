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
    private let decoder = Decoder()
    
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
        self.cookieStorage = HTTPCookieStorage()
        
        let config = URLSessionConfiguration.default
        config.httpCookieAcceptPolicy = .never
        config.httpCookieStorage = cookieStorage
        self.session = URLSession(configuration: config)
    }
}

extension QBittorrentFetcher: TorrentFetchProtocol {
    // MARK: - Auth
    func login(username: String, password: String) async -> Result<Void, LoginError> {
        let components = makeLoginComponents(username: username, password: password)
        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await getData(for: components)
        } catch InternalError.server(statusCode: let code) {
            switch code {
            case 403: return .failure(.bannedIP)
            default: return .failure(.unknown(description: nil))
            }
        } catch {
            return .failure(.unknown(description: nil))
        }
        guard
            let result = String(data: data, encoding: .utf8),
            result == "Ok." else {
            return .failure(.wrongInfo)
        }
        guard
            let cookie = response.value(forHTTPHeaderField: "set-cookie"),
            let sidString = cookie.components(separatedBy: ";").first?
                .components(separatedBy: "="),
            sidString.count == 2 else {
            return .success(())
        }
        sid = sidString[1]
        return .success(())
    }
    
    func torrentList() async -> Result<[TorrentProtocol], FetcherError> {
        fatalError()
    }
}

// MARK: - Private
private extension QBittorrentFetcher {
    /// QBittorrentFetcher 내부에서만 사용. 외부에서 확인할 수 있는 오류로 변환이 필요하다.
    enum InternalError: Error {
        case server(statusCode: Int)
    }
    /// URLSession 오류 및 Status Code 200 제외 나머지 응답을 오류로 변환한다.
    func getData(for components: URLComponents) async throws -> (Data, HTTPURLResponse) {
        guard let url = components.url else {
            throw FetcherError.network(description: "Couldn't create URL")
        }
        var request = URLRequest(url: url)
        if let sid = sid {
            request.addValue("SID=\(sid)", forHTTPHeaderField: "Cookie")
        }
        let (data, response) = try await session.data(for: request)
        guard let response = response.httpResponse else {
            throw FetcherError.network(description: "Couldn't get HTTP response")
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
