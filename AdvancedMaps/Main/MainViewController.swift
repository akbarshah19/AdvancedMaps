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
        request.naturalLanguageQuery = "Apple"
        request.region = mapView.region
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { response, error in
            if let error = error {
                print("Failed local search: \(error.localizedDescription)")
                return
            }
            
            response?.mapItems.forEach({ item in
                let placemark = item.placemark
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
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                self.mapView.addAnnotation(annotation)
            })
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
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
