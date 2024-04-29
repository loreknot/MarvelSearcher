//
//  MarvelInfo.swift
//  MarvelSearcher
//
//  Created by subError on 4/25/24.
//

import Foundation

class MarvelData {

    static var shared = MarvelData()
    let marvelNet = MarvelNet()
    
    var heroInfo: [HeroDisplayInfo] = []
    var currentHeroName = ""
    var newIndexPath: [IndexPath]?
    
    var isLoading: ((Bool) -> Void)?
    var isMoreData: ((Bool) -> Void)?
    var updateCellUI: ((IndexPath) -> Void)?
    
    var numberOfSections: Int {
        return self.heroInfo.count
    }
    
    // MARK: - Function
    func getMarvelInfo(name: String) { 
        isLoading?(true)
        marvelNet.pageCount = 0
        currentHeroName = name
        heroInfo.removeAll()
        
        marvelNet.getMarvelInfo(name: name) { [weak self] _ in
            guard let self = self else { return }
            self.isLoading?(false)
        }
    }
    
    func loadMoreMarvelInfo() {
        marvelNet.pageCount += 1
        isMoreData?(true)
        marvelNet.getMarvelInfo(name: currentHeroName) { [weak self] (indexPath) in
            guard let self = self else { return }
            self.isMoreData?(false)
            self.newIndexPath = indexPath
        }
    }
    
    func updateFavoriteState(index: Int) {
         guard heroInfo.indices.contains(index) else { return }
         heroInfo[index].favorite.toggle()
        
         updateCellUI?(IndexPath(row: index, section: 0))
     }
    
    
    func checkRemoveFavorite(name: String) {
        if let index = heroInfo.firstIndex(where: { $0.name == name }) {
            heroInfo[index].favorite = false
            
            updateCellUI?( IndexPath(row: index, section: 0))
        }
    }
    
   
}
