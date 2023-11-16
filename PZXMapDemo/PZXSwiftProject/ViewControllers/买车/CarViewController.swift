//
//  PZXSwiftProject
//  CarViewController.swift
//  Created by pzx on 2021/7/6
//  
//  ***
//  *   GitHub:https://github.com/PZXforXcode
//  *   简书:https://www.jianshu.com/u/e2909d073047
//  *   qq:496912046
//  ***
//MapKit 使用


import MapKit
import UIKit
import CoreLocation
import Cluster


class CarViewController: RootViewController,MKMapViewDelegate {
    
    var mapView: MKMapView!

    lazy var manager: ClusterManager = { [unowned self] in
        let manager = ClusterManager()
        manager.delegate = self
        manager.maxZoomLevel = 17
        manager.minCountForClustering = 2
        manager.clusterPosition = .nearCenter
        return manager
    }()
    
    override func loadView() {
        mapView = MKMapView()
        mapView.delegate = self
        self.view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = RandomColor();

        
        let locationManager = CLLocationManager()
        // 先检查权限
        if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus ==
        .authorizedAlways {
          // 已经获取到权限
        } else {
          locationManager.requestWhenInUseAuthorization()
        }
        // Do any additional setup after loading the view.
        locationManager.startUpdatingLocation()
        
        
        // 设置地图的初始显示区域
        let initialLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        let regionRadius: CLLocationDistance = 5000
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)

        // 设置地图的初始显示区域
        var annotations = [CustomAnnotation]()
            // 添加多个相似样式的标注
            for i in 0..<5 {
                let annotation = CustomAnnotation(coordinate: getRandomCoordinate(center: initialLocation.coordinate, distance: 2000), title: "Location \(i+1)", subtitle: "Description \(i+1)")
                annotations.append(annotation)
            }
            manager.add(annotations)
            mapView.addAnnotations(annotations)

            manager.reload(mapView: mapView)

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
   
//            guard let customAnnotation = annotation as? CustomAnnotation else {
//                return nil
//            }
        let customAnnotation = annotation as? CustomAnnotation
        
        if let annotation = annotation as? ClusterAnnotation {
            
            let identifier = "ClusterAnnotation"
            var annotationView: MKAnnotationView
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            annotationView.backgroundColor = UIColor.yellow
            
            
            // 添加标注文字
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            label.text = "\(annotation.annotations.count)"
            label.textColor = UIColor.red
            annotationView.addSubview(label)
            
            return annotationView
            
        } else {
            
            let identifier = "customAnnotationView"
            var annotationView: MKAnnotationView
//        MKMarkerAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                annotationView = dequeuedView
            } else {
                annotationView = MKAnnotationView(annotation: customAnnotation, reuseIdentifier: identifier)
                annotationView.canShowCallout = false
                annotationView.image = UIImage(named: "your_custom_image")
                annotationView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                annotationView.backgroundColor = UIColor.gray
                
                // 添加标注文字
                let label = UILabel(frame: CGRect(x: 0, y: 0, width:50, height: 50))
                label.text = customAnnotation?.title ?? "test"
                label.textColor = UIColor.red
                annotationView.addSubview(label)
            }
            
            return annotationView
            
            
        }
        
     }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        manager.reload(mapView: mapView) { finished in
            print(finished)
        }
    }
    
    // 生成随机坐标
     func getRandomCoordinate(center: CLLocationCoordinate2D, distance: Double) -> CLLocationCoordinate2D {
         let latOffset = Double.random(in: -0.02...0.02)
         let lonOffset = Double.random(in: -0.02...0.02)

         let newLat = center.latitude + latOffset
         let newLon = center.longitude + lonOffset

         return CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
     }

}

class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        
    }
    
}

extension CarViewController: ClusterManagerDelegate {
    
    func cellSize(for zoomLevel: Double) -> Double? {
        return 100 // default
    }
    
    func shouldClusterAnnotation(_ annotation: MKAnnotation) -> Bool {
        return !(annotation is MeAnnotation)
    }
    
}



class MeAnnotation: Annotation {}
