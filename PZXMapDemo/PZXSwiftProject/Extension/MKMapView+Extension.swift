//
//  MKMapView+Extension.swift
//  PZXMapDemo
//
//  Created by 彭祖鑫 on 2023/11/17.
//

import Foundation
import MapKit

extension MKMapView {

    var zoomLevel: Double {
        let decimalPlaces = 2
        let multiplier = pow(10.0, Double(decimalPlaces))
        return round(log2(360 * Double(frame.size.width) / 256.0 / region.span.longitudeDelta) * multiplier) / multiplier
    }
    
}
