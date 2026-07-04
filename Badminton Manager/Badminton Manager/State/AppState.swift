//
//  AppState.swift
//  Badminton Manager
//
//  Created by Sajev Lucksman on 2026-07-04.
//

import SwiftUI

@Observable
class AppState {
    var isAdminLoggedIn: Bool = false
    var showLoginSheet: Bool = false

    func login() {
        isAdminLoggedIn = true
        showLoginSheet = false
    }

    func logout() {
        isAdminLoggedIn = false
    }
}
