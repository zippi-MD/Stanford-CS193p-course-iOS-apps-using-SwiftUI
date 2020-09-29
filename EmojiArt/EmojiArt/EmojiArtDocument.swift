//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Alejandro Mendoza on 28/09/20.
//
// ViewModel


import SwiftUI

class EmojiArtDocument: ObservableObject {
    @Published private var emojiArt: EmojiArt = EmojiArt()
    @Published private(set) var backgroundImage: UIImage?
    
    static let palette: String = "🐥😅😃🙋🏼‍♂️🙌🏻🙈🙊👍🏻"
    
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    
    //MARK: - Intents
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func escaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    func setBackgroundURL(_ url: URL?) {
        emojiArt.backgroundURL = url?.imageURL
        fetchBackgroundImage()
    }
    
    private func fetchBackgroundImage() {
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async { [weak self] in
                        if url == self?.emojiArt.backgroundURL {
                            self?.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(self.x), y: CGFloat(self.y)) }
}
