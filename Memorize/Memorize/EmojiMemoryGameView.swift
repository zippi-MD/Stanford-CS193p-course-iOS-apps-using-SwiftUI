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
            Grid(viewModel.cards) { (card) in
                CardView(card: card).onTapGesture {
                    withAnimation(.linear(duration: 0.75)) {
                        viewModel.choose(card: card)
                    }
                }
                .padding(5)
            }
            .foregroundColor(.orange)
            .padding()
            
            Button {
                withAnimation(.easeInOut) {
                    viewModel.resetGame()
                }
            } label: {
                Text("New game")
                    .padding()
                    .background(Color(.tertiarySystemFill))
                    .cornerRadius(5)
            }
        }
    }
}

struct CardView: View {
    var card: MemoryGame<String>.Card
    
    @State private var animatedBonusRemaining: Double = 0
    
    private func startBonusTimeAnimation() {
        animatedBonusRemaining = card.bonusRemainig
        withAnimation(.linear(duration: card.bonusTimeRemaining)) {
            animatedBonusRemaining = 0
        }
    }
    
//    @ViewBuilder
    var body: some View {
        GeometryReader { geometry in
            if card.isFaceUp || !card.isMatched {
                ZStack{
                    Group {
                        if card.isConsumingBonusTime {
                            Pie(startAngle: Angle(degrees: -90), endAngle: Angle(degrees: -animatedBonusRemaining * 360 - 90), clockwise: true)
                                .onAppear {
                                    startBonusTimeAnimation()
                                }
                        }
                        else {
                            Pie(startAngle: Angle(degrees: -90), endAngle: Angle.degrees(-animatedBonusRemaining*360 - 90), clockwise: true)
                        }
                    }
                    .padding(6)
                    .opacity(0.4)
                    .transition(.identity)
                    
                    Text(card.content)
                        .font(Font.system(size: fontSize(for: geometry.size)))
                        .rotationEffect(Angle(degrees: card.isMatched ? 360 : 0))
                        .animation(card.isMatched ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default)
                }
                .cardify(isFaceUp: card.isFaceUp)
                .transition(AnyTransition.scale)
            }
        }
    }
    
    // MARK: - Drawing Constants
    private let fontScaleFactor: CGFloat = 0.60
    
    func fontSize(for size: CGSize) -> CGFloat {
        min(size.width, size.height) * fontScaleFactor
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame()
        game.choose(card: game.cards[0])
        return EmojiMemoryGameView(viewModel: game)
    }
}
