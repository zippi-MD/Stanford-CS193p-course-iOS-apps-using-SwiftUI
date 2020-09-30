//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Alejandro Mendoza on 28/09/20.
//
//Model

import Foundation

struct EmojiArt: Codable {
    var backgroundURL: URL?
    var emojis = [Emoji]()
    
    var json: Data? { try? JSONEncoder().encode(self) }
    
    private
    var uniqueEmojiId = 0
    
    init?(json: Data?) {
        if let json = json, let newEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json) {
            self = newEmojiArt
        }
        else {
            return nil
        }
    }
    
    init() {}
    
    mutating
    func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
    }
    
    struct Emoji: Identifiable, Codable, Hashable {
        let text: String
        var x: Int
        var y: Int
        var size: Int
        
        var id: Int
        
        fileprivate
        init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
        
        static func == (lhs: Emoji, rhs: Emoji) -> Bool {
            return lhs.id == rhs.id && lhs.text == rhs.text
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(text)
        }
    }
}
