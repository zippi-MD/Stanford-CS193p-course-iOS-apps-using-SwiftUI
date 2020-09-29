//
//  MemoryGame.swift
//  Memorize
//
//  Created by Alejandro Mendoza on 22/09/20.
//

import Foundation

struct MemoryGame<CardContent> where CardContent: Equatable {
    private(set) var cards: Array<Card>
    private var indexOfTheOneAndOnlyFaceUpCard: Int? {
        get {
            cards.indices.filter { cards[$0].isFaceUp }.only
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = index == newValue
            }
        }
    }
    
    init(numberOfPairsOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        cards = [Card]()
        for pairIndex in 0..<numberOfPairsOfCards {
            let content = cardContentFactory(pairIndex)
            cards.append(Card(content: content, id: pairIndex*2))
            cards.append(Card(content: content, id: pairIndex*2+1))
        }
        
        cards.shuffle()
    }
    
    mutating
    func choose(card: Card) {
        if let chosenCardIndex = cards.firstIndex(matching: card), !cards[chosenCardIndex].isFaceUp, !cards[chosenCardIndex].isMatched {
            if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
                if cards[chosenCardIndex].content == cards[potentialMatchIndex].content {
                    cards[chosenCardIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                }
                cards[chosenCardIndex].isFaceUp = true
            }
            else {
                indexOfTheOneAndOnlyFaceUpCard = chosenCardIndex
            }
        }
    }
    
    struct Card: Identifiable {
        var isFaceUp: Bool = false {
            didSet {
                if isFaceUp {
                    startUsingBonusTime()
                }
                else {
                    stopsUsingBonusTime()
                }
            }
        }
        var isMatched: Bool = false {
            didSet {
                stopsUsingBonusTime()
            }
        }
        var content: CardContent
        var id: Int
        
        // MARK: - Bonus Time
        var bonusTimeLimit: TimeInterval = 6
        
        private var faceUpTime: TimeInterval {
            if let lastFaceUpDate = self.lastFaceUpDate {
                return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
            }
            else {
                return pastFaceUpTime
            }
        }
        
        var lastFaceUpDate: Date?
        var pastFaceUpTime: TimeInterval = 0
        
        var bonusTimeRemaining: TimeInterval {
            max(0, bonusTimeLimit - faceUpTime)
        }
        
        var bonusRemainig: Double {
            (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? bonusTimeRemaining/bonusTimeLimit : 0
        }
        
        var hasEarnedBonus: Bool {
            isMatched && bonusTimeRemaining > 0
        }
        
        var isConsumingBonusTime: Bool {
            isFaceUp && !isMatched && bonusTimeRemaining > 0
        }
        
        private mutating func startUsingBonusTime() {
            if isConsumingBonusTime, lastFaceUpDate == nil {
                lastFaceUpDate = Date()
            }
        }
        
        private mutating func stopsUsingBonusTime() {
            pastFaceUpTime = faceUpTime
            self.lastFaceUpDate = nil
        }
    }
}
