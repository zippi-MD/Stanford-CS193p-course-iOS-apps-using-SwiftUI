//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by Alejandro Mendoza on 22/09/20.
//

import SwiftUI

class EmojiMemoryGame: ObservableObject {
    @Published private var model = createMemoryGame()
    
    static func createMemoryGame() -> MemoryGame<String> {
        let emojis = ["🦙", "🎉", "🙌🏻"]
        return MemoryGame<String>(numberOfPairsOfCards: emojis.count) { pairIndex in
            return emojis[pairIndex]
        }
    }
    
    //MARK: - Access to the Model
    var cards: Array<MemoryGame<String>.Card> {
        return model.cards
    }
    
    //MARK: - Intent
    func choose(card: MemoryGame<String>.Card) {
        model.choose(card: card)
    }
}
