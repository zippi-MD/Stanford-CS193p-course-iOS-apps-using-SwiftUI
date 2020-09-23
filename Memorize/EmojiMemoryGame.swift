//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by Alejandro Mendoza on 22/09/20.
//

import SwiftUI

class EmojiMemoryGame {
    private var model = createMemoryGame()
    
    static func createMemoryGame() -> MemoryGame<String> {
        let emojis = ["🦙", "🎉", "🙌🏻", "👌🏻", "👍🏻"]
        let pairsOfCards = Int.random(in: 2...emojis.count)
        return MemoryGame<String>(numberOfPairsOfCards: pairsOfCards) { pairIndex in
            return emojis[pairIndex]
        }
    }
    
    //MARK: - Access to the Model
    var cards: Array<MemoryGame<String>.Card> {
        return model.cards.shuffled()
    }
    
    //MARK: - Intent
    func choose(card: MemoryGame<String>.Card) {
        model.choose(card: card)
    }
}
