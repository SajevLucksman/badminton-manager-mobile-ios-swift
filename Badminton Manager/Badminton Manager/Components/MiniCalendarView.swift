//
//  MiniCalendarView.swift
//  Badminton Manager
//
//  Created by Sajev Lucksman on 2026-07-04.
//

import SwiftUI

struct MiniCalendarView: View {
    let year: Int
    let month: Int
    let bookedDays: Set<Int>

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
                            Text("\(day)")
                                .font(.caption2.weight(booked ? .bold : .regular))
                                .foregroundStyle(booked ? .white : AppTheme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 30)
                                .background(
                                    Circle()
                                        .fill(booked ? AppTheme.accent : Color.clear)
                                        .frame(width: 26, height: 26)
                                        .shadow(color: booked ? AppTheme.accent.opacity(0.3) : .clear, radius: 3)
                                )
                        } else {
                            Text("").frame(maxWidth: .infinity).frame(height: 30)
                        }
                    }
                }
            }
        }
    }
}
