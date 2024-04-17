//
//  Model.swift
//  MyAwesomeApp
//
//  Created by vincent blanchet on 17/04/2024.
//

import Foundation

enum ArmorType: String, CaseIterable {
    case helmet
    case shield
    case boot

    var image: String {
        switch self {
        case .helmet:
            "🪖"
        case .shield:
            "🛡️"
        case .boot:
            "🥾"
        }
    }
}

enum Rarity: String, CaseIterable {
    case common
    case uncommon
    case rare
    case epic
    case legendary
    case relic
}

enum Rank: String, CaseIterable {
    case warrior
    case soldier
    case knight
    case lord
    case king
}

enum Metal: String, CaseIterable {
    case bronze
    case iron
    case steel
    case silver
    case gold
    case argent
}

