//
//  GSTrackOrderMapViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 4/2/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import MapKit

class GSTrackOrderMapViewController: GSLoggedInBaseViewController {
    
    @IBOutlet weak var navigationBarView: NavigationBarNormal!
    @IBOutlet weak var deliveryTime_lbl:GSBaseLabel!
    @IBOutlet weak var deliveryDistance_lbl: GSBaseLabel!
    @IBOutlet weak var address_lbl: GSBaseLabel!
    @IBOutlet weak var orderCount_lbl: GSBaseLabel!
    @IBOutlet weak var shop_imageView: UIImageView!
    @IBOutlet weak var mapView:GMSMapView!
    @IBOutlet weak var main_scrollView:UIScrollView!
    @IBOutlet weak var scrollContent_view:UIView!
    @IBOutlet weak var info_lbl: GSBaseLabel!
    @IBOutlet weak var deliveryTime_stackView: UIStackView!
    
    var arrayOfMarkers = [GMSMarker]()
    
    var category_id = ""
    var store_id = ""
    var order_id = ""
    
    var orderObjectFromAPI: GSOrderTrackViewLocationOrder?
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyColors()
        addFewIntializers()
        trackOrderMapViewAPI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        
        main_scrollView.contentSize = CGSize(width: main_scrollView.frame.size.width, height: mapView.frame.origin.y + mapView.frame.size.height)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mapView.clear()
    }
    
    // MARK: - Initializing with Data
    
    func configureWith(categoryId:String?, storeId:String?, orderId:String?) {
        self.category_id = categoryId ?? ""
        self.store_id = storeId ?? ""
        self.order_id = orderId ?? ""
    }
    

    // MARK: - Colors For UI
    
    private func applyColors() {
        
        scrollContent_view.backgroundColor = UIColor(hexString: defaultTheme.trackOrderMap_content_BG)
        orderCount_lbl.textColor = UIColor(hexString: defaultTheme.trackOrderMap_orderCount_text)
        address_lbl.textColor = UIColor(hexString: defaultTheme.trackOrderMap_info_text)
        deliveryTime_lbl.textColor = UIColor(hexString: defaultTheme.trackOrderMap_deliveryTime_text)
        deliveryDistance_lbl.textColor = UIColor(hexString: defaultTheme.trackOrderMap_deliveryDist_text)
        
    }
    
    // MARK: User defined Methods
    
    func addFewIntializers() {
        
        navigationBarView.delegate = self
        deliveryTime_stackView.isHidden = true      // As of now dont require delivery time
        
        navigationBarView.titleText = ""
        
        main_scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)

        mapView.isUserInteractionEnabled = false
    }
    
    @IBAction func openInMapsAction(_ sender: UIButton) {
        
        guard let shopLocationCoOrdinates = orderObjectFromAPI?.shop?.location?.coordinates , shopLocationCoOrdinates.count > 1 else { return }
        
        let sourceLatitude = shopLocationCoOrdinates[1]
        let sourceLongitude = shopLocationCoOrdinates[0]
        
//        guard let deliveryLocationCoOrdinates = orderObjectFromAPI?.delivery?.location?.coordinates, deliveryLocationCoOrdinates.count > 1 else { return }
//            let delLatitude = deliveryLocationCoOrdinates[1]
//            let delLongitude = deliveryLocationCoOrdinates[0]
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            
            UIApplication.shared.open(URL(string:
                "comgooglemaps://?saddr=&daddr=\(sourceLatitude),\(sourceLongitude)&directionsmode=driving")!, options: [:], completionHandler: nil)
            
        } else {
            print("Can't use comgooglemaps://")
            
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(sourceLatitude, sourceLongitude)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "Store Address"
            mapItem.openInMaps(launchOptions: options)
        }
        
    }
    fileprivate func updateUIWithTheResponse(orderObject: GSOrderTrackViewLocationOrder) {
        
        let orderCount = orderObject.products ?? 0
        info_lbl.text = "Your \(orderCount) item(s) delivered from below shop"
        orderCount_lbl.text = "\(orderCount)"
        
        navigationBarView.titleText = orderObject.shop?.name ?? ""
        
        let distance = orderObject.distance ?? 0
//        if distance == 0 {
//            deliveryDistance_lbl.text = ""
//        } else {
//            deliveryDistance_lbl.text = "\(distance)" + " Km"
//        }
        
        deliveryDistance_lbl.text = GSCommonHelper.formattedDouble(double: distance) + " Km"
        address_lbl.text = orderObject.shop?.address ?? ""
        unwrapDataForMapToShow(orderObject: orderObject)
    }
    
    private func unwrapDataForMapToShow(orderObject: GSOrderTrackViewLocationOrder) {
        
        let distance = orderObject.distance ?? 0
        
        guard let shopLocationCoOrdinates = orderObject.shop?.location?.coordinates , shopLocationCoOrdinates.count > 1 else { return }
        
        mapView.isUserInteractionEnabled = true
        
        
        let sourceLatitude = shopLocationCoOrdinates[1]
        let sourceLongitude = shopLocationCoOrdinates[0]
        
        if distance == 0 {
            addGoogleMapsToMapView(lat: sourceLatitude, long: sourceLongitude, title: "Shop location")
            
        } else {
            
            if let deliveryLocationCoOrdinates = orderObject.delivery?.location?.coordinates, deliveryLocationCoOrdinates.count > 1 {
                let delLatitude = deliveryLocationCoOrdinates[1]
                let delLongitude = deliveryLocationCoOrdinates[0]
                
                drawPathTo(desLat: delLatitude, desLong: delLongitude, sourceLat: sourceLatitude, sourceLong: sourceLongitude)
            }
        }
    }
    
    private func addGoogleMapsToMapView(lat:Double, long:Double, title:String) {
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 300.0)
        mapView.camera = camera

        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.title = title
        marker.snippet = ""
        marker.map = mapView
        marker.icon = #imageLiteral(resourceName: "trackOrderShop_icon")

        arrayOfMarkers.append(marker)
    }
    
    private func drawPathTo(desLat:Double, desLong:Double, sourceLat:Double, sourceLong:Double) {
        let origin = "\(sourceLat),\(sourceLong)"
        let destination = "\(desLat),\(desLong)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(AppKeys.Google_Directions)"
        
        AF.request(url).responseJSON { [weak self] response in

            if self == nil { return }
            if self?.isVisible == false { return }
            
            do {
                let parsedData = try JSONSerialization.jsonObject(with: response.data!) as! [String:Any]
                
                let routes = parsedData["routes"] as! [AnyObject]
                
                for route in routes {
                    
                    let routeOverviewPolyline = route["overview_polyline"] as! [String:Any]
                    let points = routeOverviewPolyline["points"] as! String
                    let path = GMSPath.init(fromEncodedPath: points)
                    let polyline = GMSPolyline.init(path: path)
                    polyline.strokeWidth = 2.0
                    polyline.map = self?.mapView
                 }
                
                // Creates a marker in the center of the map.
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: sourceLat, longitude: sourceLong)
                marker.title = "Shop Location"
                marker.snippet = ""
                marker.map = self?.mapView
                marker.icon = #imageLiteral(resourceName: "trackOrderShop_icon")
                
                let destMarker = GMSMarker()
                destMarker.position = CLLocationCoordinate2D(latitude: desLat, longitude: desLong)
                destMarker.title = "Your delivery location."
                destMarker.snippet = ""
                destMarker.map = self?.mapView
                destMarker.icon = #imageLiteral(resourceName: "trackOrderDelivery_icon")
                
                self?.arrayOfMarkers.append(marker)
                self?.arrayOfMarkers.append(destMarker)
                
                var bounds = GMSCoordinateBounds()
                for marker in (self?.arrayOfMarkers)! {
                    bounds = bounds.includingCoordinate(marker.position)
                }
                let update = GMSCameraUpdate.fit(bounds, withPadding: 60)
                self?.mapView.animate(with: update)
                
            } catch let error as NSError {
                print(error)
            }
        }
    }
}

// MARK: - API Methods

extension GSTrackOrderMapViewController {
    
    fileprivate func trackOrderMapViewAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.viewLocationOfProducts
        
        let parameters = ["category_id": category_id,
                          "shop_id": store_id,
                          "order_id": order_id] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            if weakSelf.isVisible == false { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSOrderTrackViewLocationModel.self, from: responseData)
                    
                    if let order_object = responseModel.data?.order {
                        weakSelf.orderObjectFromAPI = order_object
                        
                        weakSelf.updateUIWithTheResponse(orderObject: order_object)
                    }
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? GSString.API.unknownError, viewController: weakSelf)
            }
        }
    }
}

// MARK: - Navigation Bar Delegate Methods
extension GSTrackOrderMapViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
    }
}
