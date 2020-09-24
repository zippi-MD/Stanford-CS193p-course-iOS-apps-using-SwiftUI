//
//  MemoryGame.swift
//  Memorize
//
//  Created by Alejandro Mendoza on 22/09/20.
//

import Foundation

struct MemoryGame<CardContent> {
    var cards: Array<Card>
    
    init(numberOfPairsOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        cards = [Card]()
        for pairIndex in 0..<numberOfPairsOfCards {
            let content = cardContentFactory(pairIndex)
            cards.append(Card(content: content, id: pairIndex*2))
            cards.append(Card(content: content, id: pairIndex*2+1))
        }
    }
    
    mutating
    func choose(card: Card) {
        print("card chosen \(card )")
        let chosenCardIndex = index(of: card)
        cards[chosenCardIndex].isFaceUp = !cards[chosenCardIndex].isFaceUp
    }
    
    func index(of card: Card) -> Int {
        for (index, _) in cards.enumerated() {
            if cards[index].id == card.id {
                return index
            }
        }
        
        return 0 // TODO: Bogus
    }
    
    struct Card: Identifiable {
        var isFaceUp: Bool = true
        var isMatched: Bool = false
        var content: CardContent
        var id: Int
    }
}
