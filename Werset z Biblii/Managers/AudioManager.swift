//
//  AudioManager.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 25/06/2025.
//

import Foundation
import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    
    private var player: AVAudioPlayer?

    private init() { }

    func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "ChristianMusic", withExtension: "mp3") else {
            print("Nie znaleziono pliku.")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // zapętlenie
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Błąd odtwarzania: \(error.localizedDescription)")
        }
    }

    func stopMusic() {
        player?.stop()
    }
}
