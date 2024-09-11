import UIKit

typealias ProductSnapshot = NSDiffableDataSourceSnapshot<Int, Product>

class ProductDataSource: UICollectionViewDiffableDataSource<Int, Product> {
    func updateData(
        with products: [Product],
        animatingDifferences: Bool = true
    ) {
        var snapshot = ProductSnapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(products)
        apply(snapshot, 
              animatingDifferences: animatingDifferences)
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        canMoveItemAt indexPath: IndexPath
    ) -> Bool {
        return true
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        moveItemAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        // Update the data source
        var currentSnapshot = snapshot()
        let movedItem = currentSnapshot.itemIdentifiers[sourceIndexPath.item]
        currentSnapshot.deleteItems([movedItem])
        
        if destinationIndexPath.item >= currentSnapshot.itemIdentifiers.count {
            currentSnapshot.appendItems([movedItem])
        } else {
            currentSnapshot.insertItems([movedItem], beforeItem: currentSnapshot.itemIdentifiers[destinationIndexPath.item])
        }
        
        apply(currentSnapshot, animatingDifferences: true)
    }
}

