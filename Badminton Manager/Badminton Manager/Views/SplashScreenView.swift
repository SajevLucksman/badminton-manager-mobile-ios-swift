//
//  SplashScreenView.swift
//  Badminton Manager
//
//  Created by Sajev Lucksman on 2026-07-04.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var isActive = false

    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                AppTheme.bg.ignoresSafeArea()
                CourtBackgroundView().ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    // Club Logo
                    Image("SplashLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: AppTheme.accent.opacity(0.3), radius: 20)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)

                    // Club Name
                    VStack(spacing: 6) {
                        Text("Shuttle and Scales")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("Harmony Smashes")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .opacity(textOpacity)

                    Spacer()

                    // Loading indicator
                    ProgressView()
                        .tint(AppTheme.accent)
                        .opacity(textOpacity)

                    Spacer()
                        .frame(height: 60)
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    logoScale = 1.0
                    logoOpacity = 1.0
                }
                withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                    textOpacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
