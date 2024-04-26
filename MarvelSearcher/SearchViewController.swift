//
//  ViewController.swift
//  MarvelSearcher
//
//  Created by subError on 4/25/24.
//

import UIKit

class SearchViewController: UIViewController {

    let marvelNet = MarvelNet()
    let marvelData = MarvelData.shared
    
    let sectionInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    let minimumCellSpacing: CGFloat = 20
    let itemsPerRow: CGFloat = 2
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var heroCollectionView: UICollectionView!

    
    // MARK: - ViewCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
       print("서치뷰 로드 완료")
        marvelNet.getMarvelInfo(name: "") { [weak self] (info) in
            guard let self = self else { return }
            
            self.marvelData.heroInfo = info
            
            DispatchQueue.main.async {
                self.heroCollectionView.reloadData()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
    }
}

// MARK: - CollectionView

extension SearchViewController:  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return marvelData.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeroCell", for: indexPath) as! HeroCell
        let heroInfo = marvelData.heroInfo[indexPath.row]

        cell.configCell(info: heroInfo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    
}


