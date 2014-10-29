//
//  InfoItem.swift
//  FestApp
//
//  Created by Oleg Grenrus on 28/10/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

import Foundation

// subclassing NSObject is important
class InfoItem: NSObject {
    let title: String
    let content: String

    init(title: String, content: String) {
        self.title = title
        self.content = content
    }

    // this will generate initWithDictionary objective-c class
    init(dictionary: NSDictionary) {
        title = dictionary["title"] as? String ?? "" // ???
        content = dictionary["content"] as? String ?? ""
    }
}
