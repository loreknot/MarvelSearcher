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
    var heroInfo: [HeroDisplayInfo] = []
    
    var numberOfSections: Int {
           return self.heroInfo.count
       }
    
    
}
