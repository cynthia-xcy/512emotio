import SwiftUI

struct CalendarSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date
    let moodRecords: [Date: String] // 日期: 表情图片名
    let onSelect: (Date) -> Void

    @State private var displayMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var displayYear: Int = Calendar.current.component(.year, from: Date())

    var body: some View {
        VStack(spacing: 0) {
            // 顶部栏
            HStack {
                Button("取消") { isPresented = false }
                    .foregroundColor(.orange)
                    .font(.system(size: 18, weight: .medium))
                Spacer()
                Text("\(displayYear)年\(displayMonth)月")
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                Spacer().frame(width: 44)
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)

            // 星期横排
            HStack {
                ForEach(["一","二","三","四","五","六","日"], id: \.self) { w in
                    Text(w)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 16)

            // 日历网格（支持上下滑动）
            CalendarMonthView(
                year: displayYear,
                month: displayMonth,
                moodRecords: moodRecords,
                selectedDate: $selectedDate,
                onSelect: { date in
                    onSelect(date)
                }
            )
            .gesture(
                DragGesture().onEnded { value in
                    if value.translation.height < -30 {
                        // 上滑，切下月
                        if displayMonth == 12 {
                            displayMonth = 1
                            displayYear += 1
                        } else {
                            displayMonth += 1
                        }
                    } else if value.translation.height > 30 {
                        // 下滑，切上月
                        if displayMonth == 1 {
                            displayMonth = 12
                            displayYear -= 1
                        } else {
                            displayMonth -= 1
                        }
                    }
                }
            )
        }
        .background(
            Color.white
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .ignoresSafeArea()
        )
    }
}

struct CalendarMonthView: View {
    let year: Int
    let month: Int
    let moodRecords: [Date: String]
    @Binding var selectedDate: Date
    let onSelect: (Date) -> Void

    var body: some View {
        let calendar = Calendar.current
        let comps = DateComponents(year: year, month: month)
        let firstDay = calendar.date(from: comps) ?? Date()
        let range = calendar.range(of: .day, in: .month, for: firstDay) ?? 1..<31
        let daysArray = Array(range)
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let days = Array(repeating: "", count: firstWeekday-1) + daysArray.map { String($0) }
        let rows = Int(ceil(Double(days.count) / 7.0))

        VStack(alignment: .leading, spacing: 0) {
            // 月份大标题
            HStack {
                Text("\(month)月")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.leading, 16)
                Spacer()
            }
            .padding(.top, 16)

            // 日历网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 16) {
                ForEach(0..<rows*7, id: \.self) { i in
                    let dayStr = i < days.count ? days[i] : ""
                    if dayStr == "" {
                        // 空白虚线圆
                        Circle()
                            .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [3]))
                            .frame(width: 36, height: 36)
                            .opacity(0.5)
                    } else {
                        let day = Int(dayStr)!
                        let date = calendar.date(from: DateComponents(year: year, month: month, day: day))!
                        let isToday = calendar.isDateInToday(date)
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        let isCurrentMonth = calendar.component(.month, from: date) == month
                        let moodImage = moodRecords[date]

                        VStack(spacing: 2) {
                            ZStack {
                                if isToday {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 28, height: 28)
                                    Text(dayStr)
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .bold))
                                } else if isSelected {
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 2)
                                        .frame(width: 28, height: 28)
                                    Text(dayStr)
                                        .foregroundColor(.black)
                                        .font(.system(size: 16, weight: .bold))
                                } else {
                                    Text(dayStr)
                                        .foregroundColor(isCurrentMonth ? .black : .gray)
                                        .font(.system(size: 16, weight: .bold))
                                        .frame(width: 28, height: 28)
                                }
                            }
                            if let mood = moodImage {
                                Image(mood)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            } else {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [3]))
                                    .frame(width: 24, height: 24)
                                    .opacity(0.5)
                            }
                        }
                        .onTapGesture {
                            onSelect(date)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }
} 