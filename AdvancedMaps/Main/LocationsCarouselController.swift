//
//  LocationsCarouselController.swift
//  AdvancedMaps
//
//  Created by Akbarshah Jumanazarov on 10/20/24.
//

import UIKit
import LBTATools

class LocationsCell: LBTAListCell<String> {
    override func setupViews() {
        backgroundColor = .red
        layer.cornerRadius = 8
        setupShadow()
    }
}

class LocationsCarouselController: LBTAListController<LocationsCell, String>, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width - 64, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        self.items = ["1", "2", "3"]
    }
}
