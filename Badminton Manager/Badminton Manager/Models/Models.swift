//
//  Models.swift
//  Badminton Manager
//
//  Created by Sajev Lucksman on 2026-07-04.
//

import SwiftUI

// MARK: - Firestore Document Models

/// Top-level document structure from badminton/data
struct BadmintonDocument {
    var players: PlayersData
    var credits: [String: [String: Double]]  // monthKey -> { playerName: creditAmount }
    var months: [String: MonthData]          // monthKey -> month data
}

struct PlayersData {
    var main: [String]
    var standby: [String]
    var enrolled: [String: String]   // playerName -> monthKey when enrolled
    var left: [String: String]       // playerName -> monthKey when left
}

struct MonthData {
    var selectedDays: [Int]
    var tinCount: Int
    var hourlyRate: Double
    var tinCost: Double
    var courierCharges: Double
    var extraShuttles: Int
    var monthlyStandby: [String]
    var payments: [PaymentEntry]
    var expenses: [ExpenseEntry]
    var shuttleDays: [Int]
    var miscExpenses: [MiscExpense]
}

struct PaymentEntry: Identifiable {
    let id = UUID()
    var member: String
    var amount: Double
    var dateISO: String
    var ts: Double
}

struct ExpenseEntry: Identifiable {
    let id = UUID()
    var type: String        // "court", "shuttle", "misc"
    var amount: Double
    var shop: String?
    var date: String?
    var courierCharges: Double?
    var desc: String?
}

struct MiscExpense: Identifiable {
    let id = UUID()
    var desc: String
    var amount: Double
}

// MARK: - UI Display Models

struct PlayerInfo: Identifiable {
    let id = UUID()
    let name: String
    let isStandby: Bool
}

struct PaymentRow: Identifiable {
    let id = UUID()
    let member: String
    let due: Double
    let paid: Double
    let outstanding: Double
    let creditOut: Double
    let creditIn: Double
    let isStandby: Bool
    let lastPaidDate: String?

    var status: PaymentStatus {
        if isStandby { return .standby }
        if due == 0 && paid == 0 { return .notPaid }
        if creditOut > 0 || outstanding == 0 { return .paid }
        if paid > 0 { return .due }
        return .notPaid
    }
}

enum PaymentStatus {
    case paid, due, notPaid, standby

    var label: String {
        switch self {
        case .paid: return "Paid"
        case .due: return "Due"
        case .notPaid: return "Not Paid"
        case .standby: return "Standby"
        }
    }

    var color: Color {
        switch self {
        case .paid: return AppTheme.success
        case .due: return AppTheme.warning
        case .notPaid: return AppTheme.danger
        case .standby: return AppTheme.purple
        }
    }
}

// MARK: - Helpers

extension BadmintonDocument {
    static var empty: BadmintonDocument {
        BadmintonDocument(players: PlayersData(main: [], standby: [], enrolled: [:], left: [:]), credits: [:], months: [:])
    }
}

extension MonthData {
    static func defaultMonth(hourlyRate: Double = 800, tinCost: Double = 4500) -> MonthData {
        MonthData(
            selectedDays: [],
            tinCount: 0,
            hourlyRate: hourlyRate,
            tinCost: tinCost,
            courierCharges: 0,
            extraShuttles: 0,
            monthlyStandby: [],
            payments: [],
            expenses: [],
            shuttleDays: [],
            miscExpenses: []
        )
    }
}
