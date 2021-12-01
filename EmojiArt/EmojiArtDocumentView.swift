//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by mndx on 26/11/21.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    let defaultEmojiFontSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            palette
        }
    }
     
    @State private var selected_mode: Bool = false
    @GestureState private var selected_mode_state: Bool = false
    
    var documentBody: some View {
        GeometryReader { geometry in
            if selected_mode == false {
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: document.backgroundImage)
                            .scaleEffect(document.get_background_mag())
                            .position(position_background(in: geometry))
                    )
                        .gesture(doubleTapToZoom(in: geometry.size, in: geometry))
                    if document.backgroundImageFetchStatus == .fetching {
                        ProgressView().scaleEffect(2)
                    } else {
                        ForEach(document.emojis) { emoji in
                            Text(emoji.text)
                                .opacity(emoji.op)
                                .font(.system(size: fontSize(for: emoji)))
                                .scaleEffect(document.get_mag_of(emoji: emoji))
                                .position(position_selected(for: emoji, in: geometry))
                                .onTapGesture {
                                    _ = document.select_emoji(emoji: emoji)
                                    selected_mode = true
                                }
                        }
                    }
                }
                .clipped()
                .onDrop(of: [.plainText,.url,.image], isTargeted: nil) { providers, location in
                    drop(providers: providers, at: location, in: geometry)
                }
                .gesture(panGesture().simultaneously(with: zoomGesture(in: geometry)))
            }
            else {
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: document.backgroundImage)
                            .scaleEffect(document.get_background_mag())
                            .position(position_background(in: geometry))
                    )
                        .gesture(doubleTapToZoom(in: geometry.size, in: geometry))
                    if document.backgroundImageFetchStatus == .fetching {
                        ProgressView().scaleEffect(2)
                    } else {
                        ForEach(document.emojis) { emoji in
                            Text(emoji.text)
                                .opacity(emoji.op)
                                .font(.system(size: fontSize(for: emoji)))
                                .scaleEffect(document.get_mag_of(emoji: emoji))
                                .position(position_selected(for: emoji, in: geometry))
                                .gesture(my_tap_gesture(emoji: emoji).simultaneously(with: my_drag_gesture(emoji: emoji, in: geometry)))
                        }
                    }
                }
                .clipped()
                .onDrop(of: [.plainText,.url,.image], isTargeted: nil) { providers, location in
                    drop(providers: providers, at: location, in: geometry)
                }
                .gesture(unselect_gesture().simultaneously(with: zoomGesture_selected(in: geometry)))
            }
        }
    }
    
    // MARK: - Drag and Drop
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.setBackground(.url(url.imageURL))
        }
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(data))
                }
            }
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(
                        String(emoji),
                        at: (Float(location.x), Float(location.y)),
                        size: defaultEmojiFontSize / 1
                    )
                }
            }
        }
        return found
    }
    
    // MARK: - Positioning/Sizing Emoji
    private func position_background(in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        let flag = document.is_background_set()
        var result: CGPoint = CGPoint(x: 0, y: 0)
        
        if flag == false {
            document.set_background_flag(flag: true)
            document.set_background_location(x: Float(center.x), y: Float(center.y), (xs: Float(0), ys: Float(0)))
            let cgp: CGPoint = CGPoint(x: 0, y: 0)
            result = cgp
            document.set_old_background_location(xo: Float(center.x), yo: Float(center.y), cgp: cgp)
        }
        else {
            let back_loc = document.get_background_location()
            result.x = CGFloat(back_loc.x)
            result.y = CGFloat(back_loc.y)
        }
        
        return result
    }
    
    private func position_selected(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {

        let any = document.get_location_of(emoji: emoji)
        let loc_x = CGFloat(any.x)
        let loc_y = CGFloat(any.y)
        
        var result: CGPoint = CGPoint(x: 0, y: 0)
        result.x = loc_x
        result.y = loc_y
        print(result)
        
        return result
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    // MARK: - Zooming
    
    private func zoomGesture(in geometry: GeometryProxy) -> some Gesture {
        MagnificationGesture()
            .updating($dummy_state) { latestGestureScale, dummy_state, _ in
                let center = geometry.frame(in: .local).center
                let magn = latestGestureScale.magnitude

                document.set_mag_emojis(mag: magn)
                document.scale_emoji(center: center, mag: Float(magn))
                document.set_background_mag(mag: magn)
                document.scale_background(center: center, mag: Float(magn))
            }
            .onEnded { gestureScaleAtEnd in
                let magn = gestureScaleAtEnd.magnitude
                
                document.set_background_mag(mag: magn)
                document.set_background_mag_o(mag: magn)
                document.set_mag_o_emojis(mag: magn)
                document.set_old_background_loc()
                document.set_old_emoji_pos()
            }
    }
    
    private func zoomGesture_selected(in geometry: GeometryProxy) -> some Gesture {
        MagnificationGesture()
            .updating($dummy_state) { latestGestureScale, dummy_state, _ in
                let center = geometry.frame(in: .local).center
                let magn = latestGestureScale.magnitude

                document.set_mag_emojis_selected(mag: magn)
                document.scale_emoji_selected(center: center, mag: Float(magn))
            }
            .onEnded { gestureScaleAtEnd in
                let magn = gestureScaleAtEnd.magnitude
                
                document.set_mag_o_emojis_selected(mag: magn)
                document.set_old_emoji_pos()
            }
    }
    
    private func doubleTapToZoom(in size: CGSize, in geometry: GeometryProxy) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size, in: geometry)
                }
            }
    }
    
    private func my_tap_gesture(emoji: EmojiArtModel.Emoji) -> some Gesture {
        TapGesture()
            .onEnded {
                let there_are_emoji_selected = document.select_emoji(emoji: emoji)
                if !there_are_emoji_selected {
                    selected_mode = false
                }
            }
    }
    
    private func my_drag_gesture(emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> some Gesture {
        return DragGesture()
            .updating($dummy_state) { latestDragGestureValue, dummy_state, _ in
                let loc_x = latestDragGestureValue.location.x
                let loc_y = latestDragGestureValue.location.y
                document.set_loc(x: Float(loc_x), y: Float(loc_y), cgp: latestDragGestureValue.startLocation)
            }
            .onEnded { finalDragGestureValue in
                let loc_x = finalDragGestureValue.location.x
                let loc_y = finalDragGestureValue.location.y
                document.set_loc(x: Float(loc_x), y: Float(loc_y), cgp: finalDragGestureValue.startLocation)
                document.set_old_loc(x: Float(loc_x), y: Float(loc_y), cgp: finalDragGestureValue.startLocation)
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize, in geometry: GeometryProxy) {
        let center = geometry.frame(in: .local).center
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0  {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            let magn = min(hZoom, vZoom)
            
            //The order of the following calls matters
            document.reset_emoji_mags(mag: magn, cx: Float(center.x), cy: Float(center.y))
            document.reset_background_location(x: Float(center.x), y: Float(center.y))
            document.reset_background_mag(mag: magn)

        }
    }
    
    // MARK: - Panning
    
    @GestureState private var dummy_state: CGSize = CGSize.zero
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($dummy_state) { latestDragGestureValue, dummy_state, _ in
                let loc_x = latestDragGestureValue.location.x
                let loc_y = latestDragGestureValue.location.y
                let xs = Float(latestDragGestureValue.startLocation.x)
                let ys = Float(latestDragGestureValue.startLocation.y)
                document.set_loc(x: Float(loc_x), y: Float(loc_y), cgp: latestDragGestureValue.startLocation)
                document.set_background_location(x: Float(loc_x), y: Float(loc_y), (xs: xs, ys: ys))
                
            }
            .onEnded { finalDragGestureValue in
                let loc_x = finalDragGestureValue.location.x
                let loc_y = finalDragGestureValue.location.y
                let xs = Float(finalDragGestureValue.startLocation.x)
                let ys = Float(finalDragGestureValue.startLocation.y)
                document.set_loc(x: Float(loc_x), y: Float(loc_y), cgp: finalDragGestureValue.startLocation)
                document.set_old_loc(x: Float(loc_x), y: Float(loc_y), cgp: finalDragGestureValue.startLocation)
                document.set_background_location(x: Float(loc_x), y: Float(loc_y), (xs: xs, ys: ys))
                document.set_old_background_location(xo: Float(loc_x), yo: Float(loc_y), cgp: finalDragGestureValue.startLocation)
            }
    }
    
    private func unselect_gesture() -> some Gesture {
        TapGesture()
            .onEnded {
                document.unselect_all_emoji()
                selected_mode = false
            }
    }

    // MARK: - Palette
    
    var palette: some View {
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size: defaultEmojiFontSize))
    }
    
    let testEmojis = "😀😷🦠💉👻👀🐶🌲🌎🌞🔥🍎⚽️🚗🚓🚲🛩🚁🚀🛸🏠⌚️🎁🗝🔐❤️⛔️❌❓✅⚠️🎶➕➖🏳️"
}

struct ScrollingEmojisView: View {
    let emojis: String

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag { NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
