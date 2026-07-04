//
//  PaymentItemView.swift
//  Badminton Manager
//
//  Created by Sajev Lucksman on 2026-07-04.
//

import SwiftUI

struct PaymentItemView: View {
    let payment: PaymentRow

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(payment.status.color.opacity(0.15))
                .frame(width: 38, height: 38)
                .overlay(
                    Text(String(payment.member.prefix(1)))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(payment.status.color)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(payment.member)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textPrimary)

                if payment.isStandby {
                    Text("Standby").font(.caption2).foregroundStyle(AppTheme.textMuted)
                } else if payment.outstanding > 0 {
                    Text("Owes LKR \(formatMoney(payment.outstanding))").font(.caption2).foregroundStyle(AppTheme.danger)
                } else if payment.creditOut > 0 {
                    Text("Credit LKR \(formatMoney(payment.creditOut))").font(.caption2).foregroundStyle(AppTheme.success)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("LKR \(formatMoney(payment.paid))")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(payment.status.label)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(payment.status.color)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(payment.status.color.opacity(0.15)))
            }
        }
        .padding(.vertical, 8)
    }
}
