//
//  StatViews.swift
//  Badminton Manager
//
//  Created by Sajev Lucksman on 2026-07-04.
//

import SwiftUI

struct ShuttleStatView: View {
    let label: String
    let value: String
    let sub: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(color)
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(AppTheme.textSecondary)
            Text(sub)
                .font(.caption2)
                .foregroundStyle(AppTheme.textMuted)
        }
    }
}

struct FinanceStatView: View {
    let label: String
    let amount: Double
    let color: Color
    var showSign: Bool = false

    var body: some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(AppTheme.textMuted)
            Text("\(showSign && amount > 0 ? "+" : "")LKR \(formatMoney(abs(amount)))")
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
        }
    }
}
