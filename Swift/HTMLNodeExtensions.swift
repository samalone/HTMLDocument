//
//  HTMLNodeExtensions.swift
//  Roundings
//
//  Created by Stuart A. Malone on 12/24/15.
//  Copyright © 2015 Llamagraphics, Inc. All rights reserved.
//

import Foundation

extension HTMLNode {
    var formDefaultValues: [String: String] {
        var defaults: [String: String] = [:]
        
        do {
            let inputs = try self.nodesForXPath(".//input[@name][@value]")
            for input in inputs {
                let key = input.attributeForName("name")!
                let value = input.attributeForName("value")!
                let type = input.attributeForName("type")!
                switch type {
                case "radio", "checkbox":
                    if let _ = input.attributeForName("checked") {
                        defaults[key] = value
                    }
                case "text", "hidden":
                    defaults[key] = value
                case "submit":
                    break   // we do not assume which submit button will be pressed
                default:
                    print(input)
                }
            }
            let selects = try self.nodesForXPath(".//select[@name]")
            for select in selects {
                let name = select.attributeForName("name")!
                if let selected = try select.nodeForXPath(".//option[@selected][@value]") {
                    print(selected)
                    let value = selected.attributeForName("value")!
                    defaults[name] = value
                }
            }
        }
        catch {
        }
        
        return defaults
    }
}
