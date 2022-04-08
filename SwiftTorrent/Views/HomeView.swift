//
//  HomeView.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/08.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var manager: TorrentManager
    
    var body: some View {
        if manager.currentUser == nil {
            LoginView()
        } else {
            TorrentList()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
