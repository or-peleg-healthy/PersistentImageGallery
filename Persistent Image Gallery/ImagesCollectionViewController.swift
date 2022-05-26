//
//  ImagesCollectionViewController.swift
//  ImageGalleryProject
//
//  Created by Or Peleg on 22/05/2022.
//

import UIKit


class ImagesCollectionViewController: UICollectionViewController,  UICollectionViewDragDelegate, UICollectionViewDropDelegate, UIDropInteractionDelegate, UICollectionViewDelegateFlowLayout {
   
    let defaultURL = URL(string: "https://www.biography.com/.image/ar_1:1%2Cc_fill%2Ccs_srgb%2Cg_face%2Cq_auto:good%2Cw_300/MTQ3NTI2NTg2OTE1MTA0MjM4/kenrick_lamar_photo_by_jason_merritt_getty_images_entertainment_getty_476933160.jpg")
    var gallery: Gallery?
    var chosenImageToEnlarge: URL?
    @IBOutlet weak var trashCan: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.dragDelegate = self
        collectionView?.dropDelegate = self
        collectionView.addInteraction(UIDropInteraction(delegate: self))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchToScale(_:)))
        self.collectionView.addGestureRecognizer(pinch)
        collectionView.dragInteractionEnabled = true
        collectionView.allowsMultipleSelection = true
    }
    
    var document: GalleryDocument?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        document?.open() { [self] success in
            if success {
                self.title = self.document?.localizedName
                self.gallery = self.document?.gallery
                if self.gallery == nil {
                    self.gallery = Gallery(name: "untitled")
                }
                collectionView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        save()
        if document?.gallery != nil {
            if let firstCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? ImageCollectionViewCell {
                if let firstCellImage = firstCell.cellView.subviews[1] as? UIImageView {
                    let image = firstCellImage.image
                    document?.thumbnail = image
                }
            }
        }
        dismiss(animated: true) {
            self.document?.close()
        }
    }
    
    @IBAction func save(_ sender: UIBarButtonItem? = nil) {
        document?.gallery = gallery
        if document?.gallery != nil {
            document?.updateChangeCount(.done)
        }
    }
    
    
    @IBAction func edit(_ sender: Any) {
        isEditing.toggle()
        trashCan.isEnabled = false
    }
    
    @IBAction func deleteItem(_ sender: Any) {
        var items: [Int] = []
        var indexPaths: [IndexPath] = []
        for indexPath in collectionView.indexPathsForVisibleItems {
            if let imageCollectionViewCell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
                if imageCollectionViewCell.isSelected {
                    items.append(indexPath.item)
                    indexPaths.append(indexPath)
                }
            }
        }
        if items != [] {
            items = items.sorted().reversed()
              for item in items {
                  gallery?.images.remove(at: item)
                  gallery?.aspectRatios.remove(at: item)
              }
              collectionView.deleteItems(at: indexPaths)
              trashCan.isEnabled = false
            isEditing = false
        }
    }
    
    @objc func pinchToScale(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            if cellWidth > 300 {
                cellWidth = 300
                return
            }
            cellWidth = cellWidth * sender.scale
            sender.scale = 1
        }
    }
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    private var cellWidth: CGFloat = 50 { didSet {
        collectionView.performBatchUpdates {
            flowLayout!.invalidateLayout()
        } completion: { _ in
            self.collectionView.reloadData()
        }
    }}
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let height = cellWidth / (gallery?.aspectRatios[indexPath.item])!
        let cellSize = CGSize(width: cellWidth, height: height)
        return cellSize
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery?.images.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if document!.hasUnsavedChanges {
            document?.autosave(completionHandler: { [self]_ in
                if gallery != nil {
                    document?.updateChangeCount(.done)
                }
            })
        }
        var cell = UICollectionViewCell()
        if let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ImageCollectionViewCell {
            if gallery != nil, indexPath.item < ((gallery?.images.count)!) {
                imageCell.configure(with: ((gallery?.images[indexPath.item])!)!)
            } else {
                imageCell.blank()
            }
            cell = imageCell
        }
        return cell
    }
    
    // MARK: - Collection View Navigation
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditing {
            trashCan.isEnabled = false
            if indexPath.item < (gallery?.images.count) ?? 0 {
                chosenImageToEnlarge = gallery?.images[indexPath.item]
                performSegue(withIdentifier: "Show Image", sender: self)
            }
        } else {
            trashCan.isEnabled = true
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if isEditing {
            let item = collectionView.cellForItem(at: indexPath)
            if item!.isSelected {
                collectionView.deselectItem(at: indexPath, animated: true)
                return false
            }
        }
        return true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ImageViewController {
            if segue.identifier == "Show Image" {
                destination.imageURL = chosenImageToEnlarge
            } else {
                return
            }
        }
    }
    
    // MARK: - Collection View Drag
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        dragItems(at: indexPath)
    }
    
    
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if indexPath.item < (self.gallery?.images.count)! {
            if let imageCell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
                if let image = (imageCell.cellView.subviews[1] as? UIImageView)?.image {
                    let dragItem = UIDragItem(itemProvider: NSItemProvider(object: image))
                    dragItem.localObject = (gallery?.images[indexPath.item], gallery?.aspectRatios[indexPath.item])
                    return [dragItem]
                }
            } else {
                return []
            }
        } else {
            return []
        }
        return []
    }
    
    // MARK: - Collection View Drop
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: isSelf ? .insertAtDestinationIndexPath : .insertIntoDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        if destinationIndexPath.item > (self.gallery?.images.count)! - 1 {
            return
        }
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                if let (url, aspectRatio) = item.dragItem.localObject as? (URL, Double) {
                    collectionView.performBatchUpdates( {
                        gallery?.images.remove(at: sourceIndexPath.item)
                        gallery?.aspectRatios.remove(at: sourceIndexPath.item)
                        gallery?.images.insert(contentsOf: [url], at: destinationIndexPath.item)
                        gallery?.aspectRatios.insert(contentsOf: [aspectRatio], at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath]) })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "Cell"))
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let url = provider as? URL {
                            placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                self.gallery?.images.insert(contentsOf: [url], at: insertionIndexPath.item)
                                collectionView.reloadData()
                            })
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        UIDropProposal(operation: .copy)
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSURL.self) { nsurls in
            if let url = nsurls.first as? URL {
                let urlContents = try? Data(contentsOf: url)
                if let imageFromUrl = UIImage(data: urlContents!) {
                    let aspectRatio = Double(imageFromUrl.size.width) / Double(imageFromUrl.size.height)
                    self.gallery?.images.append(url)
                    self.gallery?.aspectRatios.append(aspectRatio)
                    self.collectionView.reloadData()
                } else {
                    return
                }
            }
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView.allowsMultipleSelection = editing
        let indexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
            cell.isInEditingMode = editing
            cell.isSelected = false
        }
    }
}
