//
//  DirectionsController.swift
//  AdvancedMaps
//
//  Created by Akbarshah Jumanazarov on 10/22/24.
//

import UIKit
import MapKit
import LBTATools
import SwiftUI

class DirectionsController: UIViewController {
    
    let mapView = MKMapView()
    let navBar = UIView(backgroundColor: .blue)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.showsUserLocation = true
        setupRegion()
        setupNavBarUI()
        mapView.anchor(top: navBar.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        setupStartEndAnnotation()
        requestForDirections()
    }
    
    fileprivate func setupRegion() {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    fileprivate func setupNavBarUI() {
        view.addSubview(navBar)
        navBar.backgroundColor = .blue
        navBar.setupShadow(opacity: 0.5, color: .black)
        navBar.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -100, right: 0))
    }
    
    fileprivate func setupStartEndAnnotation() {
        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = .init(latitude: 37.7666, longitude: -122.427290)
        startAnnotation.title = "Starting Point"
        
        let endAnnotation = MKPointAnnotation()
        endAnnotation.coordinate = .init(latitude: 37.331352, longitude: -122.030331)
        endAnnotation.title = "Ending Point"
        
        mapView.addAnnotations([startAnnotation, endAnnotation])
        mapView.showAnnotations(self.mapView.annotations, animated: true)
    }
    
    fileprivate func requestForDirections() {
        let request = MKDirections.Request()
        let startingPlacemark = MKPlacemark(coordinate: .init(latitude: 37.7666, longitude: -122.427290))
        let endingPlacemark = MKPlacemark(coordinate: .init(latitude: 37.331352, longitude: -122.030331))
        request.source = .init(placemark: startingPlacemark)
        request.destination = .init(placemark: endingPlacemark)
//        request.transportType = .walking
        request.requestsAlternateRoutes = true
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                print("Failed to get the routing info", error)
                return
            }
            
            response?.routes.forEach({ route in
                self.mapView.addOverlay(route.polyline)
            })
            
//            guard let route = response?.routes.first else { return }
//            self.mapView.addOverlay(route.polyline)
        }
    }
}

extension DirectionsController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        let polylinRenderer = MKPolylineRenderer(overlay: overlay)
        polylinRenderer.strokeColor = .red
        return polylinRenderer
    }
}















#Preview(body: {
    DirectionsControllerRepresentable()
        .ignoresSafeArea()
})

struct DirectionsControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DirectionsController {
        return DirectionsController()
    }
    
    func updateUIViewController(_ uiViewController: DirectionsController, context: Context) {}
}
