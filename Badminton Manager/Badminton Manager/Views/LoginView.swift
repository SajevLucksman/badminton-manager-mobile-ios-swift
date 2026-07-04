//
//  LoginView.swift
//  Badminton Manager
//
//  Created by Sajev Lucksman on 2026-07-04.
//

import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()
            CourtBackgroundView().ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Header
                VStack(spacing: 8) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 50, weight: .light))
                        .foregroundStyle(
                            .linearGradient(colors: [AppTheme.accent, AppTheme.accentSecondary], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(color: AppTheme.accent.opacity(0.4), radius: 10)

                    Text("Admin Login")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Log in to manage badminton charges")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                // Form
                VStack(spacing: 14) {
                    // Username
                    HStack(spacing: 10) {
                        Image(systemName: "person.fill")
                            .foregroundStyle(AppTheme.textMuted)
                            .frame(width: 20)
                        TextField("Username", text: $username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.06))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.cardBorder))
                    )

                    // Password
                    HStack(spacing: 10) {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(AppTheme.textMuted)
                            .frame(width: 20)
                        SecureField("Password", text: $password)
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.06))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.cardBorder))
                    )

                    // Error message
                    if !errorMessage.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                            Text(errorMessage)
                        }
                        .font(.caption)
                        .foregroundStyle(AppTheme.danger)
                    }

                    // Login button
                    Button(action: handleLogin) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.8)
                            }
                            Text(isLoading ? "Logging in…" : "Log in as Admin")
                                .font(.subheadline.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(colors: [AppTheme.accent, AppTheme.accentSecondary], startPoint: .leading, endPoint: .trailing)
                                )
                        )
                        .foregroundStyle(.black)
                    }
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.7 : 1)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial.opacity(0.3))
                        .background(RoundedRectangle(cornerRadius: 20).fill(AppTheme.cardBg))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.cardBorder))
                )

                // Hint
                Text("Contact **Sajev Lucksman** for access.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textMuted)

                Spacer()
                Spacer()
            }
            .padding(.horizontal, 28)
        }
        .preferredColorScheme(.dark)
    }

    private func handleLogin() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Enter username and password."
            return
        }
        errorMessage = ""
        isLoading = true

        Task {
            let valid = await FirestoreService.shared.verifyAdmin(username: username, password: password)
            if valid {
                appState.login()
            } else {
                errorMessage = "Invalid credentials."
            }
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
        .environment(AppState())
}
