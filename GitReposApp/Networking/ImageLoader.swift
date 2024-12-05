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
    private let queue: OperationQueue
    
    init() {
        self.queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
    }
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        queue.addOperation {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
                
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                
            }
        }
    }
    
}


