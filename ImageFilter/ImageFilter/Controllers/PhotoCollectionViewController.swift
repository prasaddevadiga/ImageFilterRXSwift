
//
//  File.swift
//  ImageFilter
//
//  Created by Prasad on 5/9/20.
//  Copyright © 2020 Prasad. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Photos


class PhotoCollectionViewController: UICollectionViewController {
    
    private var disposeBag = DisposeBag()
    
    private var selectedPhotoSubject = PublishSubject<UIImage>()
    var selectedPhoto: Observable<UIImage> {
        return selectedPhotoSubject.asObservable()
    }
    
    private var imageList = BehaviorRelay<[PHAsset]>(value: [])
    var photoList: Observable<[PHAsset]> {
        return imageList.asObservable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = nil
        self.collectionView.dataSource = nil
        populatePhotos()
        photoList.bind(to: self.collectionView.rx.items(cellIdentifier: "PhotoCollectionViewCell", cellType: PhotoCollectionViewCell.self)) { row, data, cell in
            PHImageManager.default().requestImage(for: data,
                                                  targetSize: CGSize(width: 100, height: 100),
                                                  contentMode: .aspectFit, options: nil) { image, error in
                                                    DispatchQueue.main.async {
                                                        cell.photoImageView.image = image
                                                    }
            }
        }.disposed(by: disposeBag)
        
        self.collectionView.rx.itemSelected.subscribe( onNext: { indexPath in
            PHImageManager.default().requestImage(for: self.imageList.value[indexPath.row],
                                                  targetSize: CGSize(width: 100, height: 100),
                                                  contentMode: .aspectFit, options: nil) { image, info in
                                                    DispatchQueue.main.async {
                                                        if let image = image {
                                                            self.selectedPhotoSubject.onNext(image)
                                                            self.dismiss(animated: true, completion: nil)
                                                        }
                                                    }
            }
        }).disposed(by: disposeBag)
    }
    
    private func populatePhotos() {
        PHPhotoLibrary.requestAuthorization { [weak self] authorizationStatus in
            if authorizationStatus == .authorized {
                let assets = PHAsset.fetchAssets(with: .image, options: nil)
                var imageList = [PHAsset]()
                assets.enumerateObjects { (object, count, stop) in
                    imageList.append(object)
                }
                imageList.reverse()
                
                self?.imageList.accept(imageList)
                
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
    }
}
