//
//  ImageCollectionViewCell.swift
//  ImageGalleryProject
//
//  Created by Or Peleg on 22/05/2022.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var cellView: UIView!
    

    func configure(with imageURL: URL) {
        for subview in cellView.subviews {
            if subview as? UIActivityIndicatorView != nil {
                continue
            }
            subview.removeFromSuperview()
        }
        spinner.alpha = 1
        spinner.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            let urlContents = try? Data(contentsOf: imageURL)
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                let image = UIImage(data: urlContents!)
                let imageView = UIImageView(image: image)
                imageView.frame = self.cellView.frame
                self.cellView.addSubview(imageView)
            }
        }
    }
    
    func blank() {
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = CGFloat(0.5)
    }
}
