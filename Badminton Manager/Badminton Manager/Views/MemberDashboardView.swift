//
//  MemberDashboardView.swift
//  Badminton Manager
//
//  Created by Sajev Lucksman on 2026-07-04.
//

import SwiftUI

struct MemberDashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(BadmintonDataStore.self) private var store

    var body: some View {
        Group {
            if store.isLoading {
                loadingView
            } else {
                dashboardContent
            }
        }
        .background(
            ZStack {
                AppTheme.bg.ignoresSafeArea()
                CourtBackgroundView().ignoresSafeArea()
            }
        )
        .preferredColorScheme(.dark)
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(AppTheme.accent)
                .scaleEffect(1.5)
            Text("Loading data...")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var dashboardContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                headerSection
                monthlySummarySection
                calendarSection
                playersSection
                shuttleProgressSection
                financialOverviewSection
                paymentStatusSection
                footerSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "figure.badminton")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(
                    .linearGradient(colors: [AppTheme.accent, AppTheme.accentSecondary], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .shadow(color: AppTheme.accent.opacity(0.4), radius: 8)

            Text("Shuttle and Scales")
                .font(.title2.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)

            Text("Harmony Smashes")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)

            // Month Navigation
            HStack(spacing: 20) {
                Button(action: { store.goToPreviousMonth() }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.accent)
                }

                Text(store.selectedMonthDisplay)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(minWidth: 130)

                Button(action: { store.goToNextMonth() }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .padding(.top, 6)

            // Admin button
            Button(action: { appState.showLoginSheet = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.caption)
                    Text("Admin")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(AppTheme.accentSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Capsule().fill(AppTheme.accentSecondary.opacity(0.12)))
                .overlay(Capsule().stroke(AppTheme.accentSecondary.opacity(0.3), lineWidth: 0.5))
            }
            .padding(.top, 6)
        }
        .padding(.bottom, 4)
    }

    // MARK: - Monthly Summary

    private var monthlySummarySection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                StatCard(icon: "calendar.badge.checkmark", title: "Days Booked", value: "\(store.daysBooked)", color: AppTheme.accentSecondary)
                StatCard(icon: "person.fill", title: "Per Player", value: "LKR \(formatMoney(store.perPlayer))", color: AppTheme.warning)
            }
            HStack(spacing: 10) {
                StatCard(icon: "building.2.fill", title: "Court Total", value: "LKR \(formatMoney(store.courtTotal))", color: AppTheme.success)
                StatCard(icon: "sum", title: "Grand Total", value: "LKR \(formatMoney(store.grandTotal))", color: AppTheme.purple)
            }
        }
    }

    // MARK: - Players

    private var playersSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                CardHeader(icon: "person.3.fill", title: "Players")

                VStack(alignment: .leading, spacing: 6) {
                    Label("MAIN", systemImage: "circle.fill")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppTheme.accent)
                    FlowLayout(spacing: 8) {
                        ForEach(store.mainPlayers) { p in
                            PillView(name: p.name, color: AppTheme.accent)
                        }
                    }
                }

                Divider().overlay(AppTheme.cardBorder)

                VStack(alignment: .leading, spacing: 6) {
                    Label("STANDBY", systemImage: "circle.fill")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppTheme.warning)
                    FlowLayout(spacing: 8) {
                        ForEach(store.standbyPlayers) { p in
                            PillView(name: p.name, color: AppTheme.warning)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Shuttle Tracker

    private var shuttleProgressSection: some View {
        GlassCard {
            VStack(spacing: 16) {
                CardHeader(icon: "figure.badminton", title: "Shuttle Tracker")

                HStack {
                    ShuttleStatView(label: "Tins", value: "\(store.currentMonth.tinCount)", sub: "6/tin", color: AppTheme.accentSecondary)
                    Spacer()
                    ShuttleStatView(label: "Used", value: "\(store.shuttlesUsed)", sub: "shuttles", color: AppTheme.danger)
                    Spacer()
                    ShuttleStatView(label: "Left", value: "\(store.shuttlesRemaining)", sub: "shuttles", color: AppTheme.success)
                }

                VStack(alignment: .leading, spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.06))
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(colors: [AppTheme.accent, AppTheme.accentSecondary], startPoint: .leading, endPoint: .trailing)
                                )
                                .frame(width: store.shuttlesTotal > 0 ? geo.size.width * CGFloat(store.shuttlesRemaining) / CGFloat(store.shuttlesTotal) : 0)
                                .shadow(color: AppTheme.accent.opacity(0.4), radius: 4)
                        }
                    }
                    .frame(height: 10)

                    Text("\(store.shuttlesRemaining)/\(store.shuttlesTotal) remaining")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textMuted)
                }
            }
        }
    }

    // MARK: - Financial Overview

    private var financialOverviewSection: some View {
        GlassCard {
            VStack(spacing: 14) {
                CardHeader(icon: "chart.bar.fill", title: "Finances")

                HStack(spacing: 0) {
                    FinanceStatView(label: "Collected", amount: store.totalCollected, color: AppTheme.success)
                    Spacer()
                    FinanceStatView(label: "Expenses", amount: store.totalExpenses, color: AppTheme.danger)
                    Spacer()
                    FinanceStatView(label: "Balance", amount: store.balance, color: store.balance >= 0 ? AppTheme.success : AppTheme.danger, showSign: true)
                }

                HStack(spacing: 6) {
                    Image(systemName: store.balance >= 0 ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                        .font(.caption)
                    Text(store.balance > 0
                         ? "Surplus LKR \(formatMoney(store.balance))"
                         : store.balance == 0 ? "Balanced" : "Deficit LKR \(formatMoney(abs(store.balance)))")
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(store.balance >= 0 ? AppTheme.success : AppTheme.danger)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill((store.balance >= 0 ? AppTheme.success : AppTheme.danger).opacity(0.1))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke((store.balance >= 0 ? AppTheme.success : AppTheme.danger).opacity(0.2)))
                )
            }
        }
    }

    // MARK: - Payment Status

    private var paymentStatusSection: some View {
        GlassCard {
            VStack(spacing: 0) {
                CardHeader(icon: "creditcard.fill", title: "Payments")
                    .padding(.bottom, 10)

                if store.paymentRows.isEmpty {
                    Text("No data for this month.")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textMuted)
                        .padding(.vertical, 20)
                } else {
                    ForEach(Array(store.paymentRows.enumerated()), id: \.element.id) { index, payment in
                        PaymentItemView(payment: payment)
                        if index < store.paymentRows.count - 1 {
                            Divider().overlay(AppTheme.cardBorder).padding(.leading, 48)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Calendar

    private var calendarSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                CardHeader(icon: "calendar", title: "Court Bookings")

                HStack(spacing: 14) {
                    HStack(spacing: 4) {
                        Circle().fill(AppTheme.accent).frame(width: 7, height: 7)
                        Text("Booked").font(.caption2).foregroundStyle(AppTheme.textMuted)
                    }
                    HStack(spacing: 4) {
                        Circle().fill(Color.white.opacity(0.12)).frame(width: 7, height: 7)
                        Text("Available").font(.caption2).foregroundStyle(AppTheme.textMuted)
                    }
                }

                let parts = store.selectedKey.split(separator: "-").compactMap { Int($0) }
                if parts.count == 2 {
                    MiniCalendarView(year: parts[0], month: parts[1], bookedDays: store.bookedDaysSet)
                }
            }
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        Text("© 2026 Sajev Lucksman")
            .font(.caption2)
            .foregroundStyle(AppTheme.textMuted)
            .padding(.top, 4)
    }
}

#Preview {
    MemberDashboardView()
        .environment(AppState())
        .environment(BadmintonDataStore())
}
