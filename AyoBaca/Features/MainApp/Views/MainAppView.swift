//
//  MainAppView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 04/04/25.
//

import SwiftUI

struct MainAppView: View {
    @Binding var currentScreen: AppScreen
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    MainAppView(currentScreen: .constant(.mainApp))
}
