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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupDataSource()
        setupDragAndDrop()
        loadData()
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: createLayout()
        )
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            ProductCell.self,
            forCellWithReuseIdentifier: ProductCell.reuseIdentifier
        ) // Updated to ProductCell
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
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
    
    private func setupDragAndDrop() {
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true
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
            )
        ]
        
        dataSource.updateData(with: products)
    }
}

extension ViewController: SwipeCollectionViewCellDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        itemsForBeginning session: UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        let item = products[indexPath.item]
        let itemProvider = NSItemProvider(object: item.id.uuidString as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(
                operation: .move,
                intent: .insertAtDestinationIndexPath
            )
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        performDropWith coordinator: UICollectionViewDropCoordinator
    ) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }

        for item in coordinator.items {
            guard let sourceIndexPath = item.sourceIndexPath else { continue }
            
            print("sourceIndexPath: \(sourceIndexPath)")
            // Reorder the data source immediately
            let movedItem = products.remove(at: sourceIndexPath.item)
            products.insert(movedItem, at: destinationIndexPath.item)
        }

        // Update the data source with a single update
        dataSource.updateData(with: products,
                              animatingDifferences: false)
    }
}


