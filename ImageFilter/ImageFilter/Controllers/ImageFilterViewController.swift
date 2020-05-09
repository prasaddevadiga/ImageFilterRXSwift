//
//  ImageFilterViewController.swift
//  ImageFilter
//
//  Created by Prasad on 5/9/20.
//  Copyright © 2020 Prasad. All rights reserved.
//

import UIKit
import RxSwift

class ImageFilterViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationVC = segue.destination as? UINavigationController,
            let photoCollectionVC = navigationVC.viewControllers.first as? PhotoCollectionViewController else {
            return
        }
        photoCollectionVC.selectedPhoto.bind(to: self.imageView.rx.image).disposed(by: disposeBag)
    }
    
    @IBAction func applyFilter(_ sender: Any) {
        guard let image = imageView.image else { return }
        FiltersService().applyFilter(inputImage: image).bind(to: self.imageView.rx.image).disposed(by: disposeBag)        
    }
}
