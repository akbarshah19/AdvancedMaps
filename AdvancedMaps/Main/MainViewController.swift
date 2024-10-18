//
//  MainViewController.swift
//  AdvancedMaps
//
//  Created by Akbarshah Jumanazarov on 10/14/24.
//

import UIKit
import SwiftUI
import MapKit
import LBTATools

class MainViewController: UIViewController {
    
    let mapView = MKMapView()
    let searchTextField = UITextField(placeholder: "Search")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.fillSuperview()
        setupRegion()
//        setupMapAnnotations()
        Task {
            await performLocalSearch()
        }
        
        setupSearchUI()
        setupLocationsCarousel()
    }
    
    fileprivate func setupRegion() {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    fileprivate func setupMapAnnotations() {
        let sfAnnotation = MKPointAnnotation()
        sfAnnotation.coordinate = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
        sfAnnotation.title = "San Francisco"
        sfAnnotation.subtitle = "CA"
        mapView.addAnnotation(sfAnnotation)
        
        let acAnnotation = MKPointAnnotation()
        acAnnotation.coordinate = CLLocationCoordinate2D(latitude: 37.3326, longitude: -122.030024)
        acAnnotation.title = "Apple Campus"
        acAnnotation.subtitle = "CA"
        mapView.addAnnotation(acAnnotation)
        
        mapView.showAnnotations(self.mapView.annotations, animated: true)
    }
    
    fileprivate func performLocalSearch() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTextField.text
        request.region = mapView.region
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { response, error in
            if let error = error {
                print("Failed local search: \(error.localizedDescription)")
                return
            }
            
            //success
            self.mapView.removeAnnotations(self.mapView.annotations)
            response?.mapItems.forEach({ item in

                
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                self.mapView.addAnnotation(annotation)
            })
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
    }
    
    fileprivate func setupSearchUI() {
        let container = UIView(backgroundColor: .white)
        container.clipsToBounds = true
        container.layer.cornerRadius = 8
        view.addSubview(container)
        
        container.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         leading: view.leadingAnchor,
                         bottom: nil,
                         trailing: view.trailingAnchor,
                         padding: .init(top: 0, left: 16, bottom: 0, right: 16)
        )
        
        container.stack(searchTextField).withMargins(.allSides(16))
        
        //listening to searchtextfield change
        //oldschool
        searchTextField.addTarget(self, action: #selector(handleSearchChanges), for: .editingChanged)
        
        //newschool
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { _ in
                Task {
                    await self.performLocalSearch()
                }
            }
    }
    
    fileprivate func setupLocationsCarousel() {
        let locationView = UIView(backgroundColor: .red)
        view.addSubview(locationView)
        locationView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 0, right: 16), size: .init(width: 0, height: 150))
    }
    
    class LocationsCell: LBTAListCell<String> {
        override func setupViews() {
            backgroundColor = .yellow
        }
    }
    
    class LocationsCarouselController: LBTAListController<LocationsCell, String> {
        override func viewDidLoad() {
            super.viewDidLoad()
        }
    }
    
    @objc fileprivate func handleSearchChanges() {
        Task {
            await performLocalSearch()
        }
    }
}

extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //MKPinAnnotationView
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "id")
        annotationView.canShowCallout = true
//        annotationView.image = UIImage(systemName: "mappin.circle.fill")
        return annotationView
    }
}

extension MKMapItem {
    func address() -> String {
        var addressString = ""
        
        if placemark.subThoroughfare != nil {
            addressString += placemark.subThoroughfare! + " "
        }
        
        if placemark.thoroughfare != nil {
            addressString += placemark.thoroughfare! + ", "
        }
        
        if placemark.postalCode != nil {
            addressString += placemark.postalCode! + " "
        }
        
        if placemark.locality != nil {
            addressString += placemark.locality! + ", "
        }
        
        if placemark.administrativeArea != nil {
            addressString += placemark.administrativeArea! + " "
        }
        
        if placemark.country != nil {
            addressString += placemark.country!
        }
        
        return addressString
    }
}

#Preview {
    MainViewControllerRepresentable()
        .ignoresSafeArea()
}

struct MainViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MainViewController {
        return MainViewController()
    }
    
    func updateUIViewController(_ uiViewController: MainViewController, context: Context) {}
}
