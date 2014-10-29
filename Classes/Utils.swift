//
//  Utils.swift
//  FestApp
//
//  Created by Oleg Grenrus on 29/10/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

import Foundation

func makeIsoDateFormatter() -> NSDateFormatter {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    return dateFormatter
}

// Starting from some iOS, NSDateFormatter is thread-safe
let isoDateFormatter = makeIsoDateFormatter()

// To permit optional chaining
extension String {
    func asIsoDate() -> NSDate? {
        return isoDateFormatter.dateFromString(self)
    }
}

// https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSDate_Class/#//apple_ref/occ/clm/NSDate/distantPast
let swiftDistantPast: NSDate = NSDate.distantPast() as NSDate
let swiftDistantFuture: NSDate = NSDate.distantFuture() as NSDate

extension Optional {
    func filter(predicate: (T) -> Bool) -> T? {
        if let x = self {
            if (predicate(x)) {
                return x
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    func flatmap<U>(f: (T) -> U?) -> U? {
        if let x = self {
            return f(x)
        } else {
            return nil
        }
    }
}

func dateHourAndMinuteString(date: NSDate) -> String {
    let formatter: NSDateFormatter = NSDateFormatter()
    formatter.dateFormat = "HH:mm";
    return formatter.stringFromDate(date)
}

extension NSDate {
    func hourAndMinuteString() -> String {
        return "xx-xx";
    }
}