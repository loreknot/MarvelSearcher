//
//  FaveViewController.swift
//  MarvelSearcher
//
//  Created by subError on 4/26/24.
//

import UIKit

class FaveViewController: UIViewController {
    
    let sectionInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    let minimumCellSpacing: CGFloat = 20
    let itemsPerRow: CGFloat = 2
    
    let faveData = FavoriteData.shared
  
    
    // MARK: - IBOutlet
    @IBOutlet weak var faveCollectionView: UICollectionView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    // MARK: - ViewCycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        self.faveCollectionView.reloadData()
    }

    
    // MARK: - Function
        
}

// MARK: - CollectionView

extension FaveViewController:  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = faveData.numberOfSections
        emptyLabel.isHidden = count != 0
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeroCell", for: indexPath) as! HeroCell
        let heroInfo = faveData.favoriteInfo[indexPath.row]
        
        cell.configCell(info: heroInfo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        faveData.updateFavoriteState(index: indexPath.row) {
            self.faveCollectionView.performBatchUpdates({
                 collectionView.deleteItems(at: [indexPath])
             }, completion: nil)
        }
        
    }
    
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left + sectionInsets.right
        let availableWidth = collectionView.frame.width - paddingSpace - minimumCellSpacing
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height:  widthPerItem * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumCellSpacing
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
}


