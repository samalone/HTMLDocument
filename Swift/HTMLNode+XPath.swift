/*###################################################################################
#                                                                                   #
#    HTMLNode+XPath.swift - Extension for HTMLNode                                  #
#                                                                                   #
#    Copyright © 2014 by Stefan Klieme                                              #
#                                                                                   #
#    Swift wrapper for HTML parser of libxml2                                       #
#                                                                                   #
#    Version 0.9 - 20. Sep 2014                                                     #
#                                                                                   #
#    usage:     add libxml2.dylib to frameworks (depends on autoload settings)      #
#               add $SDKROOT/usr/include/libxml2 to target -> Header Search Paths   #
#               add -lxml2 to target -> other linker flags                          #
#               add Bridging-Header.h to your project and rename it as              #
#                       [Modulename]-Bridging-Header.h                              #
#                    where [Modulename] is the module name in your project          #
#                                                                                   #
#####################################################################################
#                                                                                   #
# Permission is hereby granted, free of charge, to any person obtaining a copy of   #
# this software and associated documentation files (the "Software"), to deal        #
# in the Software without restriction, including without limitation the rights      #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies  #
# of the Software, and to permit persons to whom the Software is furnished to do    #
# so, subject to the following conditions:                                          #
# The above copyright notice and this permission notice shall be included in        #
# all copies or substantial portions of the Software.                               #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR        #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,          #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE       #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, #
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR      #
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.     #
#                                                                                   #
###################################################################################*/

import Foundation

extension HTMLNode  {
    
    // XPath format predicates
    
    struct XPathPredicate {
        static var node: (String) -> String = { return "./descendant::\($0)" }
        static var nodeWithAttribute: (String, String) -> String = { return "//\($0)[@\($1)]" }
        static var attribute: (String) -> String = { return "//*[@\($0)]" }
        static var attributeIsEqual: (String, String) -> String = { return "//*[@\($0) ='\($1)']" }
        static var attributeBeginsWith: (String, String) -> String = { return "./*[starts-with(@\($0),'\($1)')]" }
        static var attributeEndsWith: (String, String) -> String = { return "//*['\($1)' = substring(@\($0)@, string-length(@\($0))- string-length('\($1)') +1)]" }
        static var attributeContains: (String, String) -> String = { return "//*[contains(@\($0),'\($1)')]" }
    }
  
    
    private static func xmlXPathNodeSetIsEmpty(nodes : xmlNodeSetPtr) -> Bool {
        return nodes == nil || nodes.memory.nodeNr == 0 || nodes.memory.nodeTab == nil
    }
    
 
    // performXPathQuery() returns one HTMLNode object or an array of HTMLNode objects if the query matches any nodes, otherwise nil or an empty array
    
//    private func performXPathQuery(node : xmlNodePtr, query : String, returnSingleNode : Bool) throws -> AnyObject
//    {
//        var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
//        var result : AnyObject? = (returnSingleNode) ? nil : Array<HTMLNode>()
//        
//        let xmlDoc = node.memory.doc
//        let xpathContext = xmlXPathNewContext(xmlDoc)
//        
//        if xpathContext != nil {
//            var xpathObject : xmlXPathObjectPtr
//            
//            if (query.hasPrefix("//") || query.hasPrefix("./")) {
//                xpathObject = xmlXPathNodeEval(node, xmlCharFrom(query), xpathContext)
//            } else {
//                xpathObject = xmlXPathEvalExpression(xmlCharFrom(query), xpathContext)
//            }
//
//            if xpathObject != nil {
//                let nodes = xpathObject.memory.nodesetval
//                if xmlXPathNodeSetIsEmpty(nodes) == false {
//                    let nodesArray = UnsafeBufferPointer(start: nodes.memory.nodeTab, count: Int(nodes.memory.nodeNr))
//                    if returnSingleNode {
//                        result = HTMLNode(pointer:nodesArray[0])
//                    } else {
//                        var resultArray = Array<HTMLNode>()
//                        for item in nodesArray {
//                            if let matchedNode = HTMLNode(pointer:item) {
//                                resultArray.append(matchedNode)
//                            }
//                        }
//                        result = resultArray
//                    }
//                }
//                xmlXPathFreeObject(xpathObject)
//            }
//            else {
//                error = setErrorWithMessage("Could not evaluate XPath expression", code:5)
//            }
//            xmlXPathFreeContext(xpathContext)
//        }
//        else {
//            error = setErrorWithMessage("Could not create XPath context", code:4)
//        }
//        
//        if let value = result {
//            return value
//        }
//        throw error
//    }

    // performXPathQuery() returns one HTMLNode object or an array of HTMLNode objects if the query matches any nodes, otherwise nil or an empty array
    
