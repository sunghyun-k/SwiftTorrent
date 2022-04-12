//
//  TorrentList.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/07.
//

import SwiftUI

struct TorrentList: View {
    @EnvironmentObject var manager: TorrentManager
    
    @State private var sortBy = (kind: SortBy.name, ascending: true)
    private var sortedTorrents: [Torrent] {
        switch sortBy.kind {
        case .name:
            return manager.torrents.sorted(by: \.name, sortBy.ascending ? {$0<$1}:{$0>$1})
        case . size:
            return manager.torrents.sorted(by: \.size, sortBy.ascending ? {$0<$1}:{$0>$1})
        case .progress:
            return manager.torrents.sorted(by: \.progress, sortBy.ascending ? {$0<$1}:{$0>$1})
        case .state:
            return manager.torrents.sorted(by: \.state, sortBy.ascending ? {$0<$1}:{$0>$1})
        case .downloadSpeed:
            return manager.torrents.sorted(by: \.downloadSpeed, sortBy.ascending ? {$0<$1}:{$0>$1})
        }
    }
    
    @State private var editMode = EditMode.inactive
    @State private var selection = Set<String>()
    
    private func exitEditMode() {
        editMode = .inactive
        selection.removeAll()
    }
    
    var body: some View {
        NavigationView {
            List(selection: $selection) {
                ForEach(sortedTorrents) { torrent in
                    NavigationLink {
                        TorrentRow(torrent: torrent)
                        
                    } label: {
                        TorrentRow(torrent: torrent, isEditing: true)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            manager.deleteTorrents([torrent].map { $0.id })
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .animation(.default, value: (sortedTorrents.map { $0.id }))
            .animation(.default, value: editMode)
            .listStyle(.plain)
            .navigationTitle("Transfers")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if editMode != .active {
                        Menu {
                            Button {
                                editMode = .active
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
                            
                            SortMenu(sortBy: $sortBy.kind, ascending: $sortBy.ascending)
                            
                            Divider()
                            Button {
                                print("settings")
                            } label: {
                                Label("Settings", systemImage: "gear")
                            }
                            
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    } else {
                        Menu {
                            SortMenu(sortBy: $sortBy.kind, ascending: $sortBy.ascending)
                        } label: {
                            Image(systemName: "arrow.up.arrow.down.circle")
                        }
                        Button("Done") {
                            exitEditMode()
                        }
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    if editMode == .active {
                        Button {
                            manager.resumeTorrents(Array(selection))
                            exitEditMode()
                        } label: {
                            Image(systemName: "play.fill")
                        }
                        Spacer()
                        Button {
                            manager.pauseTorrents(Array(selection))
                            exitEditMode()
                        } label: {
                            Image(systemName: "pause.fill")
                        }
                        Spacer()
                        Button {
                            manager.deleteTorrents(Array(selection))
                            exitEditMode()
                        } label: {
                            Image(systemName: "trash")
                        }
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

enum SortBy: String, CaseIterable, Identifiable {
    case name = "Name"
    case size = "Size"
    case progress = "Progress"
    case state = "State"
    case downloadSpeed = "Download Speed"
    var id: SortBy { self }
}
struct SortMenu: View {
    @Binding var sortBy: SortBy
    @Binding var ascending: Bool
    
    var body: some View {
        Picker("Sort by", selection: .init(
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
            .pickerStyle(.inline)
    }
}

//struct TorrentList_Previews: PreviewProvider {
//    static var previews: some View {
//        TorrentList()
//    }
//}
