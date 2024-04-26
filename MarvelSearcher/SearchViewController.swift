//
//  ViewController.swift
//  MarvelSearcher
//
//  Created by subError on 4/25/24.
//

import UIKit

class SearchViewController: UIViewController {

    let marvelData = MarvelData.shared
    
    let sectionInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    let minimumCellSpacing: CGFloat = 20
    let itemsPerRow: CGFloat = 2
    
    var activityIndicator: UIActivityIndicatorView!
    var footerActivityIndicator: UIActivityIndicatorView!

    var isLoadingData = false
    var isRefreshing = false
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var heroCollectionView: UICollectionView!

    
    // MARK: - ViewCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heroCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        
        setActivityIndicator()
        setFooterActivityIndicator()
        setBindings()
        initHeroData()
    }
    
    // MARK: - fucn
    
    func initHeroData() {
        if isLoadingData { return }
        isLoadingData = true
        isRefreshing = true
        
        marvelData.getMarvelInfo(name: "") { indexPaths in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.isLoadingData = false
                self.isRefreshing = false
                self.heroCollectionView.reloadData()
            }
        }
    }
    
    func setActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func setFooterActivityIndicator() {
         footerActivityIndicator = UIActivityIndicatorView(style: .medium)
         footerActivityIndicator.frame = CGRect(x: 0, y: 0, width: heroCollectionView.bounds.width, height: 50)
         footerActivityIndicator.hidesWhenStopped = true
     }
    
    func setBindings() {
        marvelData.isLoading = { [weak self] loading in
            DispatchQueue.main.async {
                if loading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
            footer.addSubview(footerActivityIndicator)
            footerActivityIndicator.center = CGPoint(x: footer.bounds.midX, y: footer.bounds.midY)
            footerActivityIndicator.isHidden = !isLoadingData || isRefreshing
            return footer
        }
        return UICollectionReusableView()
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


extension SearchViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        activityIndicator.isHidden = true
        // 하단에 거의 도달했는지 확인
        if offsetY > contentHeight - height - 100 {
            loadMoreData()
        }
    }
    
    func loadMoreData() {
            if isLoadingData { return }
            
            isLoadingData = true
            DispatchQueue.main.async {
                if !self.isRefreshing {
                    self.footerActivityIndicator.startAnimating()
                }
            }

            marvelData.getMarvelInfo(name: marvelData.heroName) { indexPaths in
                DispatchQueue.main.async {
                    self.footerActivityIndicator.stopAnimating()
                    if let indexPaths = indexPaths {
                        self.heroCollectionView.insertItems(at: indexPaths)
                    }
                    self.isLoadingData = false
                }
            }
        }
}


