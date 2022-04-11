//
//  TorrentList.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/07.
//

import SwiftUI

struct TorrentList: View {
    @EnvironmentObject var manager: TorrentManager
    
    enum SortBy: String, CaseIterable, Identifiable {
        case name = "Name"
        case size = "Size"
        case progress = "Progress"
        case state = "State"
        case downloadSpeed = "Download Speed"
        var id: SortBy { self }
    }
    @State var sortBy = SortBy.name
    @State var ascending = true
    var sortedTorrents: [Torrent] {
        switch sortBy {
        case .name:
            return manager.torrents.sorted(by: \.name, ascending ? {$0<$1}:{$0>$1})
        case . size:
            return manager.torrents.sorted(by: \.size, ascending ? {$0<$1}:{$0>$1})
        case .progress:
            return manager.torrents.sorted(by: \.progress, ascending ? {$0<$1}:{$0>$1})
        case .state:
            return manager.torrents.sorted(by: \.state, ascending ? {$0<$1}:{$0>$1})
        case .downloadSpeed:
            return manager.torrents.sorted(by: \.downloadSpeed, ascending ? {$0<$1}:{$0>$1})
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedTorrents) { torrent in
                    NavigationLink {
                        TorrentRow(torrent: torrent)
                    } label: {
                        TorrentRow(torrent: torrent)
                    }
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
            .animation(.default, value: sortedTorrents.map { $0.id })
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
                        
                        Picker("dd", selection: .init(
                            get: { sortBy },
                            set: { newValue in
                                if sortBy == newValue {
                                    ascending.toggle()
                                } else {
                                    sortBy = newValue
                                    ascending = true
                                }
                            })) {
                                ForEach(SortBy.allCases) { kind in
                                    if kind == sortBy {
                                        Label(kind.rawValue, systemImage: ascending ? "chevron.up" : "chevron.down")
                                    } else {
                                        Text(kind.rawValue)
                                    }
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
        .sheet(isPresented: .init(
            get: { manager.loginToken == nil },
            set: { _ in }
        )) {
            LoginView(loginToken: $manager.loginToken, loginFetcher: manager.loginFetcher())
        }
    }
}

//struct TorrentList_Previews: PreviewProvider {
//    static var previews: some View {
//        TorrentList()
//    }
//}
