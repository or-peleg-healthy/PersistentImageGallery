//
//  Gallery.swift
//  ImageGalleryProject
//
//  Created by Or Peleg on 22/05/2022.
//

import Foundation

class Gallery: Codable {
    var name: String
    var images: [URL]
    var aspectRatios: [Double]
    
    var json: Data
    
    init(name: String) {
        self.name = name
        images = []
        aspectRatios = []
    }
}
