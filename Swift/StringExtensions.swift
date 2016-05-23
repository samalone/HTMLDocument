//
//  NSStringExtensions.swift
//  Roundings
//
//  Created by Stuart A. Malone on 12/24/15.
//  Copyright © 2015 Llamagraphics, Inc. All rights reserved.
//

import Foundation

extension String {
    private static let allowedURLCharacters = NSCharacterSet(charactersInString: "!*'\"();:@&=+$,/?%#[]% ")
    
    public var urlEncoded: NSData {
        let str = NSString(string: self).stringByAddingPercentEncodingWithAllowedCharacters(String.allowedURLCharacters)!
        return str.dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    public func parseQuery() -> [String: String] {
        var query: [String: String] = [:]
        for qs in self.componentsSeparatedByString("&") {
            let split = qs.componentsSeparatedByString("=")
            query[split[0]] = split[1].stringByReplacingOccurrencesOfString("+", withString: " ").stringByRemovingPercentEncoding!
        }
        return query
    }
}
