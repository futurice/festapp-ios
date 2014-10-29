//
//  Gig.swift
//  FestApp
//
//  Created by Oleg Grenrus on 29/10/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

import Foundation

class Gig: NSObject {
    let begin: NSDate
    let end: NSDate
    let stage: String
    let day: String

    let gigId: String
    let gigName: String
    let info: String

    let imagePath: String?
    let wikipediaUrl: NSURL?

    init(dictionary: NSDictionary) {
        begin = (dictionary["start-time"] as? String)?.asIsoDate() ?? swiftDistantPast
        end   = (dictionary["end-time"] as? String)?.asIsoDate() ?? swiftDistantPast

        stage = dictionary["stage"] as? String ?? ""
        day   = dictionary["day"] as? String ?? ""

        let artist: NSDictionary? = dictionary["artist"] as? NSDictionary

        gigId = artist?["id"] as? String ?? ""
        gigName = artist?["name"] as? String ?? ""
        info = artist?["info"] as? String ?? ""

        let wikipediaString: Optional<String> = artist?["wikipedia"] as? String

        // extension magic!
        let str: NSURL? = wikipediaString
            .filter({ str in !str.isEmpty })
            .flatmap({ str in NSURL(string: str, relativeToURL: nil) })

        imagePath = (artist?["id"] as? String).map({ artistId in artistId + ".jpg" })
    }

    func timeIntervalString() -> String {
        return ""
    }

    func stageAndTimeIntervalString() -> String {
        // String interpolation
        return "\(day), \(dateHourAndMinuteString(begin))-\(dateHourAndMinuteString(end)) \(stage)"
    }

    func duration() -> NSTimeInterval {
        return end.timeIntervalSinceDate(begin)
    }
}
