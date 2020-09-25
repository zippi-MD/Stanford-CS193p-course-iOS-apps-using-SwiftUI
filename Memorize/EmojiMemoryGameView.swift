//
//  EmojiMemoryGameView.swift
//  Memorize
//
//  Created by Alejandro Mendoza on 22/09/20.
//

import SwiftUI

struct EmojiMemoryGameView: View {
    @ObservedObject var viewModel: EmojiMemoryGame
    
    var body: some View {
        VStack {
            Text(viewModel.name)
                .font(.largeTitle)
            Grid(viewModel.cards) { (card) in
                CardView(card: card).onTapGesture {
                    viewModel.choose(card: card)
                }
                .padding(5)
            }
        }
        .foregroundColor(viewModel.color)
        .padding()
        
    }
}

struct CardView: View {
    var card: MemoryGame<String>.Card
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                if card.isFaceUp {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.white)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(lineWidth: edgeLineWidth)
                    Text(card.content)
                }
                else {
                    if !card.isMatched {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill()
                    }
                }
                
            }
            .font(Font.system(size: fontSize(for: geometry.size)))
        }
    }
    
    // MARK: - Drawing Constants
    let cornerRadius: CGFloat = 10
    let edgeLineWidth: CGFloat = 3
    let fontScaleFactor: CGFloat = 0.75
    
    func fontSize(for size: CGSize) -> CGFloat {
        min(size.width, size.height) * fontScaleFactor
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiMemoryGameView(viewModel: EmojiMemoryGame())
    }
}
