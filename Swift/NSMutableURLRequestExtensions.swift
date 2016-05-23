//
//  NSMutableURLRequestExtension.swift
//  Roundings
//
//  Created by Stuart A. Malone on 12/24/15.
//  Copyright © 2015 Llamagraphics, Inc. All rights reserved.
//

import Foundation
//+ (NSMutableURLRequest *) newPostRequestWithURL: (NSURL *)url data: (NSDictionary *)data {
//    NSLog(@"Posting to %@ with %@", url, data);
//    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL: url];
//    [request setHTTPMethod: @"POST"];
//    NSMutableData * postData = [NSMutableData data];
//    for (NSString * key in data) {
//        if ([postData length] > 0) {
//            [postData appendBytes: "&" length: 1];
//        }
//        [postData appendData: [key urlEncodeUsingEncoding: NSUTF8StringEncoding]];
//        [postData appendBytes: "=" length: 1];
//        id value = data[key];
//        if ([value isKindOfClass: [NSString class]]) {
//            [postData appendData: [value urlEncodeUsingEncoding: NSUTF8StringEncoding]];
//        }
//        else if ([value isKindOfClass: [NSNumber class]]) {
//            [postData appendData: [[value stringValue] urlEncodeUsingEncoding: NSUTF8StringEncoding]];
//        }
//        else {  // Should be NSArray or NSDictionary
//            NSError * error = nil;
//            [postData appendData: [NSJSONSerialization dataWithJSONObject: value options: 0 error: &error]];
//        }
//    }
//    [request setHTTPBody: postData];
//    return request;
//}

extension NSMutableURLRequest {
    convenience init(URL: NSURL, postData: [String: String]) {
        self.init(URL: URL)
        self.HTTPMethod = "POST"
        let data = NSMutableData()
        for (key, value) in postData {
            if data.length > 0 {
                data.appendUTF8("&")
            }
            data.appendData(key.urlEncoded)
            data.appendUTF8("=")
            data.appendData(value.urlEncoded)
        }
        self.HTTPBody = data
    }
}
