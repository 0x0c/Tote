//
//  GalleryViewController.swift
//  Tote
//
//  Created by Brian Michel on 6/22/19.
//  Copyright © 2019 Brian Michel. All rights reserved.
//

import UIKit

protocol GalleryViewControllerDelegate: AnyObject {
    func galleryViewController(contorller: GalleryViewController, didRequestDetailsFor mediaGroup: MediaGroup, in cell: GalleryCollectionViewCell)
}

final class GalleryViewController: UIViewController,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDelegate,
    UICollectionViewDataSource {
    private enum Constants {
        static let interitemSpacing: CGFloat = 5
        static let lineSpacing: CGFloat = 5
        static let columns: CGFloat = 2
        static let contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    }

    weak var delegate: GalleryViewControllerDelegate?

    private let collectionView: UICollectionView

    var folder: Folder? {
        didSet {
            collectionView.reloadData()
        }
    }

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Constants.interitemSpacing
        layout.minimumLineSpacing = Constants.lineSpacing

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)

        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: GalleryCollectionViewCell.identifier)

        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.contentInset = Constants.contentInset

        navigationItem.largeTitleDisplayMode = .always

        title = "Tote"
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hack to make the large header not collapse
        view.addSubview(UIView())
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        collectionView.reloadData()
    }

    // MARK: - UICollectionView DataSource / Delegate

    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        guard let folder = folder else {
            return 0
        }

        return folder.groups.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.identifier,
                                                          for: indexPath) as? GalleryCollectionViewCell,
            let group = self.folder?.groups[indexPath.item] else {
            return UICollectionViewCell()
        }

        cell.imageURL = group.thumbnailURL()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout _: UICollectionViewLayout,
                        sizeForItemAt _: IndexPath) -> CGSize {
        let widthSquare = (collectionView.bounds.width -
            (Constants.contentInset.left + Constants.contentInset.right +
                (Constants.columns * Constants.interitemSpacing)
            )
        ) / Constants.columns

        return CGSize(width: widthSquare, height: widthSquare)
    }

    func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard
            let group = self.folder?.groups[indexPath.item],
            let collectionViewCell = cell as? GalleryCollectionViewCell else {
            return
        }
        delegate?.galleryViewController(contorller: self, didRequestDetailsFor: group, in: collectionViewCell)
    }
}
