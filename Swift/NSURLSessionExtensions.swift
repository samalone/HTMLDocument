//
//  NSURLSessionExtensions.swift
//  Roundings
//
//  Created by Stuart A. Malone on 12/24/15.
//  Copyright © 2015 Llamagraphics, Inc. All rights reserved.
//

import Foundation

private func + <KeyType, ValueType> (left: [KeyType: ValueType], right: [KeyType: ValueType]) -> [KeyType: ValueType] {
    var result = left
    for (k, v) in right { 
        result.updateValue(v, forKey: k)
    }
    return result
}

extension NSURLSession {
    public func submitForm(form: HTMLNode, response: NSURLResponse, withData postData: [String:String],
        completion: (NSData?, NSURLResponse?, NSError?) -> Void) {
            
        let mergedPostData = form.formDefaultValues + postData
        
        let action = form.attributeForName("action")!
        let submitReq = NSMutableURLRequest(URL: NSURL(string: action, relativeToURL: response.URL!)!, postData: mergedPostData)
        let task2 = dataTaskWithRequest(submitReq, completionHandler: completion)
        task2.resume()
    }

    public func submitForm(url: NSURL, formID: String, withData postData: [String:String],
        completion: (NSData?, NSURLResponse?, NSError?) -> Void) {
        let task = self.dataTaskWithURL(url) {
            (data, response, error) -> Void in
            if let data = data where error == nil {
                do {
                    let html = try HTMLDocument(data: data)
                    if let form = try html.rootNode.nodeForXPath("//form[@id ='\(formID)']") {
                        self.submitForm(form, response: response!, withData: postData, completion: completion)
                    }
                    else {
                        completion(data, response, error)
                    }
                }
                catch {
                }
            }
            else {
                completion(data, response, error)
            }
        }
        task.resume()
    }

    public func getForm(url: NSURL, formID: String,
        completion: (form: HTMLNode?, response: NSURLResponse?, error: NSError?) -> Void) {
        let task = self.dataTaskWithURL(url) {
            (data, response, getError) -> Void in
            if let data = data where getError == nil {
                do {
                    let html = try HTMLDocument(data: data)
                    let form = try html.rootNode.nodeForXPath("//form[@id ='\(formID)']")
                    completion(form: form, response: response, error: nil)
                }
                catch let err as NSError {
                    completion(form: nil, response: response, error: err)
                }
                catch {
                    completion(form: nil, response: response, error: NSError(domain: "org.edgewoodsailing.roundings", code: 1, userInfo: [NSLocalizedDescriptionKey: "Caught unknown exception"]))
                }
            }
            else {
                completion(form: nil, response: response, error: getError)
            }
        }
        task.resume()
    }
}
