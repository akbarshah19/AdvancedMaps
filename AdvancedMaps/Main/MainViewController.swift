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
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestUserLocation()
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.fillSuperview()
        mapView.showsUserLocation = true
        setupRegion()
        Task {
            await performLocalSearch()
        }
        setupSearchUI()
        setupLocationsCarousel()
    }
    
    fileprivate func requestUserLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    fileprivate func setupRegion() {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
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
            self.locationsController.items.removeAll()
            
            response?.mapItems.forEach({ item in
                
                
                let annotation = CustomMapItemAnnotation()
                annotation.mapItem = item
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                
                self.mapView.addAnnotation(annotation)
                self.locationsController.items.append(item)
            })
            
            self.locationsController.collectionView.reloadData()
            if !self.locationsController.items.isEmpty {
                DispatchQueue.main.async {
                    self.locationsController.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0),
                                                                         at: .centeredHorizontally,
                                                                         animated: true)
                }
            }
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
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { _ in
                Task {
                    await self.performLocalSearch()
                }
            }
    }
    
    let locationsController = LocationsCarouselController(scrollDirection: .horizontal)
    
    fileprivate func setupLocationsCarousel() {
        let locationView = locationsController.view!
        
        view.addSubview(locationView)
        locationView.anchor(top: nil,
                            leading: view.leadingAnchor,
                            bottom: view.safeAreaLayoutGuide.bottomAnchor,
                            trailing: view.trailingAnchor,
                            size: .init(width: 0, height: 150))
        
        locationsController.mainVC = self
    }
    
    @objc fileprivate func handleSearchChanges() {
        Task {
            await performLocalSearch()
        }
    }
}

extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKPointAnnotation) {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "id")
            annotationView.canShowCallout = true
            return annotationView
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let customAnnotation = view.annotation as? CustomMapItemAnnotation else { return }
        
        guard let index = self.locationsController.items.firstIndex(where: {$0.name == view.annotation?.title}) else { return }
        self.locationsController.collectionView.scrollToItem(at: [0, index], at: .centeredHorizontally, animated: true)
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            print("Location authorized")
            manager.startUpdatingLocation()
        default:
            print("Failed to authrize location")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let firstLocation = locations.first else { return }
        mapView.setRegion(.init(center: firstLocation.coordinate, span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: false)
        locationManager.stopUpdatingLocation()
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

class CustomMapItemAnnotation: MKPointAnnotation {
    var mapItem: MKMapItem?
}
