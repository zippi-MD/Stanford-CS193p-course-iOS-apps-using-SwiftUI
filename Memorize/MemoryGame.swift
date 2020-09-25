//
//  MemoryGame.swift
//  Memorize
//
//  Created by Alejandro Mendoza on 22/09/20.
//

import Foundation

struct MemoryGame<CardContent> where CardContent: Equatable {
    var cards: Array<Card>
    var score: Int
    let theme: Theme
    
    private let correctMatchPoints: Int = 2
    private let penalizationPints: Int = -1
    
    var indexOfTheOneAndOnlyFaceUpCard: Int? {
        get {
            cards.indices.filter { cards[$0].isFaceUp }.only
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = index == newValue
            }
        }
    }
    
    init(theme: Theme) {
        self.theme = theme
        self.score = 0
        self.cards = [Card]()
        
        let elements = theme.elements.shuffled()[0...theme.pairsOfCardsToShow]
        for pairIndex in 0..<theme.pairsOfCardsToShow {
            let content = elements[pairIndex]
            cards.append(Card(content: content, id: pairIndex*2))
            cards.append(Card(content: content, id: pairIndex*2+1))
        }
        
        cards = cards.shuffled()
    }
    
    mutating
    func choose(card: Card) {
        print("card chosen \(card )")
        if let chosenCardIndex = cards.firstIndex(matching: card), !cards[chosenCardIndex].isFaceUp, !cards[chosenCardIndex].isMatched {
            if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
                if cards[chosenCardIndex].content == cards[potentialMatchIndex].content {
                    cards[chosenCardIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                    score += correctMatchPoints
                }
                else {
                    score += penalizationPints
                }
                cards[chosenCardIndex].isFaceUp = true
            }
            else {
                indexOfTheOneAndOnlyFaceUpCard = chosenCardIndex
            }
        }
    }
    
    struct Card: Identifiable {
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        var content: CardContent
        var id: Int
    }
    
    struct Theme {
        var name: String
        var elements: [CardContent]
        var pairsOfCardsToShow: Int
        var color: String
    }
}
