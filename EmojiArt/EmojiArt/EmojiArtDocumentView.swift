//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Alejandro Mendoza on 28/09/20.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    @State private var selectedEmojis = Set<EmojiArt.Emoji>()
    
    @State private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(EmojiArtDocument.palette.map { return String($0)}, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: defaultEmojiFontSize))
                            .onDrag { NSItemProvider(object: emoji as NSString) }
                    }
                }
            }
            .padding(.horizontal)
            GeometryReader { geometry in
                ZStack {
                    Rectangle()
                        .overlay(
                            OptionalImage(image: document.backgroundImage)
                                .scaleEffect(selectedEmojis.isEmpty ? zoomScale : steadyStateZoomScale)
                                .offset(selectedEmojis.isEmpty ? panOffset : steadyStatePanOffset * zoomScale)
                        )
                        .gesture(doubleTapToZoom(in: geometry.size))
                    ForEach(document.emojis){ emoji in
                        Text(emoji.text)
                            .border(Color.black, width: selectedEmojis.contains(matching: emoji) ? selectedEmojiBorderWidth : 0)
                            .font(animatableWithSize: fontSizeFor(emoji))
                            .position(positon(for: emoji, in: geometry.size))
                            .gesture(selectGesture(emoji))
                    }
                }
                .gesture(panGesture())
                .gesture(zoomGesture())
                .gesture(deselectGesture())
                .clipped()
                .foregroundColor(.white)
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - panOffset.width, y: location.y - panOffset.height)
                    location = CGPoint(x: location.x / zoomScale, y: location.y / zoomScale)
                    return drop(providers: providers, at: location)
                }
                
            }
        }
        
    }
    
    private let defaultEmojiFontSize: CGFloat = 40
    private let selectedEmojiBorderWidth: CGFloat = 1.5
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            document.setBackgroundURL(url)
        }
        
        if !found {
            found = providers.loadFirstObject(ofType: String.self) { emoji in
                document.addEmoji(emoji, at: location, size: defaultEmojiFontSize)
            }
        }
        
        return found
    }
    
    private func positon(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        
        if selectedEmojis.isEmpty {
            location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
            location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
            location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        }
        else if selectedEmojis.contains(matching: emoji) {
            location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
            location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        }
        else {
            location = CGPoint(x: location.x * steadyStateZoomScale,
                               y: location.y * steadyStateZoomScale)
            location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
            location = CGPoint(x: location.x + (steadyStatePanOffset.width * zoomScale),
                               y: location.y + (steadyStatePanOffset.height * zoomScale))
        }
        
        
        return location
    }
    
    private func fontSizeFor(_ emoji: EmojiArt.Emoji) -> CGFloat {
        
        if selectedEmojis.isEmpty || selectedEmojis.contains(matching: emoji) {
            return emoji.fontSize * zoomScale
        }
        else {
            return emoji.fontSize
        }
        
    }
    
    private func zoomToFit(_ image: UIImage?, size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset = .zero
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, size: size)
                }
            }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureState, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureState
            }
            .onEnded { finaleGestureScale in
                if selectedEmojis.isEmpty {
                    steadyStateZoomScale *= finaleGestureScale
                }
                else {
                    for emoji in selectedEmojis {
                        document.escaleEmoji(emoji, by: finaleGestureScale)
                    }
                }
                
            }
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                if selectedEmojis.isEmpty {
                    steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
                }
                else {
                    for emoji in selectedEmojis {
                        document.moveEmoji(emoji, by: (finalDragGestureValue.translation / zoomScale))
                    }
                }
            }
    }
    
    private func selectGesture(_ emoji: EmojiArt.Emoji) -> some Gesture {
        TapGesture()
            .onEnded {
                if selectedEmojis.contains(matching: emoji) {
                    selectedEmojis.remove(emoji)
                }
                else {
                    selectedEmojis.insert(emoji)
                }
            }
    }
    
    private func deselectGesture() -> some Gesture {
        TapGesture()
            .onEnded {
                selectedEmojis.removeAll(keepingCapacity: true)
            }
    }
}
