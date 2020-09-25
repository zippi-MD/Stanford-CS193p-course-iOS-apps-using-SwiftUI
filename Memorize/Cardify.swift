//
//  Cardify.swift
//  Memorize
//
//  Created by Alejandro Mendoza on 25/09/20.
//

import SwiftUI

struct Cardify: ViewModifier {
    var isFaceUp: Bool
    private let cornerRadius: CGFloat = 10
    private let edgeLineWidth: CGFloat = 3
    
    func body(content: Content) -> some View {
        ZStack{
            if isFaceUp {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(lineWidth: edgeLineWidth)
                content
            }
            else {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill()
            }
            
        }
    }
}

extension View {
    func cardify(isFaceUp: Bool) -> some View {
        self.modifier(Cardify(isFaceUp: isFaceUp))
    }
}
