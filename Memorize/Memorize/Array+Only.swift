//
//  Array+Only.swift
//  Memorize
//
//  Created by Alejandro Mendoza on 23/09/20.
//

import Foundation

extension Array {
    var only: Element? {
        count == 1 ? first : nil
    }
}
