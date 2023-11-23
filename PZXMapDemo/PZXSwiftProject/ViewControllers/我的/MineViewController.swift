
import UIKit
import MapKit
import CoreLocation


class MineViewController: UIViewController, MKMapViewDelegate {

    var mapView: MKMapView!
    var annotations = [MKAnnotation]()
    
    let sourceCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    let destinationCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.431297)

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
        
        let button = UIButton.init(type: .custom)
        button.setTitle("导航", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.frame = CGRect(x: 40, y: 80, width: 80, height: 30)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        self.mapView.addSubview(button)
        
        
        let button2 = UIButton.init(type: .custom)
        button2.setTitle("扫码", for: .normal)
        button2.setTitleColor(.red, for: .normal)
        button2.frame = CGRect(x: 240, y: 80, width: 80, height: 30)
        button2.addTarget(self, action: #selector(buttonPressed2), for: .touchUpInside)
        self.mapView.addSubview(button2)

    }
    
    @objc func buttonPressed() {
            
        openMapsAppWithDirections(source: sourceCoordinate, destination: destinationCoordinate)
//        openGoogleMapsAppWithDirections(source: sourceCoordinate, destination: destinationCoordinate)

    }
    
    @objc func buttonPressed2() {
            
        let vc = QRCodeScannerViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    // 打开苹果地图并导航到指定的坐标
    func openMapsAppWithDirections(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)

        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        sourceMapItem.name = "定义的起点"
        destinationMapItem.name = "定义的终点"

        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]

        // 指定起始点和目的地，并打开地图应用开始导航
        // 检查设备上是否安装了苹果地图应用
          if let mapsURL = URL(string: "maps://"), UIApplication.shared.canOpenURL(mapsURL) {
              // 打开地图应用开始导航
              MKMapItem.openMaps(with: [sourceMapItem, destinationMapItem], launchOptions: launchOptions)
          } else {
              // 提示用户安装苹果地图应用或提供其他导航选项
              let alertController = UIAlertController(title: "无法打开地图应用", message: "请确保您的设备上安装了苹果地图应用。", preferredStyle: .alert)
              alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
              present(alertController, animated: true, completion: nil)
          }
    }
    
    func openGoogleMapsAppWithDirections(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let sourceString = "\(source.latitude),\(source.longitude)"
        let destinationString = "\(destination.latitude),\(destination.longitude)"

        // 构建谷歌地图的 URL Scheme
        let googleMapsURLString = "comgooglemaps://?saddr=\(sourceString)&daddr=\(destinationString)&directionsmode=driving"

        // 将 URL 字符串转换为 URL 对象
        if let url = URL(string: googleMapsURLString) {
            // 打开谷歌地图应用
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("无法打开谷歌地图应用")
        }
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
