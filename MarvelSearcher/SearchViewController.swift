import UIKit

class SearchViewController: UIViewController {

    let marvelData = MarvelData.shared
    let faveData = FavoriteData.shared
    
    let sectionInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    let minimumCellSpacing: CGFloat = 20
    let itemsPerRow: CGFloat = 2
    
    var activityIndicator: UIActivityIndicatorView!
    var footerActivityIndicator: UIActivityIndicatorView!
    
    var isLoading = false
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var heroCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var emptyLabel: UILabel!
    
    // MARK: - ViewCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heroCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        
        setIndicator()
        setBinding()
        
        marvelData.getMarvelInfo(name: "")
    }
    
    // MARK: - Function
    
    func setIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        footerActivityIndicator = UIActivityIndicatorView(style: .medium)
        footerActivityIndicator.frame = CGRect(x: 0, y: 0, width: heroCollectionView.bounds.width, height: 50)
        footerActivityIndicator.hidesWhenStopped = true
    }
    
    func setBinding() {
        
        marvelData.isLoading = { [weak self] (loading) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if loading {
                    self.activityIndicator.startAnimating()
                    self.emptyLabel.isHidden = true
                } else {
                    self.activityIndicator.stopAnimating()
                    self.heroCollectionView.reloadData()
                    
                    guard !self.marvelData.heroInfo.isEmpty else { return }
                    let indexPath = IndexPath(item: 0, section: 0)
                    self.heroCollectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                }
            }
        }
        
        marvelData.isMoreData = { [weak self] (isMoreData) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if isMoreData {
                    self.isLoading = true
                    self.footerActivityIndicator.startAnimating()
                } else {
                    self.footerActivityIndicator.stopAnimating()
                    self.isLoading = false
                    if let indexPath = self.marvelData.newIndexPath, !indexPath.isEmpty  {
                        self.heroCollectionView.insertItems(at: indexPath)
                    }
                }
            }
        }
        
        marvelData.updateCellUI = { [weak self] (indexPath) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.heroCollectionView.reloadItems(at: [indexPath])
            }
        }
    }
}

// MARK: - SearchView
extension SearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let name = searchBar.text, name.count > 1, name != marvelData.currentHeroName else { return }
        marvelData.getMarvelInfo(name: name)
    }
    
    func dismissKeyboard() {
          searchBar.resignFirstResponder()
      }
}

// MARK: - CollectionView

extension SearchViewController:  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        emptyLabel.isHidden = marvelData.numberOfSections != 0
        return marvelData.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeroCell", for: indexPath) as! HeroCell
        let heroInfo = marvelData.heroInfo[indexPath.row]
        
        cell.configCell(info: heroInfo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        marvelData.updateFavoriteState(index: indexPath.row)
        faveData.updateFavoriteData(info: marvelData.heroInfo[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
            footer.addSubview(footerActivityIndicator)
            footerActivityIndicator.center = CGPoint(x: footer.bounds.midX, y: footer.bounds.midY)
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


// MARK: - Scroll
extension SearchViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        if offsetY > contentHeight - height - 100 && scrollView.isDragging {
            guard !isLoading else { return }
            marvelData.loadMoreMarvelInfo()
        }
    }
}
