//
//  AdminDashboardView.swift
//  Badminton Manager
//
//  Created by Sajev Lucksman on 2026-07-04.
//

import SwiftUI

struct AdminDashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(BadmintonDataStore.self) private var store

    // Payment form
    @State private var payMember: String = ""
    @State private var payAmount: String = ""
    @State private var payDate: Date = Date()

    // Expense form
    @State private var expenseType: String = "court"
    @State private var expenseAmount: String = ""
    @State private var expenseShop: String = ""

    // Rates form
    @State private var courtRate: String = ""
    @State private var tinCost: String = ""
    @State private var tinCount: String = ""
    @State private var courierCharges: String = ""
    @State private var ratesLoaded = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                adminHeaderSection
                ratesSection
                calendarEditSection
                addPaymentSection
                addExpenseSection
                shuttleEditSection
                playersManageSection
                footerSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(
            ZStack {
                AppTheme.bg.ignoresSafeArea()
                CourtBackgroundView().ignoresSafeArea()
            }
        )
        .preferredColorScheme(.dark)
        .onChange(of: store.selectedKey) { loadRates() }
        .onAppear { loadRates() }
    }

    private func loadRates() {
        let month = store.currentMonth
        courtRate = String(Int(month.hourlyRate))
        tinCost = String(Int(month.tinCost))
        tinCount = String(month.tinCount)
        courierCharges = String(Int(month.courierCharges))
        ratesLoaded = true
    }

    // MARK: - Admin Header

    private var adminHeaderSection: some View {
        VStack(spacing: 12) {
            // Top bar: Logout + Title + Member View
            HStack {
                Button(action: { appState.logout() }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.danger)
                }

                Spacer()

                Text("Admin")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Button(action: { appState.logout() }) {
                    Image(systemName: "eye.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.accentSecondary)
                }
            }

            // Month Navigation
            HStack(spacing: 16) {
                Button(action: { store.goToPreviousMonth() }) {
                    Image(systemName: "chevron.left")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.accent)
                }

                Text(store.selectedMonthDisplay)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Button(action: { store.goToNextMonth() }) {
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }

    // MARK: - Rates Section

    private var ratesSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                CardHeader(icon: "slider.horizontal.3", title: "Rates & Charges")

                VStack(spacing: 12) {
                    AdminInputRow(label: "Court rate/hr (LKR)", value: $courtRate, icon: "building.2")
                    AdminInputRow(label: "Cost per tin (LKR)", value: $tinCost, icon: "case.fill")
                    AdminInputRow(label: "Tins this month", value: $tinCount, icon: "shippingbox.fill")
                    AdminInputRow(label: "Courier charges (LKR)", value: $courierCharges, icon: "bicycle")
                }

                // Save rates button
                Button(action: saveRates) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Rates")
                            .font(.caption.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(11)
                    .background(RoundedRectangle(cornerRadius: 10).fill(AppTheme.accent.opacity(0.15)))
                    .foregroundStyle(AppTheme.accent)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.accent.opacity(0.3)))
                }

                Divider().overlay(AppTheme.cardBorder)

                // Computed totals
                HStack {
                    VStack(spacing: 2) {
                        Text("Court Total").font(.caption2).foregroundStyle(AppTheme.textMuted)
                        Text("LKR \(formatMoney(store.courtTotal))")
                            .font(.caption.weight(.bold)).foregroundStyle(AppTheme.success)
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text("Shuttle Total").font(.caption2).foregroundStyle(AppTheme.textMuted)
                        Text("LKR \(formatMoney(store.shuttleTotal))")
                            .font(.caption.weight(.bold)).foregroundStyle(AppTheme.accentSecondary)
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text("Grand Total").font(.caption2).foregroundStyle(AppTheme.textMuted)
                        Text("LKR \(formatMoney(store.grandTotal))")
                            .font(.caption.weight(.bold)).foregroundStyle(AppTheme.purple)
                    }
                }
            }
        }
    }

    // MARK: - Calendar Edit

    private var calendarEditSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                CardHeader(icon: "calendar.badge.plus", title: "Court Bookings — Tap to Toggle")

                HStack(spacing: 14) {
                    HStack(spacing: 4) {
                        Circle().fill(AppTheme.accent).frame(width: 7, height: 7)
                        Text("Booked").font(.caption2).foregroundStyle(AppTheme.textMuted)
                    }
                    HStack(spacing: 4) {
                        Circle().fill(Color.white.opacity(0.12)).frame(width: 7, height: 7)
                        Text("Tap to book").font(.caption2).foregroundStyle(AppTheme.textMuted)
                    }
                }

                let parts = store.selectedKey.split(separator: "-").compactMap { Int($0) }
                if parts.count == 2 {
                    AdminCalendarView(year: parts[0], month: parts[1], bookedDays: store.bookedDaysSet) { day in
                        Task { await store.toggleBookedDay(day) }
                    }
                }

                Text("\(store.daysBooked) days booked")
                    .font(.caption2).foregroundStyle(AppTheme.textSecondary)
            }
        }
    }

    // MARK: - Add Payment

    private var addPaymentSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                CardHeader(icon: "plus.circle.fill", title: "Record Payment")

                VStack(spacing: 10) {
                    // Member picker dropdown
                    HStack(spacing: 10) {
                        Image(systemName: "person.fill").foregroundStyle(AppTheme.textMuted).frame(width: 20)
                        Picker("Select member", selection: $payMember) {
                            Text("Select member").tag("")
                            ForEach(store.players.main, id: \.self) { name in
                                Text(name).tag(name)
                            }
                            ForEach(store.players.standby, id: \.self) { name in
                                Text(name).tag(name)
                            }
                        }
                        .tint(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.05)).overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.cardBorder)))

                    HStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "banknote").foregroundStyle(AppTheme.textMuted).frame(width: 20)
                            TextField("Amount", text: $payAmount)
                                .keyboardType(.decimalPad).foregroundStyle(AppTheme.textPrimary)
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.05)).overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.cardBorder)))

                        DatePicker("", selection: $payDate, displayedComponents: .date)
                            .labelsHidden().colorScheme(.dark).frame(width: 110)
                    }

                    Button(action: addPayment) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Payment").font(.caption.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity).padding(11)
                        .background(RoundedRectangle(cornerRadius: 10).fill(AppTheme.success.opacity(0.15)))
                        .foregroundStyle(AppTheme.success)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.success.opacity(0.3)))
                    }
                }
            }
        }
    }

    // MARK: - Add Expense

    private var addExpenseSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                CardHeader(icon: "cart.fill", title: "Record Expense")

                VStack(spacing: 10) {
                    HStack(spacing: 8) {
                        ExpenseTypeButton(label: "Court", type: "court", selected: $expenseType, color: AppTheme.accentSecondary)
                        ExpenseTypeButton(label: "Shuttle", type: "shuttle", selected: $expenseType, color: AppTheme.success)
                        ExpenseTypeButton(label: "Misc", type: "misc", selected: $expenseType, color: AppTheme.purple)
                    }

                    HStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "banknote").foregroundStyle(AppTheme.textMuted).frame(width: 20)
                            TextField("Amount (LKR)", text: $expenseAmount)
                                .keyboardType(.decimalPad).foregroundStyle(AppTheme.textPrimary)
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.05)).overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.cardBorder)))

                        HStack(spacing: 8) {
                            Image(systemName: "storefront").foregroundStyle(AppTheme.textMuted).frame(width: 20)
                            TextField("Shop", text: $expenseShop).foregroundStyle(AppTheme.textPrimary)
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.05)).overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.cardBorder)))
                    }

                    Button(action: addExpense) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Expense").font(.caption.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity).padding(11)
                        .background(RoundedRectangle(cornerRadius: 10).fill(AppTheme.warning.opacity(0.15)))
                        .foregroundStyle(AppTheme.warning)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.warning.opacity(0.3)))
                    }
                }
            }
        }
    }

    // MARK: - Shuttle Edit

    private var shuttleEditSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                CardHeader(icon: "figure.badminton", title: "Shuttle Usage — Tap Days")

                let parts = store.selectedKey.split(separator: "-").compactMap { Int($0) }
                if parts.count == 2 {
                    AdminCalendarView(year: parts[0], month: parts[1], bookedDays: store.shuttleDaysSet) { day in
                        Task { await store.toggleShuttleDay(day) }
                    }
                }

                HStack {
                    Text("\(store.shuttlesUsed) shuttles used")
                        .font(.caption2).foregroundStyle(AppTheme.textSecondary)
                    Spacer()
                    Text("\(store.shuttlesRemaining) remaining")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(store.shuttlesRemaining <= 2 ? AppTheme.danger : AppTheme.success)
                }
            }
        }
    }

    // MARK: - Players Manage

    private var playersManageSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                CardHeader(icon: "person.badge.plus", title: "Players")

                VStack(alignment: .leading, spacing: 6) {
                    Label("MAIN PLAYERS", systemImage: "circle.fill")
                        .font(.caption2.weight(.bold)).foregroundStyle(AppTheme.accent)
                    FlowLayout(spacing: 8) {
                        ForEach(store.mainPlayers) { p in
                            PillView(name: p.name, color: AppTheme.accent)
                        }
                    }
                }

                Divider().overlay(AppTheme.cardBorder)

                VStack(alignment: .leading, spacing: 6) {
                    Label("STANDBY PLAYERS", systemImage: "circle.fill")
                        .font(.caption2.weight(.bold)).foregroundStyle(AppTheme.warning)
                    FlowLayout(spacing: 8) {
                        ForEach(store.standbyPlayers) { p in
                            PillView(name: p.name, color: AppTheme.warning)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        Text("© 2026 Sajev Lucksman")
            .font(.caption2).foregroundStyle(AppTheme.textMuted).padding(.top, 4)
    }

    // MARK: - Actions

    private func saveRates() {
        Task {
            await store.updateRates(
                hourlyRate: Double(courtRate) ?? 800,
                tinCost: Double(tinCost) ?? 4500,
                tinCount: Int(tinCount) ?? 0,
                courierCharges: Double(courierCharges) ?? 0
            )
        }
    }

    private func addPayment() {
        guard !payMember.isEmpty, let amount = Double(payAmount), amount > 0 else { return }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let dateStr = formatter.string(from: payDate)
        Task {
            await store.addPayment(member: payMember, amount: amount, date: dateStr)
            payMember = ""
            payAmount = ""
        }
    }

    private func addExpense() {
        guard let amount = Double(expenseAmount), amount > 0 else { return }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let dateStr = formatter.string(from: Date())
        Task {
            await store.addExpense(type: expenseType, amount: amount, shop: expenseShop.isEmpty ? nil : expenseShop, date: dateStr)
            expenseAmount = ""
            expenseShop = ""
        }
    }
}

// MARK: - Admin Sub-Components

struct AdminInputRow: View {
    let label: String
    @Binding var value: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundStyle(AppTheme.textMuted).frame(width: 20)
            Text(label).font(.caption).foregroundStyle(AppTheme.textSecondary)
            Spacer()
            TextField("", text: $value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(AppTheme.textPrimary)
                .font(.subheadline.weight(.semibold))
                .frame(width: 100)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.04)))
    }
}

