//
//  ContentView.swift
//  KeyboardLingo
//
//  Created by Anton on 2024-12-25.
//

import SwiftUI

struct ContentView: View {

    @State private var wordSet: WordSet = .default

    @State private var word: Word = WordSet.default.words.first!
    @State private var text: String = ""
    @FocusState private var textFieldFocus: Bool
    
    private var jpAttributed: AttributedString {
        var string = AttributedString()
        for (index, character) in word.jp.enumerated() {
            let isMatch: Bool = {
                guard index < text.count else { return false }
                let characterIndex = text.index(text.startIndex, offsetBy: index)
                return text[characterIndex] == character
            }()
            var container = AttributeContainer()
            container.foregroundColor = isMatch ? .accentColor : .gray
            let attributed = AttributedString(String(character), attributes: container)
            string.append(attributed)
        }
        return string
    }
    
    private var jpExtraAttributed: AttributedString? {
        guard let jpExtra = word.jpExtra else { return nil }
        var string = AttributedString()
        for (index, character) in jpExtra.enumerated() {
            let isMatch: Bool = {
                guard index < text.count else { return false }
                let characterIndex = text.index(text.startIndex, offsetBy: index)
                return text[characterIndex] == character
            }()
            var container = AttributeContainer()
            container.foregroundColor = isMatch ? .accentColor : .gray
            let attributed = AttributedString(String(character), attributes: container)
            string.append(attributed)
        }
        return string
    }
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                VStack {
                    wordSetPicker
                    Spacer()
                    Group {
                        if geometry.size.width > geometry.size.height {
                            HStack(spacing: geometry.size.width * 0.05) {
                                checkmarkImage
                                contentBody(size: geometry.size)
                            }
                            .font(.system(size: geometry.size.width * 0.1))
                        } else {
                            VStack(alignment: .leading, spacing: geometry.size.width * 0.1) {
                                checkmarkImage
                                contentBody(size: geometry.size)
                            }
                            .font(.system(size: geometry.size.width * 0.1))
                        }
                    }
                    .padding(geometry.size.width * 0.05)
                    .frame(maxWidth: .infinity)
                    Spacer()
                }
                .padding(32)
            }
        }
        .onChange(of: wordSet) { _, newWordSet in
            word = newWordSet.words.randomElement()!
            text = ""
        }
    }
    
    private var checkmarkImage: some View {
        Image(systemName: "checkmark")
            .opacity(text == word.jp ? 1.0 : 0.0)
            .foregroundStyle(.green)
    }
    
    private var wordSetPicker: some View {
        Picker(selection: $wordSet) {
            ForEach(WordSet.allCases) { wordSet in
                Text(wordSet.name)
                    .tag(wordSet)
            }
        } label: {
            EmptyView()
        }
        .labelsHidden()
        .pickerStyle(.segmented)
        .frame(maxWidth: 400)
    }
    
    private func contentBody(size: CGSize) -> some View {
        VStack(alignment: .leading) {
            Text(word.en)
                .textSelection(.enabled)
            HStack {
                Text(jpAttributed)
                    .textSelection(.enabled)
                if let jpExtraAttributed {
                    Text("(")
                    Text(jpExtraAttributed)
                        .textSelection(.enabled)
                    Text(")")
                }
            }
            TextField("...", text: $text)
#if os(iOS)
                .submitLabel(.go)
#endif
                .focused($textFieldFocus)
                .textFieldStyle(.plain)
                .frame(maxWidth: size.width * 0.5)
                .onSubmit {
                    guard text == word.jp else { return }
                    word = wordSet.words.randomElement()!
                    text = ""
                    textFieldFocus = true
                }
                .onAppear {
                    textFieldFocus = true
                }
        }
    }
}

#Preview {
    ContentView()
}
