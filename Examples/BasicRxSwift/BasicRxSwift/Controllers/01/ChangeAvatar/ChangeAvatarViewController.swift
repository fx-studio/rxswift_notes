//
//  ChangeAvatarViewController.swift
//  BasicRxSwift
//
//  Created by Le Phuong Tien on 8/17/20.
//  Copyright © 2020 Fx Studio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ChangeAvatarViewController: UIViewController {
    
    // MARK : Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Properties
    var selectIndex = -1
    private let bag = DisposeBag()
    
    private let selectedPhotosSubject = PublishSubject<UIImage>()
    var selectedPhotos: Observable<UIImage> {
        return selectedPhotosSubject.asObservable()
    }
    
    // MARK : Life cycle
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        selectedPhotosSubject.onCompleted()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Avatars"
        
        let nib = UINib(nibName: "AvatarCell", bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}

extension ChangeAvatarViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width - 30
        return CGSize(width: screenWidth/3, height: screenWidth/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AvatarCell
        
        let image = UIImage(named: "avatar_\(indexPath.row + 1)")
        cell.thumbnailImageView.image = image
        
        if indexPath.row == selectIndex {
            cell.backgroundColor = .blue
        } else {
            cell.backgroundColor = .gray
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectIndex = indexPath.row
        collectionView.reloadData()
        
        //emit UIImage
        if let image = UIImage(named: "avatar_\(indexPath.row + 1)") {
            selectedPhotosSubject.onNext(image)
        }
    }
    
}