struct ExpenseTypeButton: View {
    let label: String
    let type: String
    @Binding var selected: String
    let color: Color

    var isSelected: Bool { selected == type }

    var body: some View {
        Button(action: { selected = type }) {
            Text(label)
                .font(.caption.weight(.semibold))
                .frame(maxWidth: .infinity).padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 8).fill(isSelected ? color.opacity(0.2) : Color.white.opacity(0.04)))
                .foregroundStyle(isSelected ? color : AppTheme.textMuted)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? color.opacity(0.4) : Color.clear))
        }
    }
}

struct AdminCalendarView: View {
    let year: Int
    let month: Int
    let bookedDays: Set<Int>
    let onToggle: (Int) -> Void

    private let weekdays = ["M", "T", "W", "T", "F", "S", "S"]

    private var daysInMonth: Int {
        let cal = Calendar.current
        guard let date = cal.date(from: DateComponents(year: year, month: month)),
              let range = cal.range(of: .day, in: .month, for: date) else { return 30 }
        return range.count
    }

    private var firstWeekdayOffset: Int {
        let cal = Calendar.current
        guard let date = cal.date(from: DateComponents(year: year, month: month, day: 1)) else { return 0 }
        let wd = cal.component(.weekday, from: date)
        return wd == 1 ? 6 : wd - 2
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { d in
                    Text(d).font(.caption2.weight(.semibold)).foregroundStyle(AppTheme.textMuted).frame(maxWidth: .infinity)
                }
            }

            let totalCells = firstWeekdayOffset + daysInMonth
            let rows = (totalCells + 6) / 7

            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { col in
                        let idx = row * 7 + col
                        let day = idx - firstWeekdayOffset + 1
                        if day >= 1 && day <= daysInMonth {
                            let booked = bookedDays.contains(day)
                            Button(action: { onToggle(day) }) {
                                Text("\(day)")
                                    .font(.caption2.weight(booked ? .bold : .regular))
                                    .foregroundStyle(booked ? .white : AppTheme.textSecondary)
                                    .frame(maxWidth: .infinity).frame(height: 32)
                                    .background(
                                        Circle()
                                            .fill(booked ? AppTheme.accent : Color.white.opacity(0.04))
                                            .frame(width: 28, height: 28)
                                    )
                            }
                        } else {
                            Text("").frame(maxWidth: .infinity).frame(height: 32)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AdminDashboardView()
        .environment(AppState())
        .environment(BadmintonDataStore())
}
