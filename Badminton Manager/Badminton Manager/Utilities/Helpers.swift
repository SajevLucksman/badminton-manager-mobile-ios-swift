//
//  Helpers.swift
//  Badminton Manager
//
//  Created by Sajev Lucksman on 2026-07-04.
//

import Foundation

func formatMoney(_ value: Double) -> String {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.minimumFractionDigits = 2
    f.maximumFractionDigits = 2
    return f.string(from: NSNumber(value: value)) ?? "0.00"
}
