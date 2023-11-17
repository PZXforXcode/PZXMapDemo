//
//  MapViewController.swift
//  GoogleMapDemo
//
//  Created by 彭祖鑫 on 2023/11/15.
//

import UIKit
import MapKit
import CoreLocation


class PZXCustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D

    init(latitude: Double, longitude: Double){
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
    }
}

class ClusterAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        didSet {
            self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            self.layer.cornerRadius = 25
            self.layer.borderWidth = 2
            self.layer.borderColor = UIColor.orange.cgColor
            displayPriority = .defaultHigh
            backgroundColor = .gray
            image = UIImage(named: "-")
            let annotation = annotation as? MKClusterAnnotation
            let count = annotation?.memberAnnotations.count

            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            label.text = "\(count ?? 1)"
            label.textAlignment = .center
            label.textColor = UIColor.red
            self.addSubview(label)
        }
    }
}

class CustomAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        didSet {
            clusteringIdentifier = "arrow"
            self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            backgroundColor = .white
            image = UIImage(named: "黑色返回")
            
        }
    }
}


class MapViewController: RootViewController, MKMapViewDelegate {
    
    var mapView: MKMapView!
    var annotations = [MKAnnotation]()
    var previousZoomLevel: Double = 0


    //MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setSubviews()

    }
    //MARK: – UI
    // subviews
    func setSubviews(){
        
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

        
        // 创建 MKMapView 对象
        mapView = MKMapView(frame: view.bounds)
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.setRegion(coordinateRegion, animated: true)

        // 添加一些标注
        addRandomAnnotationsNearby()

        // 将标注添加到地图x
        mapView.addAnnotations(annotations)

        // 配置聚合
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(
            ClusterAnnotationView.self,
            forAnnotationViewWithReuseIdentifier:MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        
        let button = UIButton.init(type: .custom)
        button.setTitle("跳转", for: .normal)
        button.frame = CGRect(x: 40, y: 80, width: 80, height: 30)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        self.mapView.addSubview(button)
        
    }
    @objc func buttonPressed() {
        
        let vc : Mine2ViewController = Mine2ViewController.init()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func addRandomAnnotationsNearby() {
        
        // 清除地图上的现有标注
        mapView.removeAnnotations(annotations)
        
        // 清空数组
        annotations.removeAll()

        // 在37.7749, -122.4194 附近随机生成20个标注点
        for _ in 1...20 {
            let randomLatitude = Double.random(in: 37.7749 - 0.01 ... 37.7749 + 0.01)
            let randomLongitude = Double.random(in: -122.4194 - 0.01 ... -122.4194 + 0.01)

            let annotation = PZXCustomAnnotation(latitude: randomLatitude, longitude: randomLongitude)
            annotation.coordinate = CLLocationCoordinate2D(latitude: randomLatitude, longitude: randomLongitude)
            annotations.append(annotation)
        }

        mapView.addAnnotations(annotations)
    }
    
    
    //MARK: – request
    // 获取服务数据
    
    
    //MARK: – 填充数据
    // 填充数据
    
    
    //MARK: – 点击事件
    
    
    //MARK: – Public Method
    // 公有方法
    
    
    //MARK: – Private Method
    // 私有方法
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKClusterAnnotation {
            return ClusterAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        }else if annotation is PZXCustomAnnotation {
             guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? CustomAnnotationView else {
                 return CustomAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
             }
             annotationView.annotation = annotation
             return annotationView
         } else {
             return MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
         }
     }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        // 在这里处理缩放开始的逻辑
        previousZoomLevel  = mapView.zoomLevel

    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // 在这里处理缩放结束的逻辑
        
        print("previousZoomLevel = \(previousZoomLevel)")
        print("mapView.zoomLevel = \(mapView.zoomLevel)")
//        addRandomAnnotationsNearby()
        if (previousZoomLevel != mapView.zoomLevel) {
            mapView.removeAnnotations(annotations)
            mapView.addAnnotations(annotations)
            
        }

    }
    
    // 实现群集标注的方法
       func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
           // 创建一个MKClusterAnnotation实例，将群集中的标注数组传递给它
           let clusterAnnotation = MKClusterAnnotation(memberAnnotations: memberAnnotations)
//           print("clusterAnnotation = \(clusterAnnotation)")
           return clusterAnnotation
       }


}
