//
//  LoginView.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/06.
//

import SwiftUI

struct LoginView: View {
    
    enum Field: Hashable {
        case username
        case password
    }
    
    @State private var username: String = ""
    @State private var password: String = ""
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 10) {
            Text("qBittorrent UI")
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
                .onSubmit {
                    print("로그인 요청 보냄 from password")
                }
            Button {
                print("로그인 요청보냄", username, password)
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
    func loginFieldStyle() -> some View {
        self.font(.subheadline)
            .padding(12)
            .background(Color(white: 0.95))
            .cornerRadius(5)
            .frame(maxWidth: .infinity, maxHeight: 40)
    }
}
