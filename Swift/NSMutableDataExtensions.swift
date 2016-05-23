//
//  NSMutableDataExtensions.swift
//  Roundings
//
//  Created by Stuart A. Malone on 12/24/15.
//  Copyright © 2015 Llamagraphics, Inc. All rights reserved.
//

import Foundation

extension NSMutableData {
    func appendUTF8(s: String) {
        appendData(s.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
}
