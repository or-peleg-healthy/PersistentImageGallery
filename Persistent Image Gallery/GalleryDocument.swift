//
//  Document.swift
//  Persistent Image Gallery
//
//  Created by Or Peleg on 24/05/2022.
//

import UIKit

class GalleryDocument: UIDocument {
    
    var gallery: Gallery?
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return gallery?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
        if let json = contents as? Data {
//            gallery = Gallery(json: json)
        }
    }
}

