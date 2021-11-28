//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by mndx on 26/11/21.
//

import Foundation

struct EmojiArtModel {
    var background = Background.blank
    var emojis = [Emoji]()
    var back_loc_x: Float = 0.0
    var back_loc_y: Float = 0.0
    
    struct Emoji: Identifiable, Hashable {
        let text: String
        var x: Int // offset from the center
        var y: Int // offset from the center
        var op: Double = 1.0
        var is_selected: Bool = false
        var size: Int
        let id: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    init() { }
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, at location: (x: Int, y: Int), size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiId))
    }
}
