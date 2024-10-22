//
//  LocationsCarouselController.swift
//  AdvancedMaps
//
//  Created by Akbarshah Jumanazarov on 10/20/24.
//

import UIKit
import SwiftUI
import LBTATools
import MapKit

class LocationsCell: LBTAListCell<MKMapItem> {
    
    override var item: MKMapItem! {
        didSet {
            label.text = item.name
            addressLabel.text = item.address()
        }
    }
    
    let label = UILabel(text: "Location", font: .boldSystemFont(ofSize: 16))
    let addressLabel = UILabel(text: "Address", numberOfLines: 0)
    
    override func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 8
        setupShadow()
        stack(label, addressLabel).withMargins(.allSides(16))
    }
}

class LocationsCarouselController: LBTAListController<LocationsCell, MKMapItem> {
    
    weak var mainVC: MainViewController?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = self.items[indexPath.item]
        let annotations = mainVC?.mapView.annotations
        
        annotations?.forEach({ annotation in
            guard let customAnnotation = annotation as? CustomMapItemAnnotation else { return }
            
            if customAnnotation.mapItem?.name == selectedItem.name {
                mainVC?.mapView.selectAnnotation(annotation, animated: true)
            }
        })
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
    }
}

extension LocationsCarouselController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width - 64, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}

#Preview {
    MainViewControllerRepresentable()
        .ignoresSafeArea()
}
