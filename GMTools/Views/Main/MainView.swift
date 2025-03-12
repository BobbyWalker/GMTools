//
//  MainView.swift
//  GMTools
//
//  Created by Bobby Walker on 3/11/25.
//

import SwiftUI

struct MainView: View {
    @Bindable var gameViewModel = GameViewModel()
    
    var body: some View {
        Text("Game Systems: \(gameViewModel.systems.count)")
    }
}

#Preview {
    MainView()
}