    private func performXPathQuery<T>(query : String, resultConversion: (xmlNodeSetPtr) -> T) throws -> T {
        let xmlDoc = pointer.memory.doc
        let xpathContext = xmlXPathNewContext(xmlDoc)
        guard xpathContext != nil else {
            throw setErrorWithMessage("Could not create XPath context", code:4)
        }
        defer {
            xmlXPathFreeContext(xpathContext)
        }
        
        var xpathObject: xmlXPathObjectPtr
        if (query.hasPrefix("//") || query.hasPrefix("./")) {
            xpathObject = xmlXPathNodeEval(pointer, xmlCharFrom(query), xpathContext)
        } else {
            xpathObject = xmlXPathEvalExpression(xmlCharFrom(query), xpathContext)
        }
        guard xpathObject != nil else {
            throw setErrorWithMessage("Could not evaluate XPath expression", code:5)
        }
        defer {
            xmlXPathFreeObject(xpathObject)
        }

        return resultConversion(xpathObject.memory.nodesetval)
    }

    // MARK: - Objective-C wrapper for XPath Query function
    
    /** 
    Returns the first descendant node for a XPath query.
    
    - parameter query: The XPath query string.
    
    - returns: The first found descendant node or nil if no node matches the parameters.
    */
    
    func nodeForXPath(query : String) throws -> HTMLNode?
    {
        return try performXPathQuery(query) {
            (nodes) -> HTMLNode? in
            
            if !HTMLNode.xmlXPathNodeSetIsEmpty(nodes) {
                let nodesArray = UnsafeBufferPointer(start: nodes.memory.nodeTab, count: Int(nodes.memory.nodeNr))
                return HTMLNode(pointer:nodesArray[0])
            }
            return nil
        }
    }
    
    /**
    Returns all descendant nodes for a XPath query.
    
    - parameter query: The XPath query string.
    
    - returns: The array of all found descendant nodes or an empty array.
    */
    
    func nodesForXPath(query : String) throws -> [HTMLNode]
    {
        return try performXPathQuery(query) {
            (nodes) -> [HTMLNode] in
        
            if !HTMLNode.xmlXPathNodeSetIsEmpty(nodes) {
                let nodesArray = UnsafeBufferPointer(start: nodes.memory.nodeTab, count: Int(nodes.memory.nodeNr))
                var resultArray: [HTMLNode] = []
                for item in nodesArray {
                    if let matchedNode = HTMLNode(pointer:item) {
                        resultArray.append(matchedNode)
                    }
                }
                return resultArray
            }
            return []
        }
    }
    
    
    // MARK: - specific XPath Query methods
    // Note: In the HTMLNode main class all appropriate query methods begin with descendant instead of node
    
    /**
    Returns the first descendant node for a specified tag name.
    
    - parameter tagName: The tag name.
    
    - returns: The first found descendant node or nil if no node matches the parameters.
    */
    
    func nodeOfTag(tagName : String) throws -> HTMLNode?
    {
        return try nodeForXPath(XPathPredicate.node(tagName))
    }
    
    /**
    Returns all descendant nodes for a specified tag name.
    
    - parameter tagName: The tag name.
    
    - returns: The array of all found descendant nodes or an empty array.
    */
    
    func nodesOfTag(tagName : String, inout error : NSError?) throws -> [HTMLNode]
    {
        return try nodesForXPath(XPathPredicate.node(tagName))
    }
    
    /**
    Returns the first descendant node for a matching tag name and matching attribute name.
    
    - parameter tagName: The tag name.
    
    - parameter attributeName: The attribute name.
    
    - returns: The first found descendant node or nil if no node matches the parameters.
    */
    
    func nodeOfTag(tagName : String, withAttribute attribute : String) throws -> HTMLNode?
    {
        return try nodeForXPath(XPathPredicate.nodeWithAttribute(tagName, attribute))
    }
    
    /**
    Returns all descendant nodes for a matching tag name and matching attribute name.
    
    - parameter tagName: The tag name.
    
    - parameter attributeName: The attribute name.
    
    - returns: The array of all found descendant nodes or an empty array.
    */
    
    func nodesOfTag(tagName : String, withAttribute attribute : String) throws -> Array<HTMLNode>
    {
        return try nodesForXPath(XPathPredicate.nodeWithAttribute(tagName, attribute))
    }

    /**
    Returns the first descendant node for a specified attribute name.
    
    - parameter attributeName: The attribute name.
    
    - parameter error: An error object that, on return, identifies any Xpath errors.
    
    - returns: The first found descendant node or nil if no node matches the parameters.
    */
    
    func nodeWithAttribute(attributeName : String) throws -> HTMLNode?
    {
        return try nodeForXPath(XPathPredicate.attribute(attributeName))
    }
    
    /**
    Returns all descendant nodes for a specified attribute name.
    
    - parameter attributeName: The attribute name.
    
    - returns: The array of all found descendant nodes or an empty array.
    */
    
