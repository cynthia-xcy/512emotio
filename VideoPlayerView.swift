import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoName: String
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                        isPlaying = true
                    }
                    .onDisappear {
                        player.pause()
                        isPlaying = false
                    }
            }
        }
        .onAppear {
            setupPlayer()
        }
    }
    
    private func setupPlayer() {
        guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
            print("找不到视频文件：\(videoName)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        let playerItem = AVPlayerItem(url: url)
        
        // 设置循环播放
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                            object: playerItem,
                                            queue: .main) { _ in
            playerItem.seek(to: .zero)
            player?.play()
        }
        
        player = AVPlayer(playerItem: playerItem)
    }
} 