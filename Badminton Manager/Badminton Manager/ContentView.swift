//
//  ContentView.swift
//  Badminton Manager
//
//  Created by Sajev Lucksman on 2026-07-04.
//

import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()
    @State private var dataStore = BadmintonDataStore()

    var body: some View {
        Group {
            if appState.isAdminLoggedIn {
                AdminDashboardView()
            } else {
                MemberDashboardView()
            }
        }
        .environment(appState)
        .environment(dataStore)
        .sheet(isPresented: Binding(
            get: { appState.showLoginSheet },
            set: { appState.showLoginSheet = $0 }
        )) {
            LoginView()
                .environment(appState)
                .environment(dataStore)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .animation(.easeInOut(duration: 0.3), value: appState.isAdminLoggedIn)
        .onAppear {
            dataStore.startListening()
        }
    }
}

#Preview {
    ContentView()
}
