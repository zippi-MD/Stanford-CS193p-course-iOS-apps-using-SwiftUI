//
//  Array+Identifiable.swift
//  Memorize
//
//  Created by Alejandro Mendoza on 23/09/20.
//

import Foundation

extension Array where Element: Identifiable {
    func firstIndex(matching: Element) -> Int? {
        for (index, _) in self.enumerated() {
            if self[index].id == matching.id {
                return index
            }
        }
        return nil
    }
}
