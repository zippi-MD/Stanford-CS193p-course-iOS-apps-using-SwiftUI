//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Alejandro Mendoza on 30/09/20.
//

import SwiftUI

struct PaletteChooser: View {
    @ObservedObject var document: EmojiArtDocument
    @Binding var chosenPalett: String
    
    var body: some View {
        HStack {
            Stepper(
                onIncrement: {
                    chosenPalett = document.palette(after: self.chosenPalett)
                },
                onDecrement: {
                    chosenPalett = document.palette(after: self.chosenPalett)
                },
                label: {
                    EmptyView()
                })
            Text(document.paletteNames[chosenPalett] ?? "")
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        let document = EmojiArtDocument()
        PaletteChooser(document: document, chosenPalett: Binding.constant("⚽️🏈⚾️🎾🏐🏓⛳️🥌⛷🚴‍♂️🎳🎼🎭🪂"))
    }
}
