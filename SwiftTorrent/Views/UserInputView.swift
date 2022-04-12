//
//  UserInputView.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/12.
//

import SwiftUI

struct UserInputView: View {
    var receiveValue: (String) -> ()
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var text = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextEditor(text: $text)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                        .frame(minHeight: 60, maxHeight: 200)
                        .overlay(alignment: .topLeading) {
                            if text.isEmpty {
                                Text("magnet:")
                                    .foregroundColor(.gray)
                                    .padding([.leading], 5)
                                    .padding([.top], 8)
                            }
                        }
                        .font(.monospaced(.subheadline)())
                } header: {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Enter one link per line.")
                                .textCase(nil)
                                .font(.headline)
                                .foregroundColor(.black)
                            Text("HTTP links, Magnet links and info-hashes are supported")
                                .lineLimit(2)
                                .textCase(nil)
                                .font(.subheadline)
                        }
                        Spacer(minLength: 10)
                        Button {
                            if let clipboard = UIPasteboard.general.string {
                                text += clipboard
                            }
                        } label: {
                            Image(systemName: "doc.on.clipboard")
                                .font(.system(size: 16))
                        }
                    }
                }
            }
            .navigationTitle("Add links")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        receiveValue(text)
                        dismiss()
                    }
                    .disabled(text.isEmpty)
                }
            }
        }
        
    }
}

struct UserInputView_Previews: PreviewProvider {
    static var previews: some View {
        UserInputView { _ in
            return
        }
    }
}
