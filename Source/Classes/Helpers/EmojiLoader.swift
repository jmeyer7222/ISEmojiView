//
//  EmojiLoader.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation

final public class EmojiLoader {
    
    static func recentEmojiCategory() -> EmojiCategory {
        return EmojiCategory(
            category: .recents,
            emojis: RecentEmojisManager.sharedInstance.recentEmojis()
        )
    }
    
    static func emojiCategories() -> [EmojiCategory] {
        var emojiPListFileName = "ISEmojiList_iOS10";
        if #available(iOS 11.0, *) { emojiPListFileName = "ISEmojiList_iOS11" }
        if #available(iOS 12.1, *) { emojiPListFileName = "ISEmojiList_iOS12" }
        if #available(iOS 13.1, *) { emojiPListFileName = "ISEmojiList" }

        guard let filePath = Bundle.podBundle.path(forResource: emojiPListFileName, ofType: "plist") else {
            return []
        }
        
        guard let categories = NSArray(contentsOfFile: filePath) as? [[String:Any]] else {
            return []
        }
        
        var emojiCategories = [EmojiCategory]()
        
        var availableCategories: [Category] = [
            .smileysAndPeople, .animalsAndNature, .foodAndDrink,
            .activity, .travelAndPlaces, .objects, .symbols, .flags
        ]
        /*
        if #available(iOS 13.1, *) {
            availableCategories = [
                .smileysAndEmotion, .peopleAndBody, .animalsAndNature, .foodAndDrink,
                .activity, .travelAndPlaces, .objects, .symbols, .flags
            ]
        }*/
        
        for dictionary in categories {
            guard let title = dictionary["title"] as? String else {
                continue
            }
            
            guard let category = availableCategories.first(where:
                { $0.title == title
                    || ((title == "Smileys & Emotion" || title == "People & Body") &&
                        $0.title == "Smileys & People")
                    || (title == "Activities" && $0.title == "Activity")
                    
            }) else {
                continue
            }
            
            guard let rawEmojis = dictionary["emojis"] as? [Any] else {
                continue
            }
            
            var emojis = [Emoji]()
            
            for value in rawEmojis {
                if let string = value as? String {
                    emojis.append(Emoji(emojis: [string]))
                } else if let array = value as? [String] {
                    emojis.append(Emoji(emojis: array))
                }
            }
            
            if emojiCategories.contains(where: { (ec) -> Bool in
                ec.category.title == category.title
            }) {
                let c = emojiCategories.first { (ec) -> Bool in
                    ec.category.title == category.title
                }
                
                c?.emojis.append(contentsOf: emojis)
            }
            else {
            
                let emojiCategory = EmojiCategory(category: category, emojis: emojis)
                emojiCategories.append(emojiCategory)
            }
        }
        
        return emojiCategories
    }
    
}