    func nodesWithAttribute(attributeName : String) throws -> [HTMLNode]
    {
        return try nodesForXPath(XPathPredicate.attribute(attributeName))
    }
    
    /**
    Returns the first descendant node for a matching attribute name and matching attribute value.
    
    - parameter attributeName: The attribute name.
    
    - parameter value: The attribute value.
    
    - returns: The first found descendant node or nil if no node matches the parameters.
    */
    
    func nodeWithAttribute(attributeName : String, valueMatches value : String) throws -> HTMLNode?
    {
        return try nodeForXPath(XPathPredicate.attributeIsEqual(attributeName, value))
    }
    
    /**
    Returns all descendant nodes for a matching attribute name and matching attribute value.
    
    - parameter attributeName: The attribute name.
    
    - parameter value: The attribute value.
    
    - returns: The array of all found descendant nodes or an empty array.
    */
    
    func nodesWithAttribute(attributeName : String, valueMatches value : String) throws -> [HTMLNode]
    {
        return try nodesForXPath(XPathPredicate.attributeIsEqual(attributeName, value))
    }
    
    /**
    Returns the first descendant node for a matching attribute name and beginning of the attribute value.
    
    - parameter attributeName: The attribute name.
    
    - parameter value: The attribute value.
    
    - parameter error: An error object that, on return, identifies any Xpath errors.
    
    - returns: The first found descendant node or nil if no node matches the parameters.
    */

    func nodeWithAttribute(attributeName : String,  valueBeginsWith value : String) throws -> HTMLNode?
    {
        return try nodeForXPath(XPathPredicate.attributeBeginsWith(attributeName, value))
    }
    
    /**
    Returns all descendant nodes for a matching attribute name and beginning of the attribute value.
    
    - parameter attributeName: The attribute name.
    
    - parameter value: The attribute value.
    
    - returns: The array of all found descendant nodes or an empty array.
    */
    
    func nodesWithAttribute(attributeName : String,  valueBeginsWith value : String) throws -> [HTMLNode]
    {
        return try nodesForXPath(XPathPredicate.attributeBeginsWith(attributeName, value))
    }
    
    /**
    Returns the first descendant node for a matching attribute name and ending of the attribute value.
    
    - parameter attributeName: The attribute name.
    
    - parameter value: The attribute value.
    
    - returns: The first found descendant node or nil if no node matches the parameters.
    */
    
    func nodeWithAttribute(attributeName : String,  valueEndsWith value : String) throws -> HTMLNode?
    {
        return try nodeForXPath(XPathPredicate.attributeEndsWith(attributeName, value))
    }
    
    /**
    Returns all descendant nodes for a matching attribute name and ending of the attribute value.
    
    - parameter attributeName: The attribute name.
    
    - parameter value: The attribute value.
    
    - returns: The array of all found descendant nodes or an empty array.
    */
    
    func nodesWithAttribute(attributeName : String,  valueEndsWith value : String) throws -> [HTMLNode]
    {
        return try nodesForXPath(XPathPredicate.attributeEndsWith(attributeName, value))
    }
    
    /**
    Returns the first descendant node for a matching attribute name and containing the attribute value.
    
    - parameter attributeName: The attribute name.
    
    - parameter value: The attribute value.
    
    - returns: The first found descendant node or nil if no node matches the parameters.
    */
    
    func nodeWithAttribute(attributeName : String,  valueContains value : String) throws -> HTMLNode?
    {
        return try nodeForXPath(XPathPredicate.attributeContains(attributeName, value))
    }
    
    /**
    Returns all descendant nodes for a matching attribute name and containing the attribute value.
    
    - parameter attributeName: The attribute name.
    
    - parameter value: The attribute value.
    
    - returns: The array of all found descendant nodes or an empty array.
    */
    
    func nodesWithAttribute(attributeName : String,  valueContains value : String) throws -> [HTMLNode]
    {
        return try nodesForXPath(XPathPredicate.attributeContains(attributeName, value))
    }
    
    /**
    Returns the first descendant node for a specified class name.
    
    - parameter classValue: The class name.
    
    - returns: The first found descendant node or nil if no node matches the parameters.
    */
    
    func nodeWithClass(classValue : String) throws -> HTMLNode?
    {
        return try nodeWithAttribute(kClassKey, valueMatches:classValue)
    }
    
    /**
    Returns all descendant nodes for a specified class name.
    
    - parameter classValue: The class name.
    
    - returns: The array of all found descendant nodes or an empty array.
    */
    
    func nodesWithClass(classValue : String) throws -> [HTMLNode]
    {
        return try nodesWithAttribute(kClassKey, valueMatches:classValue)
    }

    // MARK: -  error handling
    
    func setErrorWithMessage(message : String, code : Int) -> NSError
    {
        return NSError(domain: "com.klieme.HTMLDocument", code:code, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
}
