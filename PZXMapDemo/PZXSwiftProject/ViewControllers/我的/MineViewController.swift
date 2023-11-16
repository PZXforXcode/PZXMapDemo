
import UIKit
import MapKit
import CoreLocation


class MineViewController: UIViewController, MKMapViewDelegate {

    var mapView: MKMapView!
    var annotations = [MKAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        
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

        // 配置聚合
        mapView.register(CustomClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
//        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

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

            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: randomLatitude, longitude: randomLongitude)
            annotations.append(annotation)
        }

        mapView.addAnnotations(annotations)
    }


    // MARK: - MKMapViewDelegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier) as? CustomClusterAnnotationView {
            annotationView.annotation = annotation
            annotationView.resetMarkGlyph()
            print("聚合")
            return annotationView
        } else {
            
            let annotationView = CustomClusterAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            annotationView.resetMarkGlyph()
            annotationView.glyphText = "1"
            print("没聚合")
            return annotationView
        }
        
    }
}

class CustomClusterAnnotationView: MKMarkerAnnotationView {
    
    private var imageName: String = ""
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        clusteringIdentifier = "uav"
        collisionMode = .rectangle
        displayPriority = .defaultLow
        glyphTintColor = UIColor.red
        resetMarkGlyph()
    }
    
    func resetMarkGlyph() {
        
        guard let annotation = annotation as? MKClusterAnnotation else {
             return
         }
        // 设置聚合标注的图像，显示成员标注的数量
        let count = annotation.memberAnnotations.count
        markerTintColor = UIColor.white
        image = UIImage(named: "白色返回")
        glyphText = "\(count)"
        glyphTintColor = UIColor.red
//        glyphImage = UIImage(named: "白色返回")
        subtitleVisibility = .hidden
//        selectedGlyphImage = UIImage(named: "白色返回")
        
    }
}
