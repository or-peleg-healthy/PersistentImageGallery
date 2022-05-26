//
//  Gallery.swift
//  ImageGalleryProject
//
//  Created by Or Peleg on 22/05/2022.
//

import Foundation
import UIKit

class Gallery: Codable {
    var name: String
    var images: [URL]
    var aspectRatios: [Double]
    
    var json: Data? {
        return try! JSONEncoder().encode(self)
    }
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(Gallery.self, from: json) {
            self.name = newValue.name
            self.images = newValue.images
            self.aspectRatios = newValue.aspectRatios
        } else {
            return nil
        }
    }
    
    init(name: String) {
        self.name = name
        images = []
        aspectRatios = []
    }
}
