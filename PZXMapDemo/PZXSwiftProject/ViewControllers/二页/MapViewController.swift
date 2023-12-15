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
    var title: String?
    var subtitle: String?
    

    init(latitude: Double, longitude: Double){
        title = "1"
        subtitle = "2"
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
            displayPriority = .required
            backgroundColor = .gray
            image = UIImage(named: "-")
            let annotation = annotation as? MKClusterAnnotation
            let count = annotation?.memberAnnotations.count

            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            label.text = "\(count ?? 1)"
            label.textAlignment = .center
            label.textColor = UIColor.white
            self.addSubview(label)
        }
    }
}

class CustomAnnotationView: MKAnnotationView {
     
    var isCallOut = false
    
    let foregroundView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

    override var annotation: MKAnnotation? {
        didSet {
            clusteringIdentifier = "arrow"
            self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            self.layer.cornerRadius = 25
            self.layer.borderWidth = 2
            self.layer.borderColor = UIColor.white.cgColor
//            self.layer.masksToBounds = true
            backgroundColor = .white
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            label.text = "5/7"
            label.textAlignment = .center
            label.textColor = UIColor.white
            
            
            backgroundView.layer.cornerRadius = 25
            backgroundView.layer.borderWidth = 2
            backgroundView.backgroundColor = .cyan
//            backgroundView.isUserInteractionEnabled = false
            self.addSubview(backgroundView)

            
            foregroundView.addSubview(label)
            foregroundView.layer.cornerRadius = 25
            foregroundView.layer.borderWidth = 2
            foregroundView.backgroundColor = .blue
//            foregroundView.isUserInteractionEnabled = false
            self.addSubview(foregroundView)
        
            
        }
    }
    
    func showCallOutView () {
        
        self.isCallOut = true
        backgroundView.frame = CGRect(x: 0, y: 0, width: 250, height: 250)

    }
    
    func hiddenCallOutView () {
        
        self.isCallOut = false
        backgroundView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)

    }
}

//MARK: 地图MapViewController

class MapViewController: RootViewController, MKMapViewDelegate {
    
    var mapView: MKMapView!
    var annotations = [MKAnnotation]()
    var previousZoomLevel: Double = 0
    
    let locationManager = CLLocationManager()
    
    var headingImageView: UIImageView?


    ///是否是点击导致移动的
//    var isSelectMove: Bool = false

    //MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setSubviews()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

     
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            
            // 获取当前方向，如果 locationManager.heading 可用
               if let currentHeading = locationManager.heading {
                   // 更新用户定位点视图的方向
                   if let userLocationView = mapView.view(for: mapView.userLocation) {
                       userLocationView.transform = CGAffineTransform(rotationAngle: CGFloat(currentHeading.trueHeading) * .pi / 180.0)
                   }
               }
            
        }
        

    }
    //MARK: – UI
    // subviews
    func setSubviews(){
        
        // 先检查权限
        if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus ==
        .authorizedAlways {
          // 已经获取到权限
            print("已经获取到权限")
        } else {
            print("没有权限")
          locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest


        
        
        // 设置地图的初始显示区域
//        let initialLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
//        let regionRadius: CLLocationDistance = 5000
//        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)

        
        // 创建 MKMapView 对象
        mapView = MKMapView(frame: view.bounds)
        mapView.delegate = self
        mapView.showsUserLocation = true
//        mapView.isRotateEnabled = false
        mapView.userTrackingMode = .followWithHeading

        
        view.addSubview(mapView)
//        mapView.setRegion(coordinateRegion, animated: true)
//
//        // 添加一些标注
//        addRandomAnnotationsNearby(coordinate: initialLocation.coordinate)

        // 将标注添加到地图x
//        mapView.addAnnotations(annotations)

        // 配置聚合
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(
            ClusterAnnotationView.self,
            forAnnotationViewWithReuseIdentifier:MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        
        // Add a tap gesture recognizer to the map view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
//        mapView.addGestureRecognizer(tapGesture)
        
        
        let button = UIButton.init(type: .custom)
        button.setTitle("跳转", for: .normal)
        button.frame = CGRect(x: 40, y: 80, width: 80, height: 30)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        self.mapView.addSubview(button)
        
        // Do any additional setup after loading the view.
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()

        
    }
    

    
    @objc func buttonPressed() {
        
        let vc : Mine2ViewController = Mine2ViewController.init()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func addRandomAnnotationsNearby(coordinate:CLLocationCoordinate2D) {
        
        // 清除地图上的现有标注
        mapView.removeAnnotations(annotations)
        
        // 清空数组
        annotations.removeAll()

        // 在37.7749, -122.4194 附近随机生成20个标注点
        for _ in 1...20 {
            let randomLatitude = Double.random(in: coordinate.latitude - 0.01 ... coordinate.latitude + 0.01)
            let randomLongitude = Double.random(in: coordinate.longitude - 0.01 ... coordinate.longitude + 0.01)

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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self.mapView)
            let view = self.mapView.hitTest(point, with: event)

            if let annotationContainerViewType = NSClassFromString("MKAnnotationContainerView"),
               let annotationViewType = NSClassFromString("MKAnnotationView") {
                if view!.isKind(of: annotationContainerViewType) {
                    onClickedMapBlank()
                    print("点击空白区域")
                } else if view!.isKind(of: annotationViewType) {
                    print("点击Annotation区域")
                }
            }
        }
    }

    func onClickedMapBlank() {
        // doSomething
        hideCustomAnnotationView(mapView, selfView: nil,isAll: true)
    }
    
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            
            //点击标注不执行
            // 获取点击的点的坐标
            let location = gesture.location(in: mapView)
            
            // 判断点击的位置是否在 MKAnnotationView 上
//            if let tappedView = mapView.hitTest(location, with: nil), tappedView is MKAnnotationView {
//                       // 如果点击位置在 MKAnnotationView 上，不执行进一步操作
//                       return
//            }
            
            // 将点的坐标转换成地图上的坐标
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            // 在这里执行你的操作，比如处理点击地图的空白区域或者双击空白区域
            print("Clicked on map at coordinate: \(coordinate)")
//            hideCustomAnnotationView(mapView, selfView: nil,isAll: true)
            
        }
    }
    
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
         }else if annotation is MKUserLocation {

             let userLocationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
             // 设置用户定位点视图的大小
             userLocationView.frame  = CGRectMake(0, 0, 10, 10)
             userLocationView.image = UIImage(named: "shangjiantou")
             return userLocationView

//             return nil
             
         }else {
             return MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
         }
     }
    
    // MARK: - UIScrollViewDelegate
  
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        // 在这里处理缩放开始的逻辑
//        hideAllCustomAnnotationView(mapView)
        previousZoomLevel  = mapView.zoomLevel
         

    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // 在这里处理缩放结束的逻辑


        print("previousZoomLevel = \(previousZoomLevel)")
        print("mapView.zoomLevel = \(mapView.zoomLevel)")
