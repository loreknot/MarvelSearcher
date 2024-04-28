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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
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
        backgroundColor = info.favorite ? .gray : .white
    }
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
            self.downloadImage(url: url) { [weak self] image in
                self?.imageView.image = image
            }
    }
    
    func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let image = UIImage(data: data)
                
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
        task.resume()
    }
    
}
