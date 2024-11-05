//
//  LocationSearchController.swift
//  AdvancedMaps
//
//  Created by Akbarshah Jumanazarov on 10/22/24.
//

import UIKit
import SwiftUI
import LBTATools
import MapKit

class LocationSearchCell: LBTAListCell<MKMapItem> {
    
    override var item: MKMapItem! {
        didSet {
            nameLabel.text = item.name
            addressLabel.text = item.address()
        }
    }
    
    let nameLabel = UILabel(text: "Name", font: .boldSystemFont(ofSize: 16))
    let addressLabel = UILabel(text: "Address", font: .systemFont(ofSize: 16))
    
    override func setupViews() {
        stack(nameLabel, addressLabel).withMargins(.allSides(16))
        addSeparatorView(leftPadding: 16)
    }
}

class LocationSearchController: LBTAListController<LocationSearchCell, MKMapItem> {
    
    var selectionHandler: ((MKMapItem) -> ())?
    
    let searchTextField = IndentedTextField(placeholder: "Search", padding: 12)
    let backButton = UIButton()
    
    let navBarHeight: CGFloat = 66
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
    }
    
    fileprivate func setupSearchBar() {
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(didPressBackButton), for: .touchUpInside)
        backButton.constrainWidth(20)
        
        let navBar = UIView(backgroundColor: .white)
        view.addSubview(navBar)
        navBar.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -navBarHeight, right: 0))
        
        collectionView.verticalScrollIndicatorInsets.top = navBarHeight
        
        let container = UIView(backgroundColor: .white)
        navBar.addSubview(container)
        container.fillSuperviewSafeAreaLayoutGuide()
        container.hstack(backButton, searchTextField, spacing: 12)
            .withMargins(.init(top: 0, left: 16, bottom: 16, right: 16))
        searchTextField.layer.borderColor = UIColor.black.cgColor
        searchTextField.layer.borderWidth = 2
        searchTextField.layer.cornerRadius = 5
        
        setupSearchListener()
    }
    
    @objc
    fileprivate func didPressBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupSearchListener() {
        _ = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                self?.performLocalSearch()
            })
    }
    
    fileprivate func performLocalSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTextField.text
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response else {
                print("Empty response")
                return
            }
            self.items = response.mapItems
        }
    }
}

extension LocationSearchController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 70)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        let item = self.items[indexPath.row]
        selectionHandler?(item)
    }
}


























#Preview(body: {
    LocationSearchControllerRepresentable()
        .ignoresSafeArea()
})

struct LocationSearchControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return LocationSearchController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
