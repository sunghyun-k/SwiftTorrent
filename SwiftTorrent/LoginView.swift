//
//  LoginView.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/06.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var fetcher: QBittorrentFetcher
    
    @State var username: String = ""
    @State var password: String = ""
    var body: some View {
        VStack(spacing: 10) {
            Text("qBittorrent UI")
                .font(.system(size: 30, weight: .bold))
            TextField("Username", text: $username)
                .loginField()
            SecureField("Password", text: $password)
                .loginField()
            Button {
                print("로그인 요청보냄", username, password)
                Task {
                    do {
                        try await fetcher.login(username: username,password: password)
                    } catch {
                        print(error)
                    }
                    
                }
            } label: {
                Text("Login")
                    .frame(maxWidth: .infinity, maxHeight: 35)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

private extension View {
    func loginField() -> some View {
        self.font(.subheadline)
            .padding(12)
            .background(Color(white: 0.95))
            .cornerRadius(5)
            .frame(maxWidth: .infinity, maxHeight: 40)
    }
}
