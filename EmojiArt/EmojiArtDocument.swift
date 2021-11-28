//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by mndx on 26/11/21.
//

import SwiftUI

class EmojiArtDocument: ObservableObject
{
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    init() {
        emojiArt = EmojiArtModel()
        emojiArt.addEmoji("😀", at: (-200, -100), size: 80)
        emojiArt.addEmoji("😷", at: (50, 100), size: 40)
    }
    
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }
    
    // MARK: - Background
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus {
        case idle
        case fetching
    }
    
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            // fetch the url
            backgroundImageFetchStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                DispatchQueue.main.async { [weak self] in
                    if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
                        self?.backgroundImageFetchStatus = .idle
                        if imageData != nil {
                            self?.backgroundImage = UIImage(data: imageData!)
                        }
                    }
                }
            }
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
    // MARK: - Intent(s)
    
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.background = background
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArt.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
    
    func get_back_loc() -> CGPoint {
        var cgp: CGPoint = CGPoint(x: 0, y: 0)
        cgp.x = CGFloat(emojiArt.back_loc_x)
        cgp.y = CGFloat(emojiArt.back_loc_y)
        return cgp
    }
    
    func set_back_loc(cgp: CGPoint) {
        emojiArt.back_loc_x = Float(cgp.x)
        emojiArt.back_loc_x = Float(cgp.y)
    }
    
    func select_emoji(emoji: EmojiArtModel.Emoji) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            
            if !emojiArt.emojis[index].is_selected {
                emojiArt.emojis[index].op = 0.5
                emojiArt.emojis[index].is_selected = true
            }
            else {
                emojiArt.emojis[index].op = 1.0
                emojiArt.emojis[index].is_selected = false
            }
        }
    }
    
    func unselect_emoji(emoji: EmojiArtModel.Emoji) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            
            if emojiArt.emojis[index].is_selected {
                emojiArt.emojis[index].op = 1.0
                emojiArt.emojis[index].is_selected = false
            }
        }
    }
    
    func unselect_all_emoji() {
        let size = emojiArt.emojis.count
        
        for index in 0..<size {
            emojiArt.emojis[index].op = 1.0
            emojiArt.emojis[index].is_selected = false
        }
    }
}
