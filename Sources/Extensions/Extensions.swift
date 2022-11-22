//
//  Extensions.swift
//  BlackBook
//
//  Created by Nikolas on 13.11.2022.
//

import Foundation
import NaturalLanguage

//MARK: Collection
extension Collection {
    var second: Element? { dropFirst().first }
}

//MARK: String
extension String {
    func permute(minStringLen: Int = 1) -> Set<String> {
        func permute(fromList: [String], toList: [String], minStringLen: Int, set: inout Set<String>) {
            if toList.count >= minStringLen {
                set.insert(toList.joined(separator: " "))
            }
            
            if !fromList.isEmpty {
                for (index, item) in fromList.enumerated() {
                    var newFrom = fromList
                    newFrom.remove(at: index)
                    permute(fromList: newFrom, toList: toList + [item], minStringLen: minStringLen, set: &set)
                }
            }
        }
        
        let list = self.components(separatedBy: " ")
        var set = Set<String>()
        permute(fromList: list, toList:[], minStringLen: minStringLen, set: &set)
        return set
    }

    
    
    func detectedLanguage() -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(self)
        guard let languageCode = recognizer.dominantLanguage?.rawValue else { return nil }
        let detectedLanguage = Locale.current.localizedString(forIdentifier: languageCode)
        return detectedLanguage
    }
    
    func hyphenated(languageCode: String?) -> String {
        guard let languageCode = languageCode else{return self}
        let locale = Locale(identifier: languageCode)
        return self.hyphenated(locale: locale)
    }
    
    func hyphenated(locale: Locale, wordMinimumLenght: Int = 4) -> String {
        guard CFStringIsHyphenationAvailableForLocale(locale as CFLocale) else {return self}
        
        var s = self
        
        var words = s.components(separatedBy: " ")
        
        for index in 0..<words.count {
            if words[index].count > wordMinimumLenght && !words[index].contains("-") {
                let fullRange = CFRangeMake(0, words[index].utf16.count)
                var hyphenationLocations = [CFIndex]()
                for (i, _) in words[index].utf16.enumerated() {
                    let location: CFIndex = CFStringGetHyphenationLocationBeforeIndex(words[index] as CFString, i, fullRange, 0, locale as CFLocale, nil)
                    if hyphenationLocations.last != location {
                        hyphenationLocations.append(location)
                    }
                }
                for l in hyphenationLocations.reversed() {
                    guard l > 0 else { continue }
                    let strIndex = String.Index(utf16Offset: l, in: words[index])
                    words[index].insert("\u{00AD}", at: strIndex)
                }
            }
        }
        
        s = words.joined(separator: " ")
        
        return s
    }
}
