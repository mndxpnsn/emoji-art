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
    var back_loc_xo: Float = 0.0
    var back_loc_yo: Float = 0.0
    var background_position_set: Bool = false
    
    struct Emoji: Identifiable, Hashable {
        let text: String
        var x: Int // offset from the center
        var y: Int // offset from the center
        var xo: Int
        var yo: Int
        var op: Double = 1.0
        var is_selected: Bool = false
        var size: Int
        let id: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.xo = x
            self.yo = y
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
    
    func get_location_at_index(index: Int) -> (x: Int, y: Int) {
        return (emojis[index].x, emojis[index].y)
    }
    
    mutating func set_location(x: Int, y: Int, _ location: (xs: Int, ys: Int)) {
        let num_emoji = emojis.count
        print("num_emoji")
        print(num_emoji)
        for index in 0..<num_emoji {
            if emojis[index].is_selected {
                let delx = emojis[index].xo - location.xs
                let dely = emojis[index].yo - location.ys
                emojis[index].x = x + delx
                emojis[index].y = y + dely
            }
        }
    }
    
    mutating func set_old_location(x: Int, y: Int, _ location: (xs: Int, ys: Int)) {
        let num_emoji = emojis.count
        print("num_emoji")
        print(num_emoji)
        for index in 0..<num_emoji {
            if emojis[index].is_selected {
                let delx = emojis[index].xo - location.xs
                let dely = emojis[index].yo - location.ys
                emojis[index].xo = x + delx
                emojis[index].yo = y + dely
            }
        }
    }
    
    mutating func set_old_loc_of(emoji: EmojiArtModel.Emoji, x: Int, y: Int) {
        let num_emoji = emojis.count
        for index in 0..<num_emoji {
            if emojis[index].id == emoji.id {
                if emojis[index].is_selected {
                    emojis[index].xo = x
                    emojis[index].yo = y
                }
            }
        }
    }
    
    mutating func set_loc_of(emoji: EmojiArtModel.Emoji, x: Int, y: Int) {
        let num_emoji = emojis.count
        for index in 0..<num_emoji {
            if emojis[index].id == emoji.id {
                if emojis[index].is_selected {
                    emojis[index].x = x
                    emojis[index].y = y
                }
            }
        }
    }

    mutating func set_del_loc(delx: Int, dely: Int) {
        let num_emoji = emojis.count
        print("num_emoji")
        print(num_emoji)
        for index in 0..<num_emoji {
            if emojis[index].is_selected {
                emojis[index].x += delx
                emojis[index].y += dely
            }
        }
    }
    
    func get_background_location() -> (x: Float, y: Float) {
        let xloc = self.back_loc_x
        let yloc = self.back_loc_y
        
        return (xloc, yloc)
    }
    
    mutating func set_background_location(x: Float, y: Float, _ location: (xs: Float, ys: Float)) {
        let delx = self.back_loc_xo - location.xs
        let dely = self.back_loc_yo - location.ys
        self.back_loc_x = x + delx
        self.back_loc_y = y + dely
    }
    
    func get_old_background_location() -> (xo: Float, yo: Float) {
        let xloc = self.back_loc_xo
        let yloc = self.back_loc_yo
        
        return (xloc, yloc)
    }
    
    mutating func set_old_background_location(xo: Float, yo: Float, _ location: (xs: Float, ys: Float)) {
        let delx = self.back_loc_xo - location.xs
        let dely = self.back_loc_yo - location.ys
        self.back_loc_xo = xo + delx
        self.back_loc_yo = yo + dely
    }
    
    func background_is_set() -> Bool {
        return self.background_position_set
    }
    
    mutating func set_background_flag(flag: Bool) {
        self.background_position_set = flag
    }
}
