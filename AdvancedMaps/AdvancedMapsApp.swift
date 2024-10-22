//
//  AdvancedMapsApp.swift
//  AdvancedMaps
//
//  Created by Akbarshah Jumanazarov on 10/14/24.
//

import SwiftUI

@main
struct AdvancedMapsApp: App {
    var body: some Scene {
        WindowGroup {
            DirectionsControllerRepresentable()
                .ignoresSafeArea()
        }
    }
}
