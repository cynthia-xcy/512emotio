//
//  CalendarPickerView.swift
//  512emotio
//
//  Created by Cynthia X on 2025/5/18.
//

import Foundation
import SwiftUI

struct CalendarPickerView: View {
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date
    let moodRecords: [Date: String] // 日期: 表情图片名（如"1开心"）
    let onSelect: (Date) -> Void

    @State private var currentMonth: Date = Date()

    private let weekDays = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        ZStack {
            Color.black.opacity(0.15)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(spacing: 0) {
                // 顶部栏
                HStack {
                    Button("取消") { isPresented = false }
                        .foregroundColor(Color(hex: "FFA11A"))
                        .font(.system(size: 18, weight: .regular))
                    Spacer()
                    Text(currentMonth, formatter: monthFormatter)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                    // 占位
                    Text("    ")
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 8)

                // 星期栏
                HStack {
                    ForEach(weekDays, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "D1D1D1"))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 6)

                // 日历区
                CalendarGridView(
                    currentMonth: $currentMonth,
                    selectedDate: $selectedDate,
                    moodRecords: moodRecords,
                    onSelect: { date in
                        selectedDate = date
                        onSelect(date)
                        isPresented = false
                    }
                )

                Spacer()
            }
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.white)
                    .ignoresSafeArea()
            )
            .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.7)
            .padding(.top, 60)
        }
        .transition(.move(edge: .bottom))
        .animation(.easeInOut, value: isPresented)
    }

    private var monthFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月"
        return f
    }
}

struct CalendarGridView: View {
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date
    let moodRecords: [Date: String]
    let onSelect: (Date) -> Void

    private let calendar = Calendar.current

    var body: some View {
        let days = makeDays()
        VStack(spacing: 12) {
            // 月份标题
            Text(monthTitle(for: currentMonth))
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 8)

            // 日期网格
            ForEach(days, id: \.self) { week in
                HStack(spacing: 0) {
                    ForEach(week, id: \.self) { date in
                        CalendarDayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                            moodImage: moodRecords[date]
                        )
                        .onTapGesture {
                            if calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) {
                                onSelect(date)
                            }
                        }
                    }
                }
            }
        }
    }

    private func makeDays() -> [[Date]] {
        // 取本月第一天
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let range = calendar.range(of: .day, in: .month, for: firstOfMonth)!
        let daysInMonth = range.count

        // 本月第一天是星期几（1=周日，7=周六）
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        // 计算前置空位
        let leadingEmpty = (firstWeekday + 5) % 7

        // 生成所有日期
        var days: [Date] = []
        for i in 0..<leadingEmpty {
            // 上月补位
            if let date = calendar.date(byAdding: .day, value: i - leadingEmpty, to: firstOfMonth) {
                days.append(date)
            }
        }
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        // 补齐到6行
        while days.count % 7 != 0 {
            if let date = calendar.date(byAdding: .day, value: days.count - leadingEmpty, to: firstOfMonth) {
                days.append(date)
            }
        }
        // 分组
        return stride(from: 0, to: days.count, by: 7).map { Array(days[$0..<$0+7]) }
    }

    private func monthTitle(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "M月"
        return f.string(from: date)
    }
}

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let moodImage: String?

    private let calendar = Calendar.current

    var body: some View {
        VStack {
            ZStack {
                if isToday {
                    Circle()
                        .fill(Color(hex: "FF3B30"))
                        .frame(width: 32, height: 32)
                    Text("\(calendar.component(.day, from: date))")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                } else if isCurrentMonth {
                    Circle()
                        .strokeBorder(Color(hex: "D8D8D8"), style: StrokeStyle(lineWidth: 1, dash: [3]))
                        .frame(width: 32, height: 32)
                    if let moodImage = moodImage {
                        Image(moodImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                    } else {
                        Text("\(calendar.component(.day, from: date))")
                            .foregroundColor(.black)
                            .font(.system(size: 16))
                    }
                } else {
                    Circle()
                        .strokeBorder(Color(hex: "EDEDED"), style: StrokeStyle(lineWidth: 1, dash: [3]))
                        .frame(width: 32, height: 32)
                    Text("\(calendar.component(.day, from: date))")
                        .foregroundColor(Color(hex: "D1D1D1"))
                        .font(.system(size: 16))
                }
            }
        }
        .frame(width: 44, height: 44)
    }
}
