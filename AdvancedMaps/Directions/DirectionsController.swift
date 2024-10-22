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
    let startTextField = IndentedTextField(placeholder: "Starting Point",
                                           padding: 12,
                                           cornerRadius: 8)
    let endTextField = IndentedTextField(placeholder: "Ending Point",
                                        padding: 12,
                                        cornerRadius: 8)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
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
        
        [startTextField, endTextField].forEach { tf in
            tf.backgroundColor = .white
            tf.textColor = .black
        }
        
        let containerView = UIView()
        navBar.addSubview(containerView)
        containerView.fillSuperviewSafeAreaLayoutGuide()
        
        let startIcon = UIImageView(image: #imageLiteral(resourceName: "start_location_circles").withRenderingMode(.alwaysTemplate),
                                    contentMode: .scaleAspectFit)
        startIcon.constrainWidth(20)
        startIcon.tintColor = .white
        let endIcon = UIImageView(image: #imageLiteral(resourceName: "annotation_icon").withRenderingMode(.alwaysTemplate),
                                  contentMode: .scaleAspectFit)
        endIcon.constrainWidth(20)
        endIcon.tintColor = .white
        
        containerView.stack(containerView.hstack(startIcon, startTextField, spacing: 12),
                            containerView.hstack(endIcon, endTextField, spacing: 12),
                            spacing: 12,
                            distribution: .fillEqually)
        .withMargins(.init(top: 0, left: 12, bottom: 12, right: 12))
        
        startTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleChangeStartLocation)))
        
        endTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleChangeEndLocation)))
    }
    
    @objc
    fileprivate func handleChangeStartLocation() {
        let vc = LocationSearchController()
        vc.selectionHandler = { [weak self] mapItem in
            self?.startTextField.text = mapItem.name
        }
        vc.view.backgroundColor = .yellow
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    fileprivate func handleChangeEndLocation() {
        let vc = LocationSearchController()
        vc.selectionHandler = { [weak self] mapItem in
            self?.endTextField.text = mapItem.name
        }
        vc.view.backgroundColor = .yellow
        navigationController?.pushViewController(vc, animated: true)
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
//        request.requestsAlternateRoutes = true
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                print("Failed to get the routing info", error)
                return
            }
            
//            response?.routes.forEach({ route in
//                self.mapView.addOverlay(route.polyline)
//            })
             
            guard let route = response?.routes.first else { return }
            self.mapView.addOverlay(route.polyline)
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
    func makeUIViewController(context: Context) -> UIViewController {
        return UINavigationController(rootViewController: DirectionsController())
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
