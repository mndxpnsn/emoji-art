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
                            .scaleEffect(zoomScale)
                            .position(convertFromEmojiCoordinates((0,0), in: geometry))
                    )
                    .gesture(doubleTapToZoom(in: geometry.size))
                    if document.backgroundImageFetchStatus == .fetching {
                        ProgressView().scaleEffect(2)
                    } else {
                        ForEach(document.emojis) { emoji in
                            Text(emoji.text)
                                .opacity(emoji.op)
                                .font(.system(size: fontSize(for: emoji)))
                                .scaleEffect(zoomScale_selected)
                                .position(position_selected(for: emoji, in: geometry))
                                .onTapGesture {
                                    document.select_emoji(emoji: emoji)
                                    selected_mode = true
                                    print("selected mode false")
                                }
                        }
                    }
                }
                .clipped()
                .onDrop(of: [.plainText,.url,.image], isTargeted: nil) { providers, location in
                    drop(providers: providers, at: location, in: geometry)
                }
                .gesture(panGesture().simultaneously(with: zoomGesture()))
            }
            else {
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: document.backgroundImage)
                            .scaleEffect(zoomScale)
                            .position(convertFromEmojiCoordinates((0,0), in: geometry))
                    )
                    .gesture(doubleTapToZoom(in: geometry.size))
                    if document.backgroundImageFetchStatus == .fetching {
                        ProgressView().scaleEffect(2)
                    } else {
                        ForEach(document.emojis) { emoji in
                            Text(emoji.text)
                                .opacity(emoji.op)
                                .font(.system(size: fontSize(for: emoji)))
                                .scaleEffect(zoomScale_selected)
                                .position(position_selected(for: emoji, in: geometry))
                                .gesture(my_tap_gesture(emoji: emoji))
                        }
                    }
                }
                .clipped()
                .onDrop(of: [.plainText,.url,.image], isTargeted: nil) { providers, location in
                    drop(providers: providers, at: location, in: geometry)
                }
                .gesture(unselect_gesture().simultaneously(with: zoomGesture_selected().simultaneously(with: panGesture_selected())))
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
                        at: convertToEmojiCoordinates(location, in: geometry),
                        size: defaultEmojiFontSize / zoomScale
                    )
                }
            }
        }
        return found
    }
    
    // MARK: - Positioning/Sizing Emoji
    
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        print("position")
        return convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
    }
    
    private func position_selected(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        print("position selected")
        return convertFromEmojiCoordinates_selected((emoji.x, emoji.y), in: geometry)
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - panOffset.width - center.x) / zoomScale,
            y: (location.y - panOffset.height - center.y) / zoomScale
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        let cgp_loc = CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
        )
        
        return cgp_loc
    }
    
    private func convertFromEmojiCoordinates_selected(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        let cgp_loc = CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale_selected + panOffset_selected.width,
            y: center.y + CGFloat(location.y) * zoomScale_selected + panOffset_selected.height
        )
        
        return cgp_loc
    }
    
    // MARK: - Zooming
    
    @State private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    @State private var steadyStateZoomScale_selected: CGFloat = 1
    @GestureState private var gestureZoomScale_selected: CGFloat = 1
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private var zoomScale_selected: CGFloat {
        steadyStateZoomScale_selected * gestureZoomScale_selected
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                gestureZoomScale = latestGestureScale
            }
            .updating($gestureZoomScale_selected) { latestGestureScale, gestureZoomScale_selected, _ in
                gestureZoomScale_selected = latestGestureScale
            }
            .onEnded { gestureScaleAtEnd in
                steadyStateZoomScale *= gestureScaleAtEnd
                steadyStateZoomScale_selected *= gestureScaleAtEnd
                print("zoom gesture")
            }
    }
    
    private func zoomGesture_selected() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale_selected) { latestGestureScale, gestureZoomScale_selected, _ in
                gestureZoomScale_selected = latestGestureScale
            }
            .onEnded { gestureScaleAtEnd in
                steadyStateZoomScale_selected *= gestureScaleAtEnd
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func my_tap_gesture(emoji: EmojiArtModel.Emoji) -> some Gesture {
        TapGesture()
            .onEnded {
                document.select_emoji(emoji: emoji)
                print("my tap gesture")
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0  {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset = .zero
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    // MARK: - Panning
    
    @State private var steadyStatePanOffset: CGSize = CGSize.zero
    @GestureState private var gesturePanOffset: CGSize = CGSize.zero
    
    @State private var steadyStatePanOffset_selected: CGSize = CGSize.zero
    @GestureState private var gesturePanOffset_selected: CGSize = CGSize.zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private var panOffset_selected: CGSize {
        (steadyStatePanOffset_selected + gesturePanOffset_selected) * zoomScale_selected
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .updating($gesturePanOffset_selected) { latestDragGestureValue, gesturePanOffset_selected, _ in
                gesturePanOffset_selected = latestDragGestureValue.translation / zoomScale_selected
            }
            .onEnded { finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
                steadyStatePanOffset_selected = steadyStatePanOffset_selected + (finalDragGestureValue.translation / zoomScale_selected)
                print("pan gesture")
            }
    }
    
    private func panGesture_selected() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset_selected) { latestDragGestureValue, gesturePanOffset_selected, _ in
                gesturePanOffset_selected = latestDragGestureValue.translation / zoomScale_selected
            }
            .onEnded { finalDragGestureValue in
                steadyStatePanOffset_selected = steadyStatePanOffset_selected + (finalDragGestureValue.translation / zoomScale_selected)
//                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale_selected)
                print("pan gesture selected")
            }
    }
    
    private func unselect_gesture() -> some Gesture {
        TapGesture()
            .onEnded {
                document.unselect_all_emoji()
                selected_mode = false
//                steadyStatePanOffset = steadyStatePanOffset_selected
                print("unselect gesture")
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
