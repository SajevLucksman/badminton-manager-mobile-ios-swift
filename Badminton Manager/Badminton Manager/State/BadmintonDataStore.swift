//
//  BadmintonDataStore.swift
//  Badminton Manager
//
//  Created by Sajev Lucksman on 2026-07-04.
//
//  Mirrors the web app's useBadmintonData hook.
//  Subscribes to Firestore, computes per-player splits, and exposes reactive data.
//

import SwiftUI
import FirebaseFirestore

@Observable
class BadmintonDataStore {
    // MARK: - Published State

    var document: BadmintonDocument = .empty
    var selectedKey: String
    var isLoading = true
    var error: String?

    // MARK: - Computed

    var players: PlayersData { document.players }
    var currentMonth: MonthData { document.months[selectedKey] ?? .defaultMonth() }
    var currentCredits: [String: Double] { document.credits[selectedKey] ?? [:] }

    let currentKey: String

    // MARK: - Private

    private var listener: ListenerRegistration?

    // MARK: - Init

    init() {
        let now = Date()
        let cal = Calendar.current
        let y = cal.component(.year, from: now)
        let m = cal.component(.month, from: now)
        let key = Self.monthKey(year: y, month: m)
        self.currentKey = key
        self.selectedKey = key
    }

    deinit {
        listener?.remove()
    }

    // MARK: - Subscribe

