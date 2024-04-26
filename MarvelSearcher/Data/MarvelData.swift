//
//  MarvelInfo.swift
//  MarvelSearcher
//
//  Created by subError on 4/25/24.
//

import Foundation

class MarvelData {
    private init() {}
    
    static var shared = MarvelData()
    let marvelNet = MarvelNet()
    
    var heroInfo: [HeroDisplayInfo] = []
    
    var heroName = ""
    var isLoading: ((Bool) -> Void)?
    var reloadData: (([HeroDisplayInfo]) -> Void)?
    
    var numberOfSections: Int {
        return self.heroInfo.count
    }
    
    // MARK: - func
    func getMarvelInfo(name: String, completion: @escaping ([IndexPath]?) -> Void) {
        isLoading?(true)
        
        if heroName != name {
            marvelNet.pageCount = 0
        } else {
            marvelNet.pageCount += 1
        }
        
        marvelNet.getMarvelInfo(name: name) { (indexPath) in
            self.isLoading?(false)
            completion(indexPath)
        }
    }
    
    
   
}
