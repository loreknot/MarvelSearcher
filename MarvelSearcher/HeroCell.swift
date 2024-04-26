//
//  heroCollectionViewCell.swift
//  MarvelSearcher
//
//  Created by subError on 4/26/24.
//

import UIKit

class HeroCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setBorders()
    }
    
    func setBorders() {
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 1 / UIScreen.main.scale
    }
    
    func configCell(info: HeroDisplayInfo) {
        guard let url = info.imageUrl else { return }
        
        loadImage(from: url)
        nameLabel.text = info.name
        descLabel.text = info.description
    }
    
    func loadImage(from urlString: String) {
         guard let url = URL(string: urlString) else { return }

         let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
             guard let data = data, error == nil else {
                 print("Error downloading image: \(error?.localizedDescription ?? "No error")")
                 return
             }
             DispatchQueue.main.async {
                 self?.imageView.image = UIImage(data: data)
             }
         }
         task.resume()
     }
}
