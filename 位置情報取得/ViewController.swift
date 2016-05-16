//
//  ViewController.swift
//  位置情報取得
//
//  Created by HARADA REO on 2016/05/03.
//  Copyright © 2016年 reo harada. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var myLocationManager: CLLocationManager!
    
    var data: [String] = [
        "東京タワー",
        "埼玉県さいたま市南区文蔵",
        "東京ミッドタウン",
        "テレビ朝日",
        "Apple.inc",
        "日比谷駅",
        "中目黒",
    ]
    
    var coors: [CLLocationCoordinate2D] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        self.mapView.delegate = self
        
        let security = CLLocationManager.authorizationStatus()
        print(security)
        
        if security == CLAuthorizationStatus.NotDetermined {
            myLocationManager.requestAlwaysAuthorization()
        }
        
        myLocationManager.distanceFilter = 100
        
        myLocationManager.startUpdatingLocation()
        self.mapView.userTrackingMode = MKUserTrackingMode.Follow
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print(status)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latitude = manager.location?.coordinate.latitude
        let longitude = manager.location?.coordinate.longitude
        let messeage = "緯度は\(latitude!)\n軽度は\(longitude!)です"

        let nowCordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        self.coors.append(nowCordinate)
        let mkPolyLine = MKPolyline(coordinates: &self.coors, count: self.coors.count)
        self.mapView.addOverlay(mkPolyLine)
        
        /*let alert = UIAlertController(title: "現在地", message: messeage, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
//        self.presentViewController(alert, animated: true, completion: nil)*/
        var cr = self.mapView.region;
        // 東京スカイツリーの座標
        cr.center = (manager.location?.coordinate)!
        // 縮尺　0.01
        cr.span = self.mapView.region.span//MKCoordinateSpanMake(0.001, 0.001);
        self.mapView.setRegion(cr, animated: true)
        
        // ジオコーディング
        self.data.forEach { (val) -> () in
            let myGeoCoding = CLGeocoder()
            let address = val
            myGeoCoding.geocodeAddressString(address) { (values, error) -> Void in
                if error == nil {
                    let placemaker: CLPlacemark! = values![0]
                    print(placemaker.name)
                    print(placemaker.location?.coordinate.latitude)
                    print(placemaker.location?.coordinate.longitude)
                    let fromCoordinate :CLLocationCoordinate2D = CLLocationCoordinate2DMake((placemaker.location?.coordinate.latitude)!, (placemaker.location?.coordinate.longitude)!)
                    let theRoppongiAnnotation = MKPointAnnotation()
                    theRoppongiAnnotation.coordinate  = fromCoordinate
                    theRoppongiAnnotation.title       = val
                    theRoppongiAnnotation.subtitle    = placemaker.name
                    self.mapView.addAnnotation(theRoppongiAnnotation)
                }
            }
        }
        
        // リバースジオコーディング
        let reverseGeoCoding = CLGeocoder()
        let latitude2 = CLLocationDegrees(35.6655797)
        let longitude2 = CLLocationDegrees(139.7304168)
        reverseGeoCoding.reverseGeocodeLocation(CLLocation(latitude: latitude2, longitude: longitude2)) { (values, error) -> Void in
            if error == nil {
                let placemark: CLPlacemark? = values![0]
                print(placemark?.name)
                print(placemark?.locality)
                print(placemark?.areasOfInterest)
            }
        }
        
        let myCircle: MKCircle = MKCircle(centerCoordinate: (manager.location?.coordinate)!, radius: CLLocationDistance(100))
        self.mapView.addOverlay(myCircle)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("エラー")
        print(error)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        print(overlay)
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        else {
            let myCircleView: MKCircleRenderer = MKCircleRenderer(overlay: overlay)
            myCircleView.fillColor = UIColor.redColor()
            myCircleView.strokeColor = UIColor.blueColor()
            myCircleView.alpha = 0.1
            myCircleView.lineWidth = 1.5
            return myCircleView
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapGetLocationButton(sender: AnyObject) {
        myLocationManager.startUpdatingLocation()
    }

}

