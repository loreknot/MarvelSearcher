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
    
    //MARK: - Function
    
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
}
