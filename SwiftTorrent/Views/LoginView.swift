//
//  LoginView.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/06.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var manager: TorrentManager
    
    enum Field: Hashable {
        case username
        case password
    }
    
    @State private var username: String = ""
    @State private var password: String = ""
    @FocusState private var focusedField: Field?
    
    @State var isLoggingIn: Bool = false
    @State var errorMessage: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Swift Torrent")
                .font(.system(size: 30, weight: .bold))
            TextField("Username", text: $username)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .loginFieldStyle()
                .focused($focusedField, equals: .username)
                .onSubmit {
                    focusedField = .password
                }
            SecureField("Password", text: $password)
                .loginFieldStyle()
                .focused($focusedField, equals: .password)
                .onSubmit(login)
            Text(errorMessage)
                .font(.system(size: 15))
                .foregroundColor(.red)
                .frame(minHeight: 30)
            
            Button(action: login) {
                Text("Login")
                    .frame(maxWidth: .infinity, maxHeight: 35)
            }
            .buttonStyle(.borderedProminent)
            .disabled(username.isEmpty || password.isEmpty)
            Spacer()
        }
        .overlay {
            if isLoggingIn {
                ProgressView()
            }
        }
        .padding()
    }
    
    private func login() {
        errorMessage.removeAll()
        isLoggingIn = true
        Task {
            let result = await manager.login(username: username, password: password)
            switch result {
            case .success(_):
                dismiss()
            case .failure(let error):
                switch error {
                case .bannedIP:
                    errorMessage = "IP is banned for too many failed login attempts."
                case .wrongInfo:
                    errorMessage = "Wrong username or password."
                case .unknown(let description):
                    errorMessage = description ?? "Unknown error."
                }
            }
            isLoggingIn = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

private extension View {
    func loginFieldStyle() -> some View {
        self.font(.subheadline)
            .padding(12)
            .background(Color(white: 0.95))
            .cornerRadius(5)
            .frame(maxWidth: .infinity, maxHeight: 40)
    }
}