//        addRandomAnnotationsNearby()
        if (previousZoomLevel != mapView.zoomLevel) {
//            mapView.removeAnnotations(annotations)
//            mapView.addAnnotations(annotations)
        }


    }
    
    
    

    fileprivate func hideCustomAnnotationView(_ mapView: MKMapView, selfView: CustomAnnotationView?,isAll:Bool = false) {
        // 获取地图上所有的标注
        let allAnnotations = mapView.annotations
        
        // 筛选出类型为 CustomAnnotationView 的标注
        let customAnnotationViews = allAnnotations.compactMap { annotation -> CustomAnnotationView? in
            return mapView.view(for: annotation) as? CustomAnnotationView
        }
        for item in customAnnotationViews {
            //隐藏的时候z轴最小
            item.zPriority = .min
            if (isAll) {
                item.hiddenCallOutView()
            } else {
                if (selfView != item) {
                    item.hiddenCallOutView()
                }
            }
       
        }
    }
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        print("Did select MKAnnotation")
        


    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {


        if let customAnnotationView = view as? CustomAnnotationView {
               // Now 'customAnnotationView' is of type CustomAnnotationView
               print("Did select CustomAnnotationView")
            
            hideCustomAnnotationView(mapView, selfView: customAnnotationView)
            


            
            if (customAnnotationView.isCallOut) {
                customAnnotationView.hiddenCallOutView()
            } else {
                customAnnotationView.showCallOutView()
            }
            ///选中的customAnnotationView Z轴置顶
            customAnnotationView.zPriority = .max
            mapView.setCenter(view.annotation!.coordinate, animated: true)


           } else if view is ClusterAnnotationView {
               print("Did select ClusterAnnotationView")
               mapView.setZoomLevel(mapView.zoomLevel + 1.3,coordinate: view.annotation?.coordinate)
           }
        mapView.deselectAnnotation(view.annotation, animated: true)



    

    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
//        if let customAnnotationView = view as? CustomAnnotationView {
//               // Now 'customAnnotationView' is of type CustomAnnotationView
//               print("didDeselect CustomAnnotationView")
//                customAnnotationView.hiddenCallOutView()
//           }
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
        
      
    }
    // 实现群集标注的方法
       func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
           // 创建一个MKClusterAnnotation实例，将群集中的标注数组传递给它
           let clusterAnnotation = MKClusterAnnotation(memberAnnotations: memberAnnotations)
//           print("clusterAnnotation = \(clusterAnnotation)")
           return clusterAnnotation
       }


}

extension MapViewController:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
         if let location = locations.last {
             
             let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
//             print("location.coordinate.latitude = \(location.coordinate.latitude)")
//             print("location.coordinate.longitude = \(location.coordinate.longitude)")
             mapView.setRegion(region, animated: true)
             // 添加一些标注
             addRandomAnnotationsNearby(coordinate: location.coordinate)
             print("didUpdateLocations")


             locationManager.stopUpdatingLocation()
         }
     }

     func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
         print("didUpdateHeading")
         
//         mapView.camera.heading = newHeading.trueHeading
//         mapView.setCamera(mapView.camera, animated: true)
         
         // 获取设备方向，并更新用户定位点视图的方向
         updateUserLocationViewWithHeading(newHeading.trueHeading)
         
         
     }
    

    
    func updateUserLocationViewWithHeading(_ heading: CLLocationDirection) {
        if let userLocationView = mapView.view(for: mapView.userLocation) {
            userLocationView.transform = CGAffineTransform(rotationAngle: CGFloat(heading) * .pi / 180.0)
        }
    }
    

    
    
}

extension CGFloat {
    var toRadians: CGFloat {
        return self * .pi / 180.0
    }
}











//            canShowCallout = true
//            let detailView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
//            detailView.backgroundColor = UIColor.red
//            let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
//            leftView.backgroundColor = UIColor.yellow
//            let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
//            rightView.backgroundColor = UIColor.cyan
//
//            let label2 = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
//            label2.text = "直流3"
//            label2.textAlignment = .center
//            label2.textColor = UIColor.red
//
//            detailView.addSubview(label2)
//            rightView.addSubview(label2)
//            leftView.addSubview(label2)
//
//            self.detailCalloutAccessoryView = detailView
//            self.leftCalloutAccessoryView = leftView
//            self.rightCalloutAccessoryView = rightView
