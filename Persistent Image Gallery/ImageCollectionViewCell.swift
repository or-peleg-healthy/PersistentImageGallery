//
//  ImageCollectionViewCell.swift
//  ImageGalleryProject
//
//  Created by Or Peleg on 22/05/2022.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    static var imageCache = URLCache(memoryCapacity: 0, diskCapacity: 1000000000000)
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var cellView: UIView!
    
    func configure(with imageURL: URL) {
        for subview in cellView.subviews {
            if subview as? UIActivityIndicatorView != nil || subview as? UILabel != nil {
                continue
            }
            subview.removeFromSuperview()
        }
        spinner.alpha = 1
        spinner.startAnimating()
        if let response = ImageCollectionViewCell.imageCache.cachedResponse(for: URLRequest(url: imageURL)) {
            print(response.data)
            self.spinner.stopAnimating()
            let image = UIImage(data: response.data)
            let imageView = UIImageView(image: image)
            imageView.frame = self.cellView.frame
            self.cellView.addSubview(imageView)
        } else {
            print(imageURL)
            print("new cache")
            DispatchQueue.global(qos: .userInitiated).async {
                let urlContents = try? Data(contentsOf: imageURL)
                ImageCollectionViewCell.imageCache.storeCachedResponse(CachedURLResponse(response: URLResponse(),
                                                                      data: urlContents!, storagePolicy: .allowedInMemoryOnly), for: URLRequest(url: imageURL))
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    let image = UIImage(data: urlContents!)
                    let imageView = UIImageView(image: image)
                    imageView.frame = self.cellView.frame
                    self.cellView.addSubview(imageView)
                }
            }
        }
    }
    
    var isInEditingMode: Bool = false {
        didSet {
            if isInEditingMode {
                self.layer.borderColor = UIColor.blue.cgColor
                self.layer.borderWidth = 3
            } else {
                self.layer.borderColor = UIColor.clear.cgColor
                self.layer.borderWidth = 0
            }
        }
    }

    override var isSelected: Bool {
        didSet {
            if isInEditingMode {
                if isSelected {
                    self.layer.borderColor = UIColor.green.cgColor
                    self.layer.borderWidth = 3
                } else {
                    self.layer.borderColor = UIColor.blue.cgColor
                }
            }
        }
    }
    
    func blank() {
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = CGFloat(0.5)
    }
}
