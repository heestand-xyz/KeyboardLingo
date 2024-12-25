//
//  WordSet.swift
//  KeyboardLingo
//
//  Created by Anton on 2024-12-25.
//

enum WordSet: String, CaseIterable {
    case basic
    case tech
    case house
    case travel
    case food
    case cafe
    case weather
}

extension WordSet: Identifiable {
    var id: String { rawValue }
}

extension WordSet {
    static let `default`: WordSet = .basic
}

extension WordSet {
    var name: String {
        switch self {
        case .basic:
            "Basic"
        case .tech:
            "Tech"
        case .house:
            "House"
        case .travel:
            "Travel"
        case .food:
            "Food"
        case .cafe:
            "Cafe"
        case .weather:
            "Weather"
        }
    }
}

extension WordSet {
    var words: [Word] {
        switch self {
        case .basic:
            basicWords
        case .tech:
            techWords
        case .house:
            houseWords
        case .travel:
            travelWords
        case .food:
            foodWords
        case .cafe:
            cafeWords
        case .weather:
            weatherWords
        }
    }
}
