//
//  OptionalImageView.swift
//  EmojiArt
//
//  Created by Alejandro Mendoza on 29/09/20.
//

import SwiftUI

struct OptionalImage: View {
    var image: UIImage?
    
    var body: some View {
        Group {
            if let backgroundImage = image {
                Image(uiImage: backgroundImage)
            }
        }
    }
}
