//
//  NonClusteringMKMarkerAnnotationView.swift
//  Location
//
//  Created by Eric  on 01.09.22.
//

import UIKit
import MapKit

class NonClusteringMKMarkerAnnotationView: MKMarkerAnnotationView {

    override var annotation: MKAnnotation? {
        willSet {
            markerTintColor = .gray
            canShowCallout = true
            
            displayPriority = MKFeatureDisplayPriority.required
        }
        
    }

}
