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
        apply(snapshot, animatingDifferences: animatingDifferences)
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
        guard var snapshot = self.snapshot() as ProductSnapshot?,
              let sourceItem = itemIdentifier(for: sourceIndexPath) else {
            return
        }

        snapshot.deleteItems([sourceItem])
        
        if let destinationItem = itemIdentifier(for: destinationIndexPath) {
            if destinationIndexPath.item > sourceIndexPath.item {
                snapshot.insertItems([sourceItem], afterItem: destinationItem)
            } else {
                snapshot.insertItems([sourceItem], beforeItem: destinationItem)
            }
        } else {
            snapshot.appendItems([sourceItem], toSection: 0)
        }

        apply(snapshot, animatingDifferences: false)
    }
}

