//
//  ContentView.swift
//  KeyboardLingo
//
//  Created by Anton on 2024-12-25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var word: Word = words.first!
    @State private var text: String = ""
    
    var jpAttributed: AttributedString {
        var string = AttributedString()
        for (index, character) in word.jp.enumerated() {
            let isMatch: Bool = {
                guard index < text.count else { return false }
                let characterIndex = text.index(text.startIndex, offsetBy: index)
                return text[characterIndex] == character
            }()
            var container = AttributeContainer()
            container[AttributeScopes.AppKitAttributes.ForegroundColorAttribute.self] = isMatch ? .textColor : .gray
            let attributed = AttributedString(String(character), attributes: container)
            string.append(attributed)
        }
        return string
    }
    
    var jpExtraAttributed: AttributedString? {
        guard let jpExtra = word.jpExtra else { return nil }
        var string = AttributedString()
        for (index, character) in jpExtra.enumerated() {
            let isMatch: Bool = {
                guard index < text.count else { return false }
                let characterIndex = text.index(text.startIndex, offsetBy: index)
                return text[characterIndex] == character
            }()
            var container = AttributeContainer()
            container[AttributeScopes.AppKitAttributes.ForegroundColorAttribute.self] = isMatch ? .textColor : .gray
            let attributed = AttributedString(String(character), attributes: container)
            string.append(attributed)
        }
        return string
    }
    
    var body: some View {
        HStack(spacing: 100) {
            Image(systemName: "checkmark")
                .opacity(text == word.jp ? 1.0 : 0.0)
            VStack(alignment: .leading) {
                Text(word.en)
                HStack {
                    Text(jpAttributed)
                    if let jpExtraAttributed {
                        Text("(")
                        Text(jpExtraAttributed)
                        Text(")")
                    }
                }
                    TextField("...", text: $text)
                        .textFieldStyle(.plain)
                        .frame(maxWidth: 1500)
                        .onSubmit {
                            guard text == word.jp else { return }
                            word = words.randomElement()!
                            text = ""
                        }
            }
        }
        .font(.system(size: 200))
        .padding(200)
    }
}

#Preview {
    ContentView()
}
