//
//  LoginView.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/06.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var manager: TorrentManager
    
    @State var host: String = ""
    @State var port: String = ""
    @State var username: String = ""
    @State var password: String = ""
    
    enum Field: Hashable {
        case host, port, username, password
    }
    @FocusState private var focusedField: Field?
    
    @State var isLoading: Bool = false
    @State var errorMessage: String = ""
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Swift Torrent")
                .font(.system(size: 34, weight: .bold))
            VStack(spacing: 0) {
                LoginField(title: "Host", placeholder: "127.0.0.1", text: $host)
                    .focused($focusedField, equals: .host)
                    .onSubmit {
                        focusedField = .username
                    }
                LoginField(title: "Port", placeholder: "Optional", text: $port)
                    .focused($focusedField, equals: .port)
                    .onSubmit {
                        focusedField = .username
                    }
                    .keyboardType(.decimalPad)
                LoginField(title: "Username", placeholder: "username", text: $username)
                    .focused($focusedField, equals: .username)
                    .onSubmit {
                        focusedField = .password
                    }
                LoginField(title: "Password", placeholder: "password", text: $password, isSecure: true)
                    .focused($focusedField, equals: .password)
                    .onSubmit {
                        login()
                    }
            }
            .cornerRadius(10)
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color(white: 0.85)))
            
            Text(errorMessage)
                .font(.callout)
                .foregroundColor(.red)
                .frame(minHeight: 30)
            
            Button(action: login) {
                Text("Login")
                    .frame(maxWidth: .infinity, maxHeight: 35)
            }
            .buttonStyle(.borderedProminent)
            .disabled(username.isEmpty || password.isEmpty || isLoading)
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
            Spacer()
        }
        .padding()
        .interactiveDismissDisabled()
    }
    
    private func login() {
        errorMessage.removeAll()
        isLoading = true
        Task {
            let result = await manager.login(
                host: host, port: Int(port),
                username: username, password: password
            )
            switch result {
            case .success:
                return
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct LoginField: View {
    @Binding var text: String
    var title: String
    var placeholder: String
    var isSecure: Bool
    
    init(title: String, placeholder: String, text: Binding<String>, isSecure: Bool = false) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.isSecure = isSecure
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 80, alignment: .leading)
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                }
            }
            .font(.system(size: 15))
        }
        .padding()
        .background(Rectangle().stroke(Color(white: 0.85)))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
