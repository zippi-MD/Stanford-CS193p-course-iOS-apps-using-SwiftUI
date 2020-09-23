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
        let availableEmojis = ["🦙", "🎉", "🙌🏻", "👌🏻", "👍🏻", "🙏🏻", "🙊", "🥳", "😐", "🙈", "👅", "😅"]
        let maxPairOfCards: Int = 5
        let minPairOfCards: Int = 2
        
        let emojis = availableEmojis.shuffled()[0..<maxPairOfCards]
        let pairsOfCards = Int.random(in: minPairOfCards...emojis.count)
        
        return MemoryGame<String>(numberOfPairsOfCards: pairsOfCards) { pairIndex in
            return emojis[pairIndex]
        }
    }
    
    func emojiFont() -> Font {
        return model.cards.count/2 < 5 ? .largeTitle : .title3
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
