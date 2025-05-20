import SwiftUI
import AVKit

struct ContentView: View {
    @State private var selectedMood: String?
    @State private var showCalendar = false
    @State private var selectedDate = Date()
    @State private var moodRecords: [Date: String] = [:]
    @State private var players: [String: AVPlayer] = [:]
    
    var body: some View {
        ZStack {
            // 背景色
            Color(hex: "F5F5F5")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 视频播放区域
                if let mood = selectedMood, let player = players[mood] {
                    VideoPlayer(player: player)
                        .onAppear { player.play() }
                        .onDisappear { player.pause() }
                        .frame(height: 300)
                        .cornerRadius(20)
                        .padding(.horizontal)
                }
                
                // 表情选择区域
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(["1开心", "2焦虑", "3生气", "4难过", "5害怕", "6尴尬"], id: \.self) { mood in
                            Button(action: {
                                selectedMood = mood
                                moodRecords[selectedDate] = mood
                                if players[mood] == nil {
                                    if let path = Bundle.main.path(forResource: mood, ofType: "mp4") {
                                        let url = URL(fileURLWithPath: path)
                                        let player = AVPlayer(url: url)
                                        // 循环播放
                                        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                                            player.seek(to: .zero)
                                            player.play()
                                        }
                                        players[mood] = player
                                    }
                                }
                            }) {
                                Image(mood)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .background(
                                        Circle()
                                            .fill(selectedMood == mood ? Color(hex: "FFA11A") : Color.white)
                                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 日历按钮
                Button(action: {
                    showCalendar = true
                }) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.white)
                        Text("查看历史记录")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(hex: "FFA11A"))
                    .cornerRadius(25)
                }
                .padding(.top, 20)
            }
        }
        .sheet(isPresented: $showCalendar) {
            CalendarPickerView(
                isPresented: $showCalendar,
                selectedDate: $selectedDate,
                moodRecords: moodRecords,
                onSelect: { date in
                    selectedDate = date
                    selectedMood = moodRecords[date]
                }
            )
        }
    }
}

// 颜色扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
} 