//
//  ContentView.swift
//  KeyboardLingo
//
//  Created by Anton on 2024-12-25.
//

import SwiftUI
#if canImport(CoreHaptics)
import CoreHaptics
#endif

struct ContentView: View {

    @State private var wordSet: WordSet = .default
    
    @AppStorage("wordCount") private var rawWordCount: String = ""
    private var wordCount: [WordSet: Int] {
        var wordCount: [WordSet: Int] = [:]
        for part in rawWordCount.split(separator: ",") {
            let components = part.split(separator: ":")
            guard components.count == 2 else { continue }
            guard let wordSet = WordSet(rawValue: String(components[0])) else { continue }
            guard let count = Int(components[1]) else { continue }
            wordCount[wordSet] = count
        }
        return wordCount
    }
    func incrementCount(for wordSet: WordSet) {
        var wordCount: [WordSet: Int] = wordCount
        wordCount[wordSet, default: 0] += 1
        var raw = ""
        for (wordSet, count) in wordCount {
            if !raw.isEmpty {
                raw += ","
            }
            raw += "\(wordSet.rawValue):\(count)"
        }
        rawWordCount = raw
    }

    @State private var word: Word = WordSet.default.words.first!
    @State private var text: String = ""
    @FocusState private var textFieldFocus: Bool
    
#if canImport(CoreHaptics)
    @State private var hapticEngine: CHHapticEngine?
#endif
    
    private var attributed: AttributedString {
        var string = AttributedString()
        for (index, character) in text.enumerated() {
            let isMatch: Bool = {
                guard index < word.jp.count else { return false }
                let characterIndex = word.jp.index(word.jp.startIndex, offsetBy: index)
                return word.jp[characterIndex] == character
            }()
            let isExtraMatch: Bool = {
                guard let jpExtra: String = word.jpExtra else { return false }
                guard index < jpExtra.count else { return false }
                let characterIndex = jpExtra.index(jpExtra.startIndex, offsetBy: index)
                return jpExtra[characterIndex] == character
            }()
            var container = AttributeContainer()
            container.foregroundColor = isMatch ? .blue : isExtraMatch ? .purple : .gray
            let attributed = AttributedString(String(character), attributes: container)
            string.append(attributed)
        }
        return string
    }
    
    private var jpAttributed: AttributedString {
        var string = AttributedString()
        for (index, character) in word.jp.enumerated() {
            let isMatch: Bool = {
                guard index < text.count else { return false }
                let characterIndex = text.index(text.startIndex, offsetBy: index)
                return text[characterIndex] == character
            }()
            var container = AttributeContainer()
            container.foregroundColor = isMatch ? .blue : .gray
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
            container.foregroundColor = isMatch ? .purple : .gray
            let attributed = AttributedString(String(character), attributes: container)
            string.append(attributed)
        }
        return string
    }
    
    private var jpMatchCount: Int {
        var count: Int = 0
        for (index, character) in word.jp.enumerated() {
            let isMatch: Bool = {
                guard index < text.count else { return false }
                let characterIndex = text.index(text.startIndex, offsetBy: index)
                return text[characterIndex] == character
            }()
            if isMatch {
                count += 1
            }
        }
        return count
    }
    
    private var jpExtraMatchCount: Int {
        guard let jpExtra = word.jpExtra else { return 0 }
        var count: Int = 0
        for (index, character) in jpExtra.enumerated() {
            let isMatch: Bool = {
                guard index < text.count else { return false }
                let characterIndex = text.index(text.startIndex, offsetBy: index)
                return text[characterIndex] == character
            }()
            if isMatch {
                count += 1
            }
        }
        return count
    }
    
    private var matchCount: Int {
        jpMatchCount + jpExtraMatchCount
    }
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                VStack {
                    ScrollView(.horizontal){
                        wordSetPicker
                            .padding(32)
                    }
                    Spacer()
                        .frame(height: 64)
                    Group {
                        if geometry.size.width > geometry.size.height {
                            HStack(spacing: geometry.size.width * 0.1) {
                                checkmarkImage
                                contentBody(size: geometry.size)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: geometry.size.width * 0.1) {
                                checkmarkImage
                                contentBody(size: geometry.size)
                            }
                        }
                    }
                    .font(.system(size: geometry.size.width * 0.075))
                    .padding(32)
                    .frame(maxWidth: .infinity)
                    Spacer()
                }
            }
        }
        .onChange(of: wordSet) { _, newWordSet in
            word = newWordSet.words.randomElement()!
            text = ""
        }
        .onChange(of: matchCount) { oldCount, newCount in
            if newCount > oldCount {
                haptic(count: 1)
            }
        }
    }
    
    private var checkmarkImage: some View {
        Image(systemName: "checkmark")
            .opacity(text == word.jp ? 1.0 : 0.0)
            .foregroundStyle(.green)
    }
    
    private var wordSetPicker: some View {
        HStack(alignment: .top) {
            ForEach(WordSet.allCases) { wordSet in
                let isSelected: Bool = self.wordSet == wordSet
                VStack {
                    Button {
                        self.wordSet = wordSet
                    } label: {
                        Text(wordSet.name)
                            .foregroundStyle(isSelected ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(isSelected ? Color.accentColor : .primary.opacity(0.5), in: .capsule)
                    }
                    .buttonStyle(.plain)
                    if let count = wordCount[wordSet], count > 0 {
                        Text(count, format: .number)
                    }
                }
            }
            VStack {
                Text("Total")
                    .opacity(0.5)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                Text(wordCount.values.reduce(0, +), format: .number)
            }
        }
        .font(.headline)
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
            ZStack(alignment: .leading) {
                textFieldBody(size: size)
                Text(attributed)
            }
        }
    }
    
    private func textFieldBody(size: CGSize) -> some View {
        TextField("...", text: $text)
#if os(iOS)
            .submitLabel(.go)
#endif
            .focused($textFieldFocus)
            .textFieldStyle(.plain)
            .frame(maxWidth: size.width * 0.5)
            .onChange(of: text) { oldText, newText in
                if oldText != word.jp, newText == word.jp {
                    haptic(count: 10, magic: true)
                }
            }
            .onSubmit {
                guard text == word.jp else { return }
                word = wordSet.words.randomElement()!
                text = ""
                textFieldFocus = true
                incrementCount(for: wordSet)
                haptic(count: 2, soft: true)
            }
            .onAppear {
                textFieldFocus = true
            }
    }
    
    private func haptic(count: Int, soft: Bool = false, magic: Bool = false) {
#if os(macOS)
        let manager = NSHapticFeedbackManager.defaultPerformer
        manager.perform(.generic, performanceTime: .now)
#elseif canImport(CoreHaptics)
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        if magic {
            do {
                let duration: TimeInterval = 1.0
                let count: Int = 10
                
                let engine = try CHHapticEngine()
                try engine.start()
                var events = [CHHapticEvent]()
                
                for index in 0..<count {
                    let fraction = TimeInterval(index) / TimeInterval(count)
                    let time: TimeInterval = fraction * duration
                    let continuousVibration = CHHapticEvent(
                        eventType: .hapticContinuous,
                        parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(fraction)),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(fraction))
                        ],
                        relativeTime: time,
                        duration: duration / TimeInterval(count)
                    )
                    events.append(continuousVibration)
                }
                
                let pattern = try CHHapticPattern(events: events, parameters: [])
                
                let player = try engine.makePlayer(with: pattern)
                try player.start(atTime: 0)
                
                hapticEngine = engine
                
                Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
                    engine.stop()
                    hapticEngine = nil
                }
            } catch {
                print("Haptic failure: \(error)")
            }
        } else {
            let generator = UIImpactFeedbackGenerator(style: soft ? .soft : .light)
            generator.prepare()
            generator.impactOccurred()
            if count > 1 {
                var index = 0
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                    generator.impactOccurred()
                    index += 1
                    if index == count - 1 {
                        timer.invalidate()
                    }
                }
            }
        }
#endif
    }
}

#Preview {
    ContentView()
}
