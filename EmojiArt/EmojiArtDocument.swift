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
        emojiArt.addEmoji("😀", at: (375, 343), size: 80)
        emojiArt.addEmoji("😷", at: (470, 283), size: 40)
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
    
    func scale_emoji(center: CGPoint, mag: Float) {
        let cx = Float(center.x)
        let cy = Float(center.y)
        emojiArt.scale_emoji(cx: cx, cy: cy, mag: mag)
    }
    
    func scale_background(center: CGPoint, mag: Float) {
        let cx = Float(center.x)
        let cy = Float(center.y)
        emojiArt.scale_background(cx: cx, cy: cy, mag: mag)
    }
    
    func set_old_background_loc() {
        emojiArt.set_old_background_loc()
    }
    
    func get_background_location() -> (x: Float, y: Float) {
        return emojiArt.get_background_location()
    }
    
    func set_background_location(x: Float, y: Float, _ location: (xs: Float, ys: Float)) {
        emojiArt.set_background_location(x: x, y: y, (xs: location.xs, ys: location.ys))
    }
    
    func get_old_background_location() -> (xo: Float, yo: Float) {
        return emojiArt.get_old_background_location()
    }
    
    func set_old_background_location(xo: Float, yo: Float, cgp: CGPoint) {
        let xs = Float(cgp.x)
        let ys = Float(cgp.y)
        emojiArt.set_old_background_location(xo: xo, yo: yo, (xs: xs, ys: ys))
    }
    
    func set_del_pos(delx: Int, dely: Int) {
        emojiArt.set_del_loc(delx: delx, dely: dely)
    }
    
    func set_loc(x: Int, y: Int, cgp: CGPoint) {
        let xs = Int(cgp.x)
        let ys = Int(cgp.y)
        emojiArt.set_location(x: x, y: y, (xs: xs, ys: ys))
    }
    
    func set_old_loc(x: Int, y: Int, cgp: CGPoint) {
        let xs = Int(cgp.x)
        let ys = Int(cgp.y)
        emojiArt.set_old_location(x: x, y: y, (xs: xs, ys: ys))
    }
    
    func set_loc_of(emoji: EmojiArtModel.Emoji, x: Int, y: Int) {
        emojiArt.set_loc_of(emoji: emoji, x: x, y: y)
    }
    
    func get_location_of(emoji: EmojiArtModel.Emoji) -> (x: Int, y: Int) {
        return (emoji.x, emoji.y)
    }
    
    func get_old_loc_of(emoji: EmojiArtModel.Emoji) -> (x: Int, y: Int) {
        return (emoji.xo, emoji.yo)
    }
    
    func set_old_loc_of(emoji: EmojiArtModel.Emoji, x: Int, y: Int) {
        emojiArt.set_old_loc_of(emoji: emoji, x: x, y: y)
    }
    
    func is_background_set() -> Bool {
        return emojiArt.background_is_set()
    }
    
    func set_background_flag(flag: Bool) {
        emojiArt.set_background_flag(flag: flag)
    }
    
    func get_mag_of(emoji: EmojiArtModel.Emoji) -> Double {
        return emojiArt.get_mag_of(emoji: emoji)
    }
    
    func get_background_mag() -> Double {
        return emojiArt.get_background_mag()
    }
    
    func set_background_mag(mag: Double) {
        emojiArt.set_background_mag(mag: mag)
    }
    
    func get_background_mag_o() -> Double {
        return emojiArt.get_background_mag_o()
    }
    
    func set_background_mag_o(mag: Double) {
        emojiArt.set_background_mag_o(mag: mag)
    }
    
    func set_mag_emojis(mag: Double) {
        emojiArt.set_mag_emojis(mag: mag)
    }
    
    func set_mag_o_emojis(mag: Double) {
        emojiArt.set_mag_o_emojis(mag: mag)
    }
    
    func set_mag(mag: Double) {
        emojiArt.set_mag(mag: mag)
    }
    
    func set_mag_selected(mag: Double) {
        emojiArt.set_mag_selected(mag: mag)
    }
    
    func set_old_emoji_pos() {
        emojiArt.set_old_emoji_pos()
    }
    
    func select_emoji(emoji: EmojiArtModel.Emoji) {
        emojiArt.pannable = false
        emojiArt.zoomable = false
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
    
    func set_emoji_at(index: Int, x: Int, y: Int) {
        emojiArt.set_loc_of(emoji: emojiArt.emojis[index], x: x, y: y)
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
        
        emojiArt.zoomable = true
        emojiArt.pannable = true
    }
}
