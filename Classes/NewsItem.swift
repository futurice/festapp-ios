//
//  NewsItem.swift
//  FestApp
//
//  Created by Oleg Grenrus on 29/10/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

import Foundation

class NewsItem: NSObject {
    let title: String
    let content: String
    let published: NSDate

    init(title: String, content: String, published: NSDate) {
        self.title = title
        self.content = content
        self.published = published
    }

    init(dictionary: NSDictionary) {
        title = dictionary["title"] as? String ?? "" // ???
        content = dictionary["content"] as? String ?? ""

        // Optional Chaining - https://developer.apple.com/library/ios/documentation/swift/conceptual/swift_programming_language/OptionalChaining.html
        published = (dictionary["published"] as? String)?.asIsoDate() ?? swiftDistantPast
    }
}
