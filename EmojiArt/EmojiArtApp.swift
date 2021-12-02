//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by mndx on 26/11/21.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let document = EmojiArtDocument()
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}
