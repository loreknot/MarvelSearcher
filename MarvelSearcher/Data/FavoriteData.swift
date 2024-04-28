//
//  Favorite.swift
//  MarvelSearcher
//
//  Created by subError on 4/25/24.
//

import Foundation

class FavoriteData {
    static let shared = FavoriteData()
    
    let favoriteKey = "favorite"
    var favoriteInfo: [HeroDisplayInfo] = []
    
    var numberOfSections: Int {
        return self.favoriteInfo.count
    }
    
    //MARK: - Function
    init() {
        self.favoriteInfo = loadFavorite()
    }
    
    func saveFavorite(favorite: [HeroDisplayInfo]) {
        if let encoded = try? JSONEncoder().encode(favorite) {
            UserDefaults.standard.set(encoded, forKey: favoriteKey)
        }
    }
    
    func loadFavorite() -> [HeroDisplayInfo] {
        if let savedFavorite = UserDefaults.standard.object(forKey: favoriteKey) as? Data {
            if let loadedFavorites = try? JSONDecoder().decode([HeroDisplayInfo].self, from: savedFavorite) {
                return loadedFavorites
            }
        }
        return []
    }
    
    func updateFavoriteData(info: HeroDisplayInfo) {
        var favorite = FavoriteData.shared.loadFavorite()
        if let index = favorite.firstIndex(where: { $0.name == info.name }) {
            
            if let name = info.name {
                MarvelData.shared.checkRemoveFavorite(name: name)
            }
            favorite.remove(at: index)
        } else {
            favorite.append(info)
            if favorite.count > 5 {
                
                if let name = favorite.first?.name {
                    MarvelData.shared.checkRemoveFavorite(name: name)
                }
                favorite.removeFirst()
            }
        }
        FavoriteData.shared.saveFavorite(favorite: favorite)
        self.favoriteInfo = loadFavorite()
    }
    
    func updateFavoriteState(index: Int, completion: @escaping () -> Void) {
        updateFavoriteData(info: self.favoriteInfo[index])
        completion()
    }
}
