//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by Alejandro Mendoza on 22/09/20.
//

import SwiftUI

class EmojiMemoryGame: ObservableObject {
    @Published private var model: MemoryGame<String> = createMemoryGame()
    private static var themes = [
        MemoryGame<String>.Theme(name: "Halloween", elements: ["😅", "🐥", "🙋🏼‍♂️", "💚", "😃", "🙌🏻"], pairsOfCardsToShow: 3, color: "orange"),
        MemoryGame<String>.Theme(name: "Christmas", elements: ["👍🏻", "1️⃣", "😂", "☺️", "😱", "😍", "💪🏻", "👌🏻", "👍🏻"], pairsOfCardsToShow: 5, color: "red"),
        MemoryGame<String>.Theme(name: "Easter", elements: ["👍🏻", "1️⃣", "😂", "☺️", "😱", "😍", "💪🏻", "👌🏻", "👍🏻"], pairsOfCardsToShow: 2, color: "yellow"),
        MemoryGame<String>.Theme(name: "Labor Day", elements: ["👍🏻", "1️⃣", "😂", "☺️", "😱", "😍", "💪🏻", "👌🏻", "👍🏻"], pairsOfCardsToShow: 1, color: "blue"),
    ]
    
    static func createMemoryGame() -> MemoryGame<String> {
        let theme = themes.shuffled().first!
        return MemoryGame<String>(theme: theme)
    }
    
    //MARK: - Access to the Model
    var cards: Array<MemoryGame<String>.Card> {
        return model.cards
    }
    
    var score: Int {
        return model.score
    }
    
    var name: String {
        return model.theme.name
    }
    
    var color: Color {
        return EmojiMemoryGameColors(rawValue: model.theme.color)?.getColor ?? Color.gray
    }
    
    //MARK: - Intent
    func choose(card: MemoryGame<String>.Card) {
        model.choose(card: card)
    }
    
    func newGame() {
        model = EmojiMemoryGame.createMemoryGame()
    }
    
    enum EmojiMemoryGameColors: String {
        case orange
        case red
        case blue
        case yellow
        
        var getColor: Color {
            switch self {
            case .orange:
                return Color.orange
            case .red:
                return Color.red
            case .blue:
                return Color.blue
            case .yellow:
                return Color.yellow
            }
        }
    }
}
