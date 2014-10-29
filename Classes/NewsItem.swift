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
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

        title = dictionary["title"] as? String ?? "" // ???
        content = dictionary["content"] as? String ?? ""

        // https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSDate_Class/#//apple_ref/occ/clm/NSDate/distantPast
        published = dateFormatter.dateFromString(dictionary["published"] as String) ?? (NSDate.distantPast() as NSDate) // unsafe downcasts
    }
}
