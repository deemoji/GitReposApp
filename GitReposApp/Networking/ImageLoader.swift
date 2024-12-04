//
//  ImageLoader.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 05.12.2024.
//

import Foundation
import UIKit

protocol ImageLoader {
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void)
}

final class ImageLoaderImpl: ImageLoader {
    
    private let cache = NSCache<NSString, UIImage>()
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            self.cache.setObject(image, forKey: urlString as NSString)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
        
    }
}

