//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Alejandro Mendoza on 28/09/20.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    @GestureState private var gestureZoomScale: CGFloat = 1
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var zoomScale: CGFloat {
        document.steadyStateZoomScale * gestureZoomScale
    }
    
    private var panOffset: CGSize {
        (document.steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    @State var choosenPalett: String = ""
    @State var explainBackgroundPaste: Bool = false
    @State var confirmBackgroundPaste: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                PaletteChooser(document: document, chosenPalett: $choosenPalett)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(choosenPalett.map { return String($0)}, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: defaultEmojiFontSize))
                                .onDrag { NSItemProvider(object: emoji as NSString) }
                        }
                    }
                }
            }
            .zIndex(1)
            .onAppear {
                choosenPalett = document.defaultPalette
            }
            
            GeometryReader { geometry in
                ZStack {
                    Rectangle()
                        .overlay(
                            OptionalImage(image: document.backgroundImage)
                                .scaleEffect(zoomScale)
                                .offset(panOffset)
                        )
                        .gesture(doubleTapToZoom(in: geometry.size))
                    
                    if isLoading {
                        Image(systemName: "timer")
                            .imageScale(.large)
                            .foregroundColor(Color.gray)
                            .spinning()
                    }
                    else {
                        ForEach(document.emojis){ emoji in
                            Text(emoji.text)
                                .font(animatableWithSize: emoji.fontSize * zoomScale)
                                .position(positon(for: emoji, in: geometry.size))
                        }
                    }
                }
                .gesture(panGesture())
                .gesture(zoomGesture())
                .clipped()
                .foregroundColor(.white)
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onReceive(document.$backgroundImage){ image in
                    zoomToFit(image, size: geometry.size)
                }
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - panOffset.width, y: location.y - panOffset.height)
                    location = CGPoint(x: location.x / zoomScale, y: location.y / zoomScale)
                    return drop(providers: providers, at: location)
                }
                .navigationBarItems(trailing: Button(action: {
                    if let url = UIPasteboard.general.url, url != document.backgroundURL {
                        confirmBackgroundPaste = true
                    }
                    else {
                        explainBackgroundPaste = true
                    }
                }, label: {
                    Image(systemName: "doc.on.clipboard").imageScale(.large)
                        .alert(isPresented: $explainBackgroundPaste) {
                            Alert(title: Text("Paste Background"),
                                  message: Text("Copy the URL of an image and touch this button to make it the background of your document"),
                                  dismissButton: .default(Text("Ok"))
                            )
                        }
                }))
                
            }
            .zIndex(-1)
        }
        .alert(isPresented: $explainBackgroundPaste) {
            Alert(title: Text("Paste Background"),
                  message: Text("Replace your background with \(UIPasteboard.general.url?.absoluteString ?? "nothing")?"),
                  primaryButton: .default(Text("Ok")) {
                    document.backgroundURL = UIPasteboard.general.url
                  },
                  secondaryButton: .cancel()
            )
        }
    }
    
    private let defaultEmojiFontSize: CGFloat = 40
    
    private var isLoading: Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            document.backgroundURL = url
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
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        return location
    }
    
    private func zoomToFit(_ image: UIImage?, size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.height > 0, size.width > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            document.steadyStatePanOffset = .zero
            document.steadyStateZoomScale = min(hZoom, vZoom)
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
                document.steadyStateZoomScale *= finaleGestureScale
            }
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                document.steadyStatePanOffset = document.steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }
}
