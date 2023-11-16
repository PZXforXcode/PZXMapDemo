# PZXMapDemo
MapKit地图Demo
# iOS MapKit 实现点聚合

## 前言

公司有海外版App业务，需要使用MapKit，之前用高德地图是自带点聚合功能的。在国内MapKit的相关文献比较少，官方文档对点聚合api介绍也不是很详细。经过探索，把经验总结下来，后续可以参考。

## 实现方案

### 1.后端实现

有朋友在租房平台地图实现了点聚合，他们的方案是，传入当前地图的对角经纬度，后端会返回相应的大头针数据，根据大头针数据进行在地图上的摆放。

例如下面的数据

```json
{
  list:[
    {
      type:1//type 用于判断显示那种类型的大头针 例如1是非聚合的大头针 2是聚合的大头针  3是最大聚合的大头针
      msg:"显示的内容"
      count:10//聚合的数量
      ...//其他
    }
  ]
  
}
```

每次滑动和改变地图大小都会请求接口，并且获取到相应数据进行展示。类似App：特来电，贝壳找房

优点：聚合规则可控制，客户端统一由后端的数据进行渲染展示。

缺点：每次展示都是需要网络请求进行刷新的

### 2.后端+客户端实现

经过自己研究MapKit有一套自己的点聚合，但是规则是Apple自己计算的，无法控制（可能是系统根据某个规则判断2个点靠近了，进行聚合）。

参考的国外博客：https://medium.com/mobilepeople/enhance-your-map-experience-with-annotations-13e28507f892

这样的方案我通过代码模拟了下

首先创建一个地图

然后添加一个点

```swift
var mapView: MKMapView!
//设置地图大小  代理 设置定位等（后续完整代码可以看到所有的，这部分先展示关键代码帮助理解）

let annotation = MKPointAnnotation()
annotation.coordinate = CLLocationCoordinate2DMake(52.524190, 13.403030)          
mapView.addAnnotation(annotation)
```

在地图上会添加这样一个大头针

![img](https://p.ipic.vip/9rq36w.png)



自定义一个MKAnnotation类

```swift
class PZXCustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D

    init(latitude: Double, longitude: Double){
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
    }
}
```

在自定义一个MKAnnotationView类 用于自定义大头针样式

```swift
///非聚合大头针样式
class CustomAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        didSet {
            self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            backgroundColor = .white
            image = UIImage(named: "自定义图片名称")
        }
    }
}
```

注册这个自定义View

```swift
///注册大头针
mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
```

重新添加大头针

```swift
let annotation = PZXCustomAnnotation(latitude: 52.524190, longitude: 13.403030)
mapView.addAnnotation(annotation)
```

![img](https://p.ipic.vip/vuanog.png)

这样在地图上就有了一个自定义图片的大头针

然后给地图加上代理

```swift
        mapView.delegate = self
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

```

代理方法里面加Viewfor的方法

```swift
func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
     if annotation is PZXCustomAnnotation {
         guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? CustomAnnotationView else {
             return CustomAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
         }
         annotationView.annotation = annotation
         return annotationView
     } else {
         return MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
     }
 }
```

这样地图上就可以添加2个不同的的点了

![img](https://p.ipic.vip/rii8os.png)

然后如果我们添加多个点

![img](https://miro.medium.com/v2/resize:fit:398/1*EHsII3dmBmQB6hPdGOnN1A.gif)

![img](https://miro.medium.com/v2/resize:fit:398/1*89jYy-3759MSR_LjudKYVQ.gif)

系统的样式的图片是可以聚合的，但是我们自定义的样式是无法聚合的

需要给自定义的View添加clusteringIdentifier

```swift
class CustomAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        didSet {
            clusteringIdentifier = "clusteringIdentifier"
            self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            backgroundColor = .white
            image = UIImage(named: "自定义图标")
            
        }
    }
}
```

这样就可以达到聚合的样式了

但是目前聚合的样式也是系统样式，如果想自定义的话还需要添加代码

![img](https://miro.medium.com/v2/resize:fit:398/1*dCMpYTS3qd3_QinNhz7gFA.gif)

自定义一个聚合类的MKAnnotationView

```swift
class ClusterAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        didSet {
            self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            displayPriority = .defaultHigh
            backgroundColor = .gray
            image = UIImage(named: "-")
          	//获取到聚合的子类数字
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
```

记得注册它

```swift
        mapView.register(
            ClusterAnnotationView.self,
            forAnnotationViewWithReuseIdentifier:MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
```

最后在代理里进行添加判断代码

```swift
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
```

这样自定义样式的聚合就完成了

## 完整代码

最后附上这个ViewController的完整代码

```swift
//
//  MapViewController.swift
//  GoogleMapDemo
//
//  Created by pzx on 2023/11/15.
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
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(
            ClusterAnnotationView.self,
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

}

```

## Demo

demo地址:https://github.com/PZXforXcode/PZXMapDemo

