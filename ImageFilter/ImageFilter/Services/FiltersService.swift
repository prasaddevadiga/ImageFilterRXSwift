//
//  FilterService.swift
//  ImageFilter
//
//  Created by Prasad on 5/9/20.
//  Copyright © 2020 Prasad. All rights reserved.
//

import UIKit
import CoreImage
import RxSwift

class FiltersService: NSObject {
    var context: CIContext
    override init() {
        context = CIContext()
    }
    
    func applyFilter(inputImage: UIImage) -> Observable<UIImage> {
        return Observable<UIImage>.create { observer in
            self.applyFilter(inputImage: inputImage) { image in
                observer.onNext(image)
            }
            return Disposables.create()
        }
    }
    
    private func applyFilter(inputImage: UIImage, completion: @escaping (UIImage) -> Void) {
        guard let filter = CIFilter(name: "CICMYKHalftone") else { return }
        filter.setValue(5.0, forKey: kCIInputWidthKey)
        guard let sourceImage = CIImage(image: inputImage) else { return }
        filter.setValue(sourceImage, forKey: kCIInputImageKey)
        
        if let cgImage = self.context.createCGImage(filter.outputImage! , from: filter.outputImage?.extent ?? CGRect.zero) {
            let processedImage = UIImage(cgImage: cgImage, scale: inputImage.scale, orientation: inputImage.imageOrientation)
            completion(processedImage)
        }
    }
}
