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
    
    @State private var showPaletteEditor: Bool = false
    
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
            Image(systemName: "keyboard").imageScale(.large)
                .onTapGesture {
                    showPaletteEditor = true
                }
                .popover(isPresented: $showPaletteEditor) {
                    PaletteEditor(chosenPalette: $chosenPalett, isShowing: $showPaletteEditor)
                        .environmentObject(document)
                        .frame(minWidth: 300, minHeight: 500)
                }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}


struct PaletteEditor: View {
    @EnvironmentObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    @Binding var isShowing: Bool
    
    @State private var paletteName: String = ""
    @State private var emojisToAdd: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Palette Editor")
                    .font(.headline)
                    .padding()
                HStack {
                    Spacer()
                    Button {isShowing = false} label: {Text("Done")}
                    .padding()
                }
            }
            
            Divider()
            Form {
                Section {
                    TextField("Palette Name", text: $paletteName, onEditingChanged: { began in
                        if !began {
                            document.renamePalette(chosenPalette, to: paletteName)
                        }
                    })
                    
                    TextField("Add Emoji", text: $emojisToAdd, onEditingChanged: { began in
                        if !began {
                            chosenPalette = document.addEmoji(emojisToAdd, toPalette: chosenPalette)
                            emojisToAdd = ""
                        }
                    })
                }
                Section(header: Text("Remove Emoji")) {
                    Grid(chosenPalette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: fontSize))
                            .onTapGesture {
                                chosenPalette = document.removeEmoji(emoji, fromPalette: chosenPalette)
                            }
                    }
                    .frame(height: height)
                }
            }
        }
        .onAppear {
            paletteName = document.paletteNames[chosenPalette] ?? ""
        }
    }
    
    //MARK: - Drawing Constants
    private var height: CGFloat {
        CGFloat((chosenPalette.count - 1) / 6) * 70 + 70
    }
    
    private let fontSize: CGFloat = 40
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        let document = EmojiArtDocument()
        PaletteChooser(document: document, chosenPalett: Binding.constant("⚽️🏈⚾️🎾🏐🏓⛳️🥌⛷🚴‍♂️🎳🎼🎭🪂"))
    }
}
