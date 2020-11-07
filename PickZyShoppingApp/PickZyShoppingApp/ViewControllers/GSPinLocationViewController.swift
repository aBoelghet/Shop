//
//  GSPinLocationViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh on 19/07/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

import GooglePlaces
import GoogleMaps
import MapKit

public typealias PinSelectionCompletion = (_  selAddress: String?) -> Void

class GSPinLocationViewController: UIViewController{
    
    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
    @IBOutlet weak var centerImageIcon: UIImageView!
    @IBOutlet weak var googleMap: GMSMapView!
    @IBOutlet weak var selectedAddress_lbl: GSBaseLabel!
    
    var currentLocation:CLLocationCoordinate2D!
    var finalPositionAfterDragging:CLLocationCoordinate2D?
    var locationMarker:GMSMarker!
    var selCoordinate:CLLocationCoordinate2D!
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        _locationManager.activityType = .automotiveNavigation
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar_view.delegate = self
        googleMap.delegate = self
        centerImageIcon.layer.zPosition = 1
        
//        addPlacePickerController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        checkAndGetUserLocation()
        
        selecedLocFromPrevious()
    }
    
    //MARK: - Closure Method
    
    fileprivate var addressPinSelected:PinSelectionCompletion?
    
    @objc open func addressPinSelected(completion:PinSelectionCompletion?) {
        addressPinSelected = completion
    }
    
    //MARK: - User defined methods
    
    func checkAndGetUserLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse     {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func setupLocationMarker(coordinate: CLLocationCoordinate2D) {
        #if DEBUG
            print("setup location")
        #endif
        if locationMarker != nil {
            locationMarker.map = nil
        }
        locationMarker = GMSMarker(position: coordinate)
        locationMarker.map = googleMap
        locationMarker.appearAnimation =  .pop
        locationMarker.icon = GMSMarker.markerImage(with: UIColor.blue)
        locationMarker.opacity = 0.75
        locationMarker.isFlat = true
    }
    
    func selecedLocFromPrevious() {
        guard selCoordinate != nil else {
            return
        }
        self.currentLocation = CLLocationCoordinate2D(latitude: selCoordinate.latitude,longitude: selCoordinate.longitude)
        let camera = GMSCameraPosition.camera(withLatitude: self.currentLocation.latitude, longitude:currentLocation.longitude, zoom: 300)
        self.googleMap.camera = camera
        self.googleMap?.animate(to: camera)
    }
    
    func addPlacePickerController() {
        let placePickerController = GMSAutocompleteViewController()
        placePickerController.delegate = self
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter  //suitable filter type
        filter.country = Locale.current.regionCode //appropriate country code
        placePickerController.autocompleteFilter = filter
        self.navigationController?.present(placePickerController, animated: true, completion: nil)
    }
    
    //MARK: - Location from dragged point
    
    func wrapperFunctionToShowPosition(mapView:GMSMapView){
        let geocoder = GMSGeocoder()
        let latitute = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        let position = CLLocationCoordinate2DMake(latitute, longitude)
        selectedAddress_lbl.text = "Loading..."
        geocoder.reverseGeocodeCoordinate(position) { response , error in
            if error != nil {
                #if DEBUG
                    print("GMSReverseGeocode Error: \(String(describing: error?.localizedDescription))")
                #endif
                self.selectedAddress_lbl.text = error?.localizedDescription ?? "Something went wrong..."
            } else {
                let result = response?.results()?.first
                let address = result?.lines?.reduce("") { $0 == "" ? $1 : $0 + ", " + $1 }
                #if DEBUG
                    print(address ?? "Nil address")
                #endif
                //                self.searchBar.text = address
                self.selectedAddress_lbl.text = address
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.deliveryLat, value: latitute)
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.deliveryLong, value: longitude)
            }
        }
    }
}

extension GSPinLocationViewController:GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        //        wrapperFunctionToShowPosition(mapView: mapView)
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print("idleAt")
        wrapperFunctionToShowPosition(mapView: mapView)
    }
}

extension GSPinLocationViewController:CLLocationManagerDelegate {
    //this method is called by the framework on  locationManager.requestLocation();
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didupdate location")
        let userLocation:CLLocation = locations[0] as CLLocation
        self.currentLocation = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
        let camera = GMSCameraPosition.camera(withLatitude: self.currentLocation.latitude, longitude:currentLocation.longitude, zoom: 300)
        let position = CLLocationCoordinate2D(latitude:  currentLocation.latitude, longitude: currentLocation.longitude)
        self.setupLocationMarker(coordinate: position)
        self.googleMap.camera = camera
        self.googleMap?.animate(to: camera)
        manager.stopUpdatingLocation()
    }
}

// MARK: - GMSAutoComplete Delegate
extension GSPinLocationViewController: GMSAutocompleteViewControllerDelegate{
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
//        print("Place name: \(place.name)")
//        print("Place address: \(String(describing: place.formattedAddress))")
//        print("Place attributions: \(String(describing: place.attributions))")
        
        //Tag  0  -  Delivery Location Textfield
        //Tag  1  -  Shop Location Textfield'
        
        selCoordinate = place.coordinate
        selecedLocFromPrevious()

        dismiss(animated: true, completion: nil)

    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}


extension GSPinLocationViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
//        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
//        navigationController?.popViewController(animated: true)
//        addMapsOnView()
        addressPinSelected?(selectedAddress_lbl.text)
    }
}
