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
            label.textColor = UIColor.red
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
            self.layer.borderColor = UIColor.yellow.cgColor
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
            foregroundView.backgroundColor = .brown
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


class MapViewController: RootViewController, MKMapViewDelegate {
    
    var mapView: MKMapView!
    var annotations = [MKAnnotation]()
    var previousZoomLevel: Double = 0
    ///是否是点击导致移动的
//    var isSelectMove: Bool = false

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
         } else {
             return MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
         }
     }
    
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
