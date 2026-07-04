//
//  FirestoreService.swift
//  Badminton Manager
//
//  Created by Sajev Lucksman on 2026-07-04.
//

import Foundation
import FirebaseFirestore

/// Mirrors the web app's badmintonService.js
/// Collection: "badminton", Document: "data"
/// Structure:
///   - _members: { main: [String], standby: [String], enrolled: {name: monthKey}, left: {name: monthKey} }
///   - credits: { "2026-07": { "Sajev": 200.0, ... } }
///   - months: { "2026-07": { selectedDays, tinCount, hourlyRate, tinCost, payments, expenses, shuttleDays, ... } }
final class FirestoreService {
    static let shared = FirestoreService()

    private let db = Firestore.firestore()
    private let docRef: DocumentReference

    private init() {
        docRef = db.collection("badminton").document("data")
    }

    /// Subscribe to real-time updates on the badminton/data document
    func subscribe(onChange: @escaping (BadmintonDocument) -> Void) -> ListenerRegistration {
        return docRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists,
                  let rawData = snapshot.data() else {
                print("[FirestoreService] No data or error: \(error?.localizedDescription ?? "unknown")")
                return
            }

            let document = Self.parse(rawData: rawData)
            onChange(document)
        }
    }

    /// Save the full document back to Firestore (admin writes)
    func save(document: BadmintonDocument) async throws {
        var payload = Self.serialize(document: document)
        // Add _members back into the payload
        var membersMap: [String: Any] = [
            "main": document.players.main,
            "standby": document.players.standby,
        ]
        if !document.players.enrolled.isEmpty {
            membersMap["enrolled"] = document.players.enrolled
        }
        if !document.players.left.isEmpty {
            membersMap["left"] = document.players.left
        }
        payload["_members"] = membersMap
        try await docRef.setData(payload)
    }

    /// Verify admin credentials (collection: "users", matching username + password)
    func verifyAdmin(username: String, password: String) async -> Bool {
        do {
            let snapshot = try await db.collection("users")
                .whereField("username", isEqualTo: username)
                .whereField("password", isEqualTo: password)
                .getDocuments()
            return !snapshot.documents.isEmpty
        } catch {
            print("[FirestoreService] Auth error: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Parsing

    static func parse(rawData: [String: Any]) -> BadmintonDocument {
        // Extract _members
        let membersRaw = rawData["_members"] as? [String: Any] ?? [:]
        let players = PlayersData(
            main: membersRaw["main"] as? [String] ?? [],
            standby: membersRaw["standby"] as? [String] ?? [],
            enrolled: membersRaw["enrolled"] as? [String: String] ?? [:],
            left: membersRaw["left"] as? [String: String] ?? [:]
        )

        // Extract credits
        var credits: [String: [String: Double]] = [:]
        if let creditsRaw = rawData["credits"] as? [String: Any] {
            for (monthKey, value) in creditsRaw {
                if let monthCredits = value as? [String: Any] {
                    var parsed: [String: Double] = [:]
                    for (name, amount) in monthCredits {
                        parsed[name] = (amount as? NSNumber)?.doubleValue ?? 0
                    }
                    credits[monthKey] = parsed
                }
            }
        }

        // Extract months
        var months: [String: MonthData] = [:]
        if let monthsRaw = rawData["months"] as? [String: Any] {
            for (monthKey, value) in monthsRaw {
                if let monthDict = value as? [String: Any] {
                    months[monthKey] = Self.parseMonth(monthDict)
                }
            }
        }

        return BadmintonDocument(players: players, credits: credits, months: months)
    }

    static func parseMonth(_ dict: [String: Any]) -> MonthData {
        let selectedDays = (dict["selectedDays"] as? [Any])?.compactMap { ($0 as? NSNumber)?.intValue } ?? []
        let tinCount = (dict["tinCount"] as? NSNumber)?.intValue ?? 0
        let hourlyRate = (dict["hourlyRate"] as? NSNumber)?.doubleValue ?? 800
        let tinCost = (dict["tinCost"] as? NSNumber)?.doubleValue ?? 4500
        let courierCharges = (dict["courierCharges"] as? NSNumber)?.doubleValue ?? 0
        let extraShuttles = (dict["extraShuttles"] as? NSNumber)?.intValue ?? 0
        let monthlyStandby = dict["monthlyStandby"] as? [String] ?? []

        // Parse payments
        var payments: [PaymentEntry] = []
        if let paymentsRaw = dict["payments"] as? [[String: Any]] {
            for p in paymentsRaw {
                payments.append(PaymentEntry(
                    member: p["member"] as? String ?? "",
                    amount: (p["amount"] as? NSNumber)?.doubleValue ?? 0,
                    dateISO: p["dateISO"] as? String ?? "",
                    ts: (p["ts"] as? NSNumber)?.doubleValue ?? 0
                ))
            }
        }

        // Parse expenses
        var expenses: [ExpenseEntry] = []
        if let expensesRaw = dict["expenses"] as? [[String: Any]] {
            for e in expensesRaw {
                expenses.append(ExpenseEntry(
                    type: e["type"] as? String ?? "court",
                    amount: (e["amount"] as? NSNumber)?.doubleValue ?? 0,
                    shop: e["shop"] as? String,
                    date: e["date"] as? String,
                    courierCharges: (e["courierCharges"] as? NSNumber)?.doubleValue,
                    desc: e["desc"] as? String
                ))
            }
        }

        // Parse shuttle days
        let shuttleDays = (dict["shuttleDays"] as? [Any])?.compactMap { ($0 as? NSNumber)?.intValue } ?? []

        // Parse misc expenses
        var miscExpenses: [MiscExpense] = []
        if let miscRaw = dict["miscExpenses"] as? [[String: Any]] {
            for m in miscRaw {
                miscExpenses.append(MiscExpense(
                    desc: m["desc"] as? String ?? "",
                    amount: (m["amount"] as? NSNumber)?.doubleValue ?? 0
                ))
            }
        }

        return MonthData(
            selectedDays: selectedDays,
            tinCount: tinCount,
            hourlyRate: hourlyRate,
            tinCost: tinCost,
            courierCharges: courierCharges,
            extraShuttles: extraShuttles,
            monthlyStandby: monthlyStandby,
            payments: payments,
            expenses: expenses,
            shuttleDays: shuttleDays,
            miscExpenses: miscExpenses
        )
    }

    // MARK: - Serialization

    static func serialize(document: BadmintonDocument) -> [String: Any] {
        var payload: [String: Any] = [:]

        // Serialize credits
        var creditsMap: [String: Any] = [:]
        for (monthKey, monthCredits) in document.credits {
            creditsMap[monthKey] = monthCredits
        }
        payload["credits"] = creditsMap

        // Serialize months
        var monthsMap: [String: Any] = [:]
        for (monthKey, month) in document.months {
            monthsMap[monthKey] = serializeMonth(month)
        }
        payload["months"] = monthsMap

        return payload
    }

    static func serializeMonth(_ month: MonthData) -> [String: Any] {
        var dict: [String: Any] = [
            "selectedDays": month.selectedDays,
            "tinCount": month.tinCount,
            "hourlyRate": month.hourlyRate,
            "tinCost": month.tinCost,
            "courierCharges": month.courierCharges,
            "extraShuttles": month.extraShuttles,
            "monthlyStandby": month.monthlyStandby,
            "shuttleDays": month.shuttleDays,
        ]

        dict["payments"] = month.payments.map { p in
            ["member": p.member, "amount": p.amount, "dateISO": p.dateISO, "ts": p.ts] as [String: Any]
        }

        dict["expenses"] = month.expenses.map { e in
            var entry: [String: Any] = ["type": e.type, "amount": e.amount]
            if let shop = e.shop { entry["shop"] = shop }
            if let date = e.date { entry["date"] = date }
            if let courier = e.courierCharges { entry["courierCharges"] = courier }
            if let desc = e.desc { entry["desc"] = desc }
            return entry
        }

        if !month.miscExpenses.isEmpty {
            dict["miscExpenses"] = month.miscExpenses.map { ["desc": $0.desc, "amount": $0.amount] as [String: Any] }
        }

        return dict
    }
}
