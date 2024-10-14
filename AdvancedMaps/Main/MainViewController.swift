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

struct MainViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MainViewController {
        return MainViewController()
    }
    
    func updateUIViewController(_ uiViewController: MainViewController, context: Context) {}
}

class MainViewController: UIViewController {
    
    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mapView)
        mapView.fillSuperview()
    }
}
