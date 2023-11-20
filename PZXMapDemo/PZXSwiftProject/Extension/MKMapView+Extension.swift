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
    
    
    func setZoomLevel(_ zoomLevel: Double, coordinate: CLLocationCoordinate2D? = nil, animated: Bool = true) {
        let minZoomLevel = 2.0
        let maxZoomLevel = 19.67
        
        // 限制缩放等级在有效范围内
        let clampedZoomLevel = min(max(zoomLevel, minZoomLevel), maxZoomLevel)

        // 根据缩放等级计算新的 region.span.longitudeDelta
        let longitudeDelta = (360 / pow(2, clampedZoomLevel)) * Double(frame.size.width) / 256.0

        // 根据缩放等级计算新的 region.span.latitudeDelta
        let latitudeDelta = (180 / pow(2, clampedZoomLevel)) * Double(frame.size.height) / 256.0

        // 创建新的 region
        let newRegion: MKCoordinateRegion
        if let coordinate = coordinate {
            newRegion = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            )
        } else {
            newRegion = MKCoordinateRegion(
                center: region.center,
                span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            )
        }

        // 设置地图的新 region
        setRegion(newRegion, animated: animated)
    }
    
    
}
