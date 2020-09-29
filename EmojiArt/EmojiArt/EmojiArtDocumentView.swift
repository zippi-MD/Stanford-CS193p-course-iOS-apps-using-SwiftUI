//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Alejandro Mendoza on 28/09/20.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
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
                            Group {
                                if let backgroundImage = document.backgroundImage {
                                    Image(uiImage: backgroundImage)
                                }
                            }
                        )
                        .foregroundColor(.white)
                        .edgesIgnoringSafeArea([.horizontal, .bottom])
                        .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                            var location = geometry.convert(location, from: .global)
                            location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                            return drop(providers: providers, at: location)
                        }
                    ForEach(document.emojis){ emoji in
                        Text(emoji.text)
                            .font(font(for: emoji))
                            .position(positon(for: emoji, in: geometry.size))
                    }
                }
            }
        }
        
    }
    
    private let defaultEmojiFontSize: CGFloat = 40
    
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
    
    private func font(for emoji: EmojiArt.Emoji) -> Font {
        Font.system(size: emoji.fontSize)
    }
    
    private func positon(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        CGPoint(x: emoji.location.x + size.width/2, y: emoji.location.y + size.height/2)
    }
}
