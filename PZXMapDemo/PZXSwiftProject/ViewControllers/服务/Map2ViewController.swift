//
//  MapViewController.swift
//  GoogleMapDemo
//
//  Created by 彭祖鑫 on 2023/11/15.
//
///自己写算法 解决这个
import UIKit
import MapKit
import CoreLocation

class CustomClusterAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var memberAnnotations: [MKAnnotation]

    init(coordinate: CLLocationCoordinate2D, memberAnnotations: [MKAnnotation]) {
        self.coordinate = coordinate
        self.memberAnnotations = memberAnnotations
    }
}


class PZXMap2CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D

    init(latitude: Double, longitude: Double){
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
    }
}

class ClusterMap2AnnotationView: MKAnnotationView {
    private let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

    override var annotation: MKAnnotation? {
        didSet {

            self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            //这句代码很重要，不设置required经常出现异常消失的问题
            displayPriority = .required
            backgroundColor = .gray
            image = UIImage(named: "-")

            label.textAlignment = .center
            label.textColor = UIColor.red
            label.text = "\((annotation as? CustomClusterAnnotation)?.memberAnnotations.count ?? 1)"
            addSubview(label)
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class CustomMap2AnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        didSet {
            
            displayPriority = .required
            self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            backgroundColor = .white
            image = UIImage(named: "黑色返回")

        }
    }
}


class Mine2ViewController: RootViewController, MKMapViewDelegate {
    
    var mapView: MKMapView!
    var annotations = [MKAnnotation]()


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

        // 将标注添加到地图
        mapView.addAnnotations(annotations)

        // 配置聚合
        mapView.register(CustomMap2AnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(
            ClusterMap2AnnotationView.self,
            forAnnotationViewWithReuseIdentifier:MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        
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

            let annotation = PZXMap2CustomAnnotation(latitude: randomLatitude, longitude: randomLongitude)
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
        
        if annotation is CustomClusterAnnotation {
            return ClusterMap2AnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        }else if annotation is PZXMap2CustomAnnotation {
             guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? CustomMap2AnnotationView else {
                 return CustomAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
             }
             annotationView.annotation = annotation
             return annotationView
         } else {
             return MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
         }
     }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
           // 地图区域变化后重新组织标注
        mapView.removeAnnotations(mapView.annotations)
        let reorganizedAnnotations = reorganizeAnnotations(for: mapView.region)
        print("reorganizedAnnotations = \(reorganizedAnnotations)")
        mapView.addAnnotations(reorganizedAnnotations)
        print("mapView.annotations = \(mapView.annotations)")
        print("reorganizedAnnotations.count = \(reorganizedAnnotations.count)")
        print("mapView.annotations.count = \(mapView.annotations.count)")

       }
       
    
    func reorganizeAnnotations(for region: MKCoordinateRegion) -> [MKAnnotation] {
        var newAnnotations: [MKAnnotation] = []
        var clusters: [CustomClusterAnnotation] = []

        // 遍历当前所有的标注
        for annotation in annotations {
            var isClustered = false
            let annotationLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)

            // 检查是否有足够近的聚合标注可以加入
            for cluster in clusters {
                let clusterLocation = CLLocation(latitude: cluster.coordinate.latitude, longitude: cluster.coordinate.longitude)

                // 如果标注与聚合标注足够近，则加入该聚合
                if annotationLocation.distance(from: clusterLocation) < calculateClusteringDistanceThreshold(for: region) {
                    cluster.memberAnnotations.append(annotation)
                    isClustered = true
                    break
                }
            }

            // 如果没有足够近的聚合标注，则创建一个新的聚合标注
            if !isClustered {
                let newCluster = CustomClusterAnnotation(coordinate: annotation.coordinate, memberAnnotations: [annotation])
                clusters.append(newCluster)
            }
        }

        // 将独立的标注和聚合的标注添加到新数组
        newAnnotations = clusters.flatMap { cluster in
            cluster.memberAnnotations.count > 1 ? [cluster] : cluster.memberAnnotations
        }

        return newAnnotations
    }
    func calculateClusteringDistanceThreshold(for region: MKCoordinateRegion) -> CLLocationDistance {
        // 根据缩放等级等条件，计算聚合的距离阈值
        // 你可能需要根据具体情况调整这个逻辑
        return region.span.latitudeDelta * 10000
    }

    func findNearbyCluster(for annotation: PZXMap2CustomAnnotation, in clusters: inout [CustomClusterAnnotation], with distanceThreshold: CLLocationDistance) -> CustomClusterAnnotation? {
        let annotationLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        for cluster in clusters {
            // 直接使用 cluster，不需要类型转换
            let clusterLocation = CLLocation(latitude: cluster.coordinate.latitude, longitude: cluster.coordinate.longitude)
            let distance = annotationLocation.distance(from: clusterLocation)
            
            if distance < distanceThreshold {
                return cluster
            }
        }
        return nil
    }

}
