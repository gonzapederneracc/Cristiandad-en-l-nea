//
//  VideoPlayerView.swift
//  Iglesia Cristiandad
//
//  Created by Gonza Pedernera on 27/03/2025.
//


import SwiftUI
import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerVC = AVPlayerViewController()
        let player = AVPlayer(url: url)
        playerVC.player = player
        playerVC.modalPresentationStyle = .fullScreen
        playerVC.showsPlaybackControls = true // Asegura que los controles sean visibles
        player.play()
        return playerVC
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