    func startListening() {
        listener = FirestoreService.shared.subscribe { [weak self] doc in
            guard let self else { return }
            self.document = doc
            self.isLoading = false
            self.error = nil
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    // MARK: - Month Navigation

    func goToPreviousMonth() {
        selectedKey = Self.prevMonthKey(selectedKey)
    }

    func goToNextMonth() {
        selectedKey = Self.nextMonthKey(selectedKey)
    }

    var selectedMonthDisplay: String {
        let parts = selectedKey.split(separator: "-")
        guard parts.count == 2,
              let y = Int(parts[0]),
              let m = Int(parts[1]) else { return selectedKey }
        let months = ["January","February","March","April","May","June","July","August","September","October","November","December"]
        return "\(months[m - 1]) \(y)"
    }

    // MARK: - Computed Totals (mirrors web helpers.js)

    var daysBooked: Int { currentMonth.selectedDays.count }
    var courtTotal: Double { Double(daysBooked) * currentMonth.hourlyRate }
    var shuttleTotal: Double { Double(currentMonth.tinCount) * currentMonth.tinCost + currentMonth.courierCharges }
    var miscTotal: Double { currentMonth.miscExpenses.reduce(0) { $0 + $1.amount } }
    var grandTotal: Double { courtTotal + shuttleTotal + miscTotal }

    var shuttlesTotal: Int { currentMonth.tinCount * 6 + currentMonth.extraShuttles }
    var shuttlesUsed: Int { currentMonth.shuttleDays.count }
    var shuttlesRemaining: Int { max(0, shuttlesTotal - shuttlesUsed) }

    var mainPlayers: [PlayerInfo] {
        players.main.map { PlayerInfo(name: $0, isStandby: false) }
    }

    var standbyPlayers: [PlayerInfo] {
        players.standby.map { PlayerInfo(name: $0, isStandby: true) }
    }

    /// Compute payment rows with per-player cost splitting (mirrors monthTotals in helpers.js)
    var paymentRows: [PaymentRow] {
        let month = currentMonth
        let creditIn = currentCredits

        let isActive: (String) -> Bool = { name in
            let enrolled = self.players.enrolled[name]
            let left = self.players.left[name]
            if let e = enrolled, e > self.selectedKey { return false }
            if let l = left, l <= self.selectedKey { return false }
            return true
        }

        let activeMain = players.main.filter(isActive)
        let activeStandby = players.standby.filter(isActive)
        let allPlayers = activeMain + activeStandby
        let monthlyStandby = Set(month.monthlyStandby)

        // Calculate paid amounts
        var paid: [String: Double] = [:]
        var lastDate: [String: String] = [:]
        allPlayers.forEach { paid[$0] = 0; lastDate[$0] = "" }
        for p in month.payments {
            paid[p.member, default: 0] += p.amount
            if lastDate[p.member, default: ""] < p.dateISO {
                lastDate[p.member] = p.dateISO
            }
        }

        // Determine standby vs main
        let allStandby = activeStandby + activeMain.filter { monthlyStandby.contains($0) }
        let mainActive = activeMain.filter { !monthlyStandby.contains($0) }

        // Calculate standby contributions
        var standbyTotal: Double = 0
        var standbyRows: [PaymentRow] = []
        for m in allStandby {
            let cin = creditIn[m] ?? 0
            let p = paid[m] ?? 0
            standbyTotal += cin + p
            standbyRows.append(PaymentRow(
                member: m, due: 0, paid: p, outstanding: 0, creditOut: 0,
                creditIn: cin, isStandby: true, lastPaidDate: lastDate[m]?.isEmpty == true ? nil : lastDate[m]
            ))
        }

        // Per main player
        let adjusted = max(0, grandTotal - standbyTotal)
        let per = mainActive.isEmpty ? 0 : adjusted / Double(mainActive.count)

        // Standby excess credit
        let standbyExcess = max(0, standbyTotal - grandTotal)
        if standbyExcess > 0 && !allStandby.isEmpty {
            let each = standbyExcess / Double(allStandby.count)
            standbyRows = standbyRows.map { r in
                PaymentRow(member: r.member, due: 0, paid: r.paid, outstanding: 0, creditOut: each,
                           creditIn: r.creditIn, isStandby: true, lastPaidDate: r.lastPaidDate)
            }
        }

        // Main player rows
        var mainRows: [PaymentRow] = []
        for m in mainActive {
            let cin = creditIn[m] ?? 0
            let p = paid[m] ?? 0
            let applied = cin + p
            let outstanding = max(0, per - applied)
            let creditOut = max(0, applied - per)
            mainRows.append(PaymentRow(
                member: m, due: per, paid: p, outstanding: outstanding, creditOut: creditOut,
                creditIn: cin, isStandby: false, lastPaidDate: lastDate[m]?.isEmpty == true ? nil : lastDate[m]
            ))
        }

        return mainRows + standbyRows
    }

    var perPlayer: Double {
        let mainActive = players.main.filter { name in
            let enrolled = self.players.enrolled[name]
            let left = self.players.left[name]
            if let e = enrolled, e > self.selectedKey { return false }
            if let l = left, l <= self.selectedKey { return false }
            return true
        }.filter { !Set(currentMonth.monthlyStandby).contains($0) }

        let activeStandby = players.standby.filter { name in
            let enrolled = self.players.enrolled[name]
            let left = self.players.left[name]
            if let e = enrolled, e > self.selectedKey { return false }
            if let l = left, l <= self.selectedKey { return false }
            return true
        }

        var standbyTotal: Double = 0
        for m in (activeStandby + players.main.filter { Set(currentMonth.monthlyStandby).contains($0) }) {
            standbyTotal += (currentCredits[m] ?? 0) + (currentMonth.payments.filter { $0.member == m }.reduce(0) { $0 + $1.amount })
        }

        let adjusted = max(0, grandTotal - standbyTotal)
        return mainActive.isEmpty ? 0 : adjusted / Double(mainActive.count)
    }

    var totalCollected: Double {
        currentMonth.payments.reduce(0) { $0 + $1.amount }
    }

    var totalExpenses: Double {
        currentMonth.expenses.reduce(0) { $0 + $1.amount + ($1.courierCharges ?? 0) }
    }

    var balance: Double { totalCollected - totalExpenses }

    var bookedDaysSet: Set<Int> { Set(currentMonth.selectedDays) }
    var shuttleDaysSet: Set<Int> { Set(currentMonth.shuttleDays) }

    // MARK: - Admin Actions

    func addPayment(member: String, amount: Double, date: String) async {
        guard var month = document.months[selectedKey] else { return }
        month.payments.append(PaymentEntry(member: member, amount: amount, dateISO: date, ts: Date().timeIntervalSince1970 * 1000))
        document.months[selectedKey] = month
        try? await FirestoreService.shared.save(document: document)
    }

    func addExpense(type: String, amount: Double, shop: String?, date: String?) async {
        guard var month = document.months[selectedKey] else { return }
        month.expenses.append(ExpenseEntry(type: type, amount: amount, shop: shop, date: date))
        document.months[selectedKey] = month
        try? await FirestoreService.shared.save(document: document)
    }

    func toggleBookedDay(_ day: Int) async {
        guard var month = document.months[selectedKey] else { return }
        if let idx = month.selectedDays.firstIndex(of: day) {
            month.selectedDays.remove(at: idx)
        } else {
            month.selectedDays.append(day)
        }
        document.months[selectedKey] = month
        try? await FirestoreService.shared.save(document: document)
    }

    func toggleShuttleDay(_ day: Int) async {
        guard var month = document.months[selectedKey] else { return }
        if let idx = month.shuttleDays.firstIndex(of: day) {
            month.shuttleDays.remove(at: idx)
        } else {
            month.shuttleDays.append(day)
        }
        document.months[selectedKey] = month
        try? await FirestoreService.shared.save(document: document)
    }

    func updateRates(hourlyRate: Double, tinCost: Double, tinCount: Int, courierCharges: Double) async {
        var month = document.months[selectedKey] ?? .defaultMonth()
        month.hourlyRate = hourlyRate
        month.tinCost = tinCost
        month.tinCount = tinCount
        month.courierCharges = courierCharges
        document.months[selectedKey] = month
        try? await FirestoreService.shared.save(document: document)
    }

    // MARK: - Static Helpers

    static func monthKey(year: Int, month: Int) -> String {
        "\(year)-\(String(format: "%02d", month))"
    }

    static func prevMonthKey(_ key: String) -> String {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 2 else { return key }
        var y = parts[0], m = parts[1] - 1
        if m < 1 { m = 12; y -= 1 }
        return monthKey(year: y, month: m)
    }

    static func nextMonthKey(_ key: String) -> String {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 2 else { return key }
        var y = parts[0], m = parts[1] + 1
        if m > 12 { m = 1; y += 1 }
        return monthKey(year: y, month: m)
    }
}
