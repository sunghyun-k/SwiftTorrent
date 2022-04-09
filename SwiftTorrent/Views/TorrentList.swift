//
//  TorrentList.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/07.
//

import SwiftUI

struct TorrentList: View {
    @EnvironmentObject var manager: TorrentManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(manager.torrents) { torrent in
                    TorrentRow(torrent: torrent)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                manager.deleteTorrents([torrent])
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Transfers")
            .toolbar {
                ToolbarItem {
                    Menu {
                        Button {
                            print("Select")
                        } label: {
                            Label("Select", systemImage: "checkmark.circle")
                        }
                        Button {
                            print("file")
                        } label: {
                            Label("Add torrent files", systemImage: "doc.badge.plus")
                        }
                        Button {
                            print("link")
                        } label: {
                            Label("Add torrent links", systemImage: "link.badge.plus")
                        }
                        Divider()
                        Picker("Sort", selection: .constant(0)) {
                            ForEach(0..<3) { name in
                                Text("\(name)")
                            }
                        }
                        Divider()
                        Button {
                            print("settings")
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }

                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }

                }
            }
        }
    }
}

struct TorrentList_Previews: PreviewProvider {
    static var previews: some View {
        TorrentList()
    }
}
