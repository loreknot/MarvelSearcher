//
//  MavelNet.swift
//  MarvelSearcher
//
//  Created by subError on 4/25/24.
//

import Foundation
import CommonCrypto

class MarvelNet {
    var searchTask: URLSessionDataTask?
    let session = URLSession.shared
    var searchWorkItem: DispatchWorkItem?
    var pageCount = 0
    
    // MARK: - Function
    
    func md5(_ string: String) -> String {
        let data = Data(string.utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    func makeRequestUrl(name: String?) -> String {
        let publicKey = Constants.publicKey
        let privateKey = Constants.privateKey
        let ts = "\(Date().timeIntervalSince1970)"
        
        let hash = md5(ts + privateKey + publicKey)
        let mainUrl = "\(Constants.mainUrl):443/v1/public/"
        var parameters = "characters?ts=\(ts)"
        
        if let name = name, !name.isEmpty {
            parameters += "&nameStartsWith=\(name)"
        }
        
        parameters += "&limit=10&offset=\(10 * pageCount)"
        
        let auth = "&apikey=\(publicKey)&hash=\(hash)"
        let url =  mainUrl + parameters + auth
        return url
    }
    
    func getMarvelInfo(name: String, completion: @escaping ([IndexPath]?) -> Void) {
        searchTask?.cancel()
        searchWorkItem?.cancel()
        
        let workItem = DispatchWorkItem {
           
            let url = self.makeRequestUrl(name: name)
            guard let url = URL(string: url) else { return }
            
            self.searchTask = self.session.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }

                if let error = error as? URLError, error.code == .cancelled {
                    print("Request was cancelled")
                    return
                }
                
                guard let data = data, error == nil else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                do {
                    let heroData = try JSONDecoder().decode(HeroData.self, from: data)
                    var displayInfo = heroData.data.results.map { $0.toDisplayInfo() }
                    self.updateFavorite(displayInfo: &displayInfo)
                 
                    let existingCount = MarvelData.shared.heroInfo.count
                    MarvelData.shared.heroInfo.append(contentsOf: displayInfo)
                    let newCount = MarvelData.shared.heroInfo.count
                    
                    let indexPaths = (existingCount..<newCount).map { IndexPath(row: $0, section: 0) }
                    completion(indexPaths)
                    
                } catch {
                    print("Error decoding data: \(error)")
                    completion(nil)
                }
            }
            
            self.searchTask?.resume()
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3, execute: workItem)
        searchWorkItem = workItem
    }
    
    func updateFavorite(displayInfo: inout [HeroDisplayInfo]) {
        let favorite = FavoriteData.shared.loadFavorite()
        let favoriteName = favorite.compactMap { $0.name }
        
        displayInfo.indices.forEach { index in
            if let name = displayInfo[index].name, favoriteName.contains(name) {
                displayInfo[index].favorite = true
            }
        }
    }
    
    func prettyPrintJSON(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            if let prettyPrintedString = String(data: prettyData, encoding: .utf8) {
                print(prettyPrintedString)
            } else {
                print("Invalid response")
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
}



