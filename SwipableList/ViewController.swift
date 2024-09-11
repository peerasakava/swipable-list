//
//  ViewController.swift
//  SwipableList
//
//  Created by Peerasak Unsakon on 11/9/2567 BE.
//

import UIKit
import SwipeCellKit

class ViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var dataSource: ProductDataSource!
    private var products: [Product] = []
    var draggingCell: ProductCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupDataSource()
        setupLongPressGesture()
        loadData()
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(
            frame: .zero, // Change frame to .zero for Auto Layout
            collectionViewLayout: createLayout()
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            ProductCell.self,
            forCellWithReuseIdentifier: ProductCell.reuseIdentifier
        )
        collectionView.dragInteractionEnabled = true
        
        view.addSubview(collectionView)
        
        // Set constraints
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func setupDataSource() {
        dataSource = ProductDataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] (
                collectionView,
                indexPath,
                product
            ) -> UICollectionViewCell? in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ProductCell.reuseIdentifier,
                    for: indexPath
                ) as? ProductCell else { // Updated to ProductCell
                    fatalError("Unable to dequeue ProductCell")
                }
                cell.delegate = self
                cell.configure(with: product)
                return cell
            }
        )
    }
    
    private func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, 
                                                            action: #selector(handleLongPressGesture(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)),
            let cell = collectionView.cellForItem(at: selectedIndexPath) as? ProductCell else { return }
            
            let snapshot = customSnapshotFromCell(cell)
            
            draggingCell = cell
            cell.isHidden = true
            cell.alpha = 0.0
            cell.accessibilityValue = "Dragging"
            cell.nameLabel.textColor = .red
            
            var center = cell.center
            snapshot.center = center
            snapshot.alpha = 1.0
            collectionView.addSubview(snapshot)
            
            UIView.animate(withDuration: 0.25, animations: {
                snapshot.alpha = 0.85
                center.y = gesture.location(in: self.collectionView).y
                snapshot.center = center
            }) { _ in
                //cell.isHidden = true
            }
            
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            guard
                let snapshot = collectionView.subviews.last
            else { return }
            
            var center = snapshot.center
            center.y = gesture.location(in: collectionView).y
            snapshot.center = center
            
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            guard
                let draggingCell,
                let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)),
                let snapshot = collectionView.subviews.last
            else { return }
            
            let min: CGFloat = (100.0 / 2.0)
            let cal: CGFloat = (100.0 * CGFloat(selectedIndexPath.item)) + (100.0 / 2.0)
            let nextCenterY: CGFloat = max(cal, min)

            
            UIView.animate(withDuration: 0.37, animations: {
                snapshot.center.y = nextCenterY
            }) { _ in
                snapshot.removeFromSuperview()
                draggingCell.isHidden = false
                draggingCell.alpha = 1.0
            }
            
            draggingCell.nameLabel.textColor = .white
            collectionView.endInteractiveMovement()
        default:
            break
        }
    }

    private func customSnapshotFromCell(_ cell: UICollectionViewCell) -> UIView {
        UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0.0)
        cell.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.4
    
        return snapshot
    }
    
    private func loadData() {
        products = [
            Product(
                name: "iPhone 12",
                price: 799.99,
                description: "The latest iPhone with 5G capabilities"
            ),
            Product(
                name: "MacBook Air",
                price: 999.99,
                description: "Thin and light laptop with M1 chip"
            ),
            Product(
                name: "AirPods Pro",
                price: 249.99,
                description: "Wireless earbuds with active noise cancellation"
            ),
            Product(
                name: "iPad Air",
                price: 599.99,
                description: "Powerful tablet with A14 Bionic chip"
            ),
            Product(
                name: "Apple Watch Series 6",
                price: 399.99,
                description: "Advanced health and fitness companion"
            ),
            // New products added
            Product(
                name: "iPhone 13",
                price: 899.99,
                description: "The latest iPhone with improved camera"
            ),
            Product(
                name: "MacBook Pro",
                price: 1299.99,
                description: "High-performance laptop for professionals"
            ),
            Product(
                name: "AirPods Max",
                price: 549.99,
                description: "Premium over-ear headphones"
            ),
            Product(
                name: "iPad Pro",
                price: 1099.99,
                description: "Powerful tablet for creative professionals"
            ),
            Product(
                name: "Apple Watch SE",
                price: 279.99,
                description: "Affordable smartwatch with essential features"
            ),
            Product(
                name: "HomePod mini",
                price: 99.99,
                description: "Compact smart speaker with great sound"
            ),
            Product(
                name: "Apple TV 4K",
                price: 179.99,
                description: "Streaming device with 4K HDR support"
            ),
            Product(
                name: "Magic Keyboard",
                price: 99.99,
                description: "Wireless keyboard with a sleek design"
            ),
            Product(
                name: "Magic Mouse",
                price: 79.99,
                description: "Wireless mouse with multi-touch surface"
            ),
            Product(
                name: "AirTag",
                price: 29.99,
                description: "Item tracker to keep track of your belongings"
            ),
            Product(
                name: "Apple Pencil (2nd generation)",
                price: 129.99,
                description: "Precision stylus for iPad"
            )
        ]
        
        dataSource.updateData(with: products)
    }
}

extension ViewController: SwipeCollectionViewCellDelegate  {
    func collectionView(
        _ collectionView: UICollectionView,
        editActionsForItemAt indexPath: IndexPath,
        for orientation: SwipeActionsOrientation
    ) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let editAction = SwipeAction(
            style: .default,
            title: "Edit"
        ) { action, indexPath in
            // Handle edit action
            print("Edit item at index \(indexPath.item)")
        }
        editAction.backgroundColor = .systemBlue
        
        let deleteAction = SwipeAction(
            style: .destructive,
            title: "Remove"
        ) { [weak self] action, indexPath in
            // Handle delete action
            self?.products.remove(at: indexPath.item)
            self?.dataSource.updateData(with: self?.products ?? [])
        }
        
        return [deleteAction, editAction]
    }
}


