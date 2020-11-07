//
//  GSPlacesAutoCompleteViewController.swift
//  PickZyShoppingApp
//
//  Created by Purushoth on 29/09/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation

protocol GSPlaceAutoCompleteDelegate: class {
    func locationAddressSelected()
}

class GSPlacesAutoCompleteViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: NavigationWithSearchBar!
    @IBOutlet weak var placesTable: UITableView!
    
    var placePredictions = [GMSAutocompletePrediction]()
    var type : Int!
    var isFromProfileView = false
    weak var delegate: GSPlaceAutoCompleteDelegate?
    
    var locationManger : CLLocationManager?
    var editAddressPopUp:GSEditAddressPopUpView?
    var savedAddress_array = [GSPrefferedLocationsModel]()
    
    struct GSPrefferedLocationsModel {
        let address_obj:GSViewProfileAddressObject
        let type: GSPrefferedLocationTypes
    }
    enum GSPrefferedLocationTypes {
        case address
        case autoDetect
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // We don't need to show the saved addresses when comes from profile view as we are already showing them in the profile view.
        if !isFromProfileView {
            
            let isGuestLogin = SharedPersistence.getValue(key: UserDefaultKeys.isGuestUserLogin) as? Bool ?? false
            if !isGuestLogin {
                viewProfileAPI()
            } else {
                
                if self.savedAddress_array.count > 0 {
                    self.savedAddress_array.removeAll()
                }
                
                let locationAuthorizationStatus = CLLocationManager.authorizationStatus()
                if locationAuthorizationStatus == .authorizedAlways || locationAuthorizationStatus == .authorizedWhenInUse {
                    self.savedAddress_array.append(GSPrefferedLocationsModel(address_obj: GSViewProfileAddressObject(location: nil, address: nil, isDefault: nil, type: nil, id: nil), type: .autoDetect))
                }
            }
        } else {
            
            if self.savedAddress_array.count > 0 {
                self.savedAddress_array.removeAll()
            }
            
            let locationAuthorizationStatus = CLLocationManager.authorizationStatus()
            if locationAuthorizationStatus == .authorizedAlways || locationAuthorizationStatus == .authorizedWhenInUse {
                self.savedAddress_array.append(GSPrefferedLocationsModel(address_obj: GSViewProfileAddressObject(location: nil, address: nil, isDefault: nil, type: nil, id: nil), type: .autoDetect))
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - User defined Methods
    
    func initialize(){
        
        placesTable.dataSource = self
        placesTable.delegate = self
        placesTable.tableFooterView = UIView()
        navigationBar.delegate = self
        navigationBar.cartIconView.isHidden = true
        navigationBar.navigSearchBar.delegate = self
        
        placesTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
            
        if self.type == 0 {
            self.navigationBar.titleLable.text = "Product Search Location"
            
        } else {
            self.navigationBar.titleLable.text = "Delivery Location"
        }
        
        if isFromProfileView {
            self.navigationBar.titleLable.text = "Add Location"
        }
        
        placeAutocomplete()
    }
    
    func getPlaceDetails(placeId : String, isSaveAddress:Bool) {
        
        let placeClient = GMSPlacesClient()
        placeClient.lookUpPlaceID(placeId, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(placeId)")
                return
            }
            
            if isSaveAddress {
                let addressObjectToSave = self.getTheAddressInRequiredFormat(place: place)
                self.processTheAddressForSave(addressObjectToSave, coordinates: place.coordinate)
                return
            }
            
            if self.type == 0 {
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.searchLongitude, value: place.coordinate.longitude)
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.searchLatitude, value: place.coordinate.latitude)
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.searchPlace, value: (place.name ?? "") + ", " + (place.formattedAddress ?? ""))
                self.navigationBar.titleLable.text = "Search Location"
                
                if SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLat) == nil {
                    self.storeTheAddressComponents(place: place)
                }
            }
            else {
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.deliveryLong, value: place.coordinate.longitude)
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.deliveryLat, value: place.coordinate.latitude)
                
                if (SharedPersistence.getValue(key: UserDefaultKeys.locations.searchPlace) as? String ?? "") == "" {
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.searchLongitude, value: place.coordinate.longitude)
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.searchLatitude, value: place.coordinate.latitude)
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.searchPlace, value: (place.name ?? "") + ", " + (place.formattedAddress ?? ""))
                }
                
                self.storeTheAddressComponents(place: place)
            }
//            self.dismiss(animated: true, completion: nil)
            GSCustomPushPop.doCustomPop(from: self)
            self.delegate?.locationAddressSelected()
        })
    }
    
    private func storeTheAddressComponents(place: GMSPlace) {
        
        SharedPersistence.removeValue(key: UserDefaultKeys.locations.delivery_zipCode)

        let autoCompleteAddress = getTheAddressInRequiredFormat(place: place)
        
        if autoCompleteAddress.zipcode != "" {
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_zipCode, value: autoCompleteAddress.zipcode)
        }
        
        SharedPersistence.removeValue(key: UserDefaultKeys.locations.savedAddressObject)
        
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_unchangeable_address, value: autoCompleteAddress.area)
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_changeable, value: autoCompleteAddress.street)
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.deliveryPlace, value: autoCompleteAddress.full_address)
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_landMark, value: "")
    }
    
    struct GSAutoCompleteAddress {
        let street: String
        let area: String
        let full_address: String
        let zipcode: String
    }
    
    private func getTheAddressInRequiredFormat(place: GMSPlace) -> GSAutoCompleteAddress {
        
        if let unwrappedAddressComponents = place.addressComponents {
            
            var unchangeableLocalAddress = ""
            var changeableLocalAddress = ""
            var zipCode = ""
            
            changeableLocalAddress = (place.name ?? "")
            
            for component in unwrappedAddressComponents {
                
                if component.type == "street_number" || component.type == "route" || component.type == "sublocality_level_2" || component.type == "sublocality_level_1" {
                    // Changeable Address
                    
                    changeableLocalAddress = (changeableLocalAddress == "") ? component.name : (changeableLocalAddress + ", " + component.name)
                    
                } else if component.type == "postal_code" {
                    zipCode = component.name
                } else {
                    // Un Changeable Address
                    if unchangeableLocalAddress.lowercased().contains(component.name.lowercased()) { continue }         // To Remove the duplicates
                    unchangeableLocalAddress = (unchangeableLocalAddress == "") ? component.name : (unchangeableLocalAddress + ", " + component.name)
                }
            }
            
            if changeableLocalAddress.contains(zipCode) {
                changeableLocalAddress = changeableLocalAddress.replacingOccurrences(of: zipCode, with: "")
                changeableLocalAddress = changeableLocalAddress.removeEnclosedWhieteSpace()
            }
            
            if changeableLocalAddress.last == "," {
                changeableLocalAddress.remove(at: changeableLocalAddress.index(before: changeableLocalAddress.endIndex))
            }
            if unchangeableLocalAddress.last == "," {
                unchangeableLocalAddress.remove(at: unchangeableLocalAddress.index(before: unchangeableLocalAddress.endIndex))
            }

            var combinedAddress = ""
            
            if changeableLocalAddress != "" {
                combinedAddress += changeableLocalAddress
                combinedAddress += ", "
            }
            if unchangeableLocalAddress != "" {
                combinedAddress += unchangeableLocalAddress
            }
            
            return GSAutoCompleteAddress(street: changeableLocalAddress, area: unchangeableLocalAddress, full_address: combinedAddress, zipcode: zipCode)
        }
        
        var fullAddress = place.formattedAddress ?? ""
        if fullAddress.contains(place.name ?? "") == false {
            let temp = fullAddress
            fullAddress = (place.name ?? "") + ", " + temp
        }
        return GSAutoCompleteAddress(street: (place.name ?? ""), area: place.formattedAddress ?? "", full_address: fullAddress, zipcode: "")
    }
    
    fileprivate func processTheAddressForSave(_ addressObj:GSAutoCompleteAddress, coordinates:CLLocationCoordinate2D) {
        
        let latitude = coordinates.latitude
        let longitude = coordinates.longitude
        
        view.endEditing(true)
        
        if editAddressPopUp != nil {
            if editAddressPopUp!.isDescendant(of: self.view) {
                return
            }
            editAddressPopUp = nil
        }
        editAddressPopUp = GSEditAddressPopUpView()
        editAddressPopUp?.delegate = self
        editAddressPopUp?.configureWith(street: addressObj.street, area: addressObj.area, landMark:"", zipCode: addressObj.zipcode, coordinate: [longitude,latitude], isAddressConfirmation: false)
        editAddressPopUp!.showTheViewFromBottom(on: self.view, for: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom), completionHandler: {
            self.editAddressPopUp?.setTextViewHeightBasedOnContent()
        })
    }
    
    func placeAutocomplete() {
        let filter = GMSAutocompleteFilter()
        let placeClient = GMSPlacesClient()
        filter.type = .noFilter
        filter.country = "IN"
        placeClient.autocompleteQuery( navigationBar.navigSearchBar.text ?? "", bounds: nil, filter: filter, callback: {(results, error) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
                return
            }
            if let results = results {
                self.placePredictions = results
                self.placesTable.reloadData()
                for result in results {
                    print("Result \(result.attributedFullText) with placeID \(result.placeID)")
                    
                }
            }
        })
    }
}

// MARK: - Edit Address Pop Up Delegate

extension GSPlacesAutoCompleteViewController: GSEditAddressPopViewDelegate {
    
    
    func saveAddressWith(editAddressObj: GSEditAddressModel) {
        
        if isFromProfileView {
            GSCustomPushPop.doCustomPop(from: self)
            delegate?.locationAddressSelected()
        } else {
            
            let locationObject = GSViewProfileLocation(type: "Point", coordinates: editAddressObj.coordinates)
            let address = GSViewProfileAddress(street: editAddressObj.street, area: editAddressObj.area, landmark: editAddressObj.landMark, zipcode: Int(editAddressObj.zipcode))
            
            let addressObject = GSViewProfileAddressObject(location: locationObject, address: address, isDefault: false, type: editAddressObj.type, id: editAddressObj.addressId)
            processTheSavedAddressObjectForSelection(addressObject)
            
//            viewProfileAPI()
        }
    }
}

// MARK: - UITableView Methods

extension GSPlacesAutoCompleteViewController : UITableViewDelegate, UITableViewDataSource, GSPlaceTableCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let searchbar_text = navigationBar.navigSearchBar.text ?? ""
        if savedAddress_array.count > 0 && searchbar_text.count == 0 {
            return savedAddress_array.count
        }
        return placePredictions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.Places_tableCell, for: indexPath) as? GSPlacesTableViewCell else{
            return UITableViewCell()
        }
        
        cell.delegate = self
        cell.save_btn.tag = indexPath.row
        cell.delete_btn.tag = indexPath.row
        cell.saveBtnBG_view.isHidden = true
        cell.deleteBtnBG_view.isHidden = true
        
        let searchbar_text = navigationBar.navigSearchBar.text ?? ""
        if savedAddress_array.count > 0 && searchbar_text.count == 0 {
            
            if savedAddress_array[indexPath.row].type == .autoDetect {
                cell.location_lbl.text = "Auto Select Current location"
                cell.address_lbl.text = "Using GPS"
                cell.icon_imgView.image = #imageLiteral(resourceName: "currentLocation_icon")
                return cell
            }
            
            cell.deleteBtnBG_view.isHidden = false
            cell.location_lbl.text = savedAddress_array[indexPath.row].address_obj.type ?? ""
            
            var address = ""
            let savedItem = savedAddress_array[indexPath.row].address_obj
            if let street = savedItem.address?.street, street != "" {
                address += street
                address = address.removeEnclosedWhieteSpace()
            }
            if let area = savedItem.address?.area, area != "" {
                if address == "" {
                    address += area
                } else {
                    address += (", " + area)
                }
            }
            
            if let zipcode = savedItem.address?.zipcode, zipcode != 0 {
                if address == "" {
                    address += "\(zipcode)"
                } else {
                    address += (", " + "\(zipcode)")
                }
            }
            cell.icon_imgView.image = #imageLiteral(resourceName: "ShopDetails_Shop_icon")
            cell.address_lbl.text = address
            
        } else {
            cell.saveBtnBG_view.isHidden = false
            cell.location_lbl.text = placePredictions[indexPath.row].attributedPrimaryText.string
            cell.address_lbl.text = placePredictions[indexPath.row].attributedSecondaryText?.string
            cell.icon_imgView.image = #imageLiteral(resourceName: "locationPIn")
        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 65
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let searchbar_text = navigationBar.navigSearchBar.text ?? ""
        if savedAddress_array.count > 0 && searchbar_text.count == 0 {          // Saved List Array
            
            if indexPath.row >= savedAddress_array.count { return }
            
            let addressAtIndex = savedAddress_array[indexPath.row]
            
            if addressAtIndex.type == .autoDetect {
                // Will detect the current location
                
                locationManger = CLLocationManager()
                locationManger?.delegate = self
                locationManger?.startUpdatingLocation()
                
            } else {
                
                let address_obj = addressAtIndex.address_obj
                processTheSavedAddressObjectForSelection(address_obj)
            }
            
            return
        }
        
        if isFromProfileView {
            
            if indexPath.row < placePredictions.count {
                getPlaceDetails(placeId: placePredictions[indexPath.row].placeID, isSaveAddress: true)
            }
            
            return
        }
        
        if indexPath.row < placePredictions.count {
            if type == 0 {
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.searchPlace, value: placePredictions[indexPath.row].attributedFullText.string)
            } else {
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.deliveryPlace, value: placePredictions[indexPath.row].attributedFullText.string)
            }
            getPlaceDetails(placeId: placePredictions[indexPath.row].placeID , isSaveAddress: false)
        }
    }
    
    // MARK: - Saved Address Selection
    
    fileprivate func processTheSavedAddressObjectForSelection(_ address_obj: GSViewProfileAddressObject) {
        
        guard let coordinates = address_obj.location?.coordinates else { return }
        guard coordinates.count > 1 else { return }
        let longitude = coordinates[0]
        let latitude = coordinates[1]
        
        var combinedAddress = ""
        var changebleAddress = ""
        var unchangeableAddress = ""
        
        if let street = address_obj.address?.street, street != "" {
            combinedAddress += street
            combinedAddress = combinedAddress.removeEnclosedWhieteSpace()
            changebleAddress = street.removeEnclosedWhieteSpace()
        }
        if let area = address_obj.address?.area, area != "" {
            
            if combinedAddress == "" {
                combinedAddress += area
            } else {
                combinedAddress += ", \(area)"
            }
            combinedAddress = combinedAddress.removeEnclosedWhieteSpace()
            unchangeableAddress = area.removeEnclosedWhieteSpace()
        }
        var zipcode = ""
        
        if let zipCode = address_obj.address?.zipcode, zipCode != 0 {
            zipcode = "\(zipCode)"
            
            if combinedAddress == "" {
                combinedAddress += zipcode
            } else {
                combinedAddress += ", \(zipcode)"
            }
        }
        
        
        if type == 0 {
            
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.searchPlace, value: combinedAddress)
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.searchLatitude, value: latitude)
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.searchLongitude, value: longitude)
            
        } else {
            
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.deliveryPlace, value: combinedAddress)
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.deliveryLat, value: latitude)
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.deliveryLong, value: longitude)
            
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_changeable, value: changebleAddress)
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_unchangeable_address, value: unchangeableAddress)
            
            SharedPersistence.removeValue(key: UserDefaultKeys.locations.delivery_landMark)
            
            if let landMark = address_obj.address?.landmark {
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_landMark, value: landMark)
            }
            
            if let encodedSavedAddress = try? JSONEncoder().encode(address_obj) {
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.savedAddressObject, value: encodedSavedAddress)
            }
            
            if zipcode == "" {
                SharedPersistence.removeValue(key: UserDefaultKeys.locations.delivery_zipCode)
            } else {
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_zipCode, value: zipcode)
            }
        }
        
        //            self.dismiss(animated: true, completion: nil)
        GSCustomPushPop.doCustomPop(from: self)
        delegate?.locationAddressSelected()
    }
    
    
    // MARK: - Place cell Delegate Methods
    
    func saveSelectedAddress(_ sender: UIButton) {
        
        let index = sender.tag
        if index < placePredictions.count {
            getPlaceDetails(placeId: placePredictions[index].placeID, isSaveAddress: true)
        }
    }
    func deleteSelectedAddress(_ sender: UIButton) {
        
        let index = sender.tag
        
        if index < savedAddress_array.count {
            let address_item = savedAddress_array[index]
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.deleteAddress, alertButtonsArray: ["No", "Yes"], isLastButtonDestructive: true, viewController: self) { btnIndex in
                if btnIndex == 1 {
                    self.removeAddressAPI(address_id: address_item.address_obj.id ?? "")
                }
            }
        }
    }
}

// MARK: - Navigation Bar View Delegate Methods

extension GSPlacesAutoCompleteViewController: NavigationWithSearchBarDelegate {
    
    func rightBarBtnPressed(sender: UIButton) {
        
    }
    func leftBarBtnPressed(sender: UIButton) {
        //            self.dismiss(animated: true, completion: nil)
        GSCustomPushPop.doCustomPop(from: self)
    }
}

// MARK: - Core Location Manager Delegate

extension GSPlacesAutoCompleteViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        
        guard let latestLocation = locations.first else { return }
        SharedPersistence.removeValue(key: UserDefaultKeys.locations.savedAddressObject)
        getTheAddressDetailsUsing(latestLocation)
    }
    
    func getTheAddressDetailsUsing(_ latestLoc:CLLocation) {
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(latestLoc, completionHandler: {[weak self] placeMarks, error in
            
            if self == nil { return }
            
            if(error != nil) {
                if let weakSelf = self {
                    CustomAlert.showAlert(title: "Error", message: GSString.API.NetworkFailure, viewController: weakSelf)
                    print("\(error!.localizedDescription)")
                }
            } else {
                
                let placeMark = placeMarks?.last
                guard let coordinates = placeMark?.location?.coordinate else { return }
                
                var addressString : String = ""
                
                var changeableAddress = ""
                var unChangeableAddress = ""
                var zipcode = ""
                
                if placeMark?.subThoroughfare != nil {
                    addressString = addressString + (placeMark?.subThoroughfare!)! + ", "   // Changeable
                    changeableAddress = (changeableAddress == "") ? ((placeMark?.subThoroughfare!) ?? "") : (changeableAddress + ", " + ((placeMark?.subThoroughfare!) ?? ""))
                }
                if placeMark?.thoroughfare != nil {
                    addressString = addressString + (placeMark?.thoroughfare!)! + ", "  // Changeable
                    changeableAddress = (changeableAddress == "") ? ((placeMark?.thoroughfare!) ?? "") : (changeableAddress + ", " + ((placeMark?.thoroughfare!) ?? ""))
                }
                
                if placeMark?.subLocality != nil {
                    addressString = addressString + (placeMark?.subLocality!)! + ", "   // Unchangeable
                    //                    unChangeableAddress = (unChangeableAddress == "") ? ((placeMark?.subLocality!) ?? "") : (unChangeableAddress + ", " + ((placeMark?.subLocality!) ?? ""))
                    changeableAddress = (changeableAddress == "") ? ((placeMark?.subLocality!) ?? "") : (changeableAddress + ", " + ((placeMark?.subLocality!) ?? ""))
                }
                
                if placeMark?.locality != nil {
                    addressString = addressString + (placeMark?.locality!)! + ", "      // Unchangeable
                    unChangeableAddress = (unChangeableAddress == "") ? ((placeMark?.locality!) ?? "") : (unChangeableAddress + ", " + ((placeMark?.locality!) ?? ""))
                }
                if placeMark?.administrativeArea != nil {
                    addressString = addressString + (placeMark?.administrativeArea!)! + ", "      // Unchangeable
                    unChangeableAddress = (unChangeableAddress == "") ? ((placeMark?.administrativeArea!) ?? "") : (unChangeableAddress + ", " + ((placeMark?.administrativeArea!) ?? ""))
                }
                if placeMark?.country != nil {
                    addressString = addressString + (placeMark?.country!)! + ", "       // Unchangeable
                    unChangeableAddress = (unChangeableAddress == "") ? ((placeMark?.country!) ?? "") : (unChangeableAddress + ", " + ((placeMark?.country!) ?? ""))
                }
                if placeMark?.postalCode != nil {
                    addressString = addressString + (placeMark?.postalCode!)! + " "
                    zipcode = placeMark?.postalCode ?? ""
                }
                
                if self?.isFromProfileView == true {
                    
                    let addressObject = GSAutoCompleteAddress(street: changeableAddress, area: unChangeableAddress, full_address: addressString, zipcode: zipcode)
                    self?.processTheAddressForSave(addressObject, coordinates: coordinates)
                    return
                }
                
                if self?.type == 0 {
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.searchPlace, value: addressString)
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.searchLongitude, value: coordinates.longitude)
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.searchLatitude, value: coordinates.latitude)
                    
                } else  {
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.deliveryPlace, value: addressString)
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.deliveryLat, value: coordinates.latitude)
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.deliveryLong, value: coordinates.longitude)
                    
                    if changeableAddress.last == "," {
                        changeableAddress.remove(at: changeableAddress.index(before: changeableAddress.endIndex))
                    }
                    if unChangeableAddress.last == "," {
                        unChangeableAddress.remove(at: unChangeableAddress.index(before: unChangeableAddress.endIndex))
                    }
                    
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_unchangeable_address, value: unChangeableAddress)
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_changeable, value: changeableAddress)
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_landMark, value: "")
                    
                    if let postalCode = placeMark?.postalCode {
                        SharedPersistence.storeUserDefaults(key: postalCode, value: placeMark?.postalCode ?? "")
                    } else {
                        SharedPersistence.removeValue(key: UserDefaultKeys.locations.delivery_zipCode)
                    }
                }
                
                //            self.dismiss(animated: true, completion: nil)
                GSCustomPushPop.doCustomPop(from: self!)
                self?.delegate?.locationAddressSelected()
            }
        })
    }
}

// MARK: - API Methods

extension GSPlacesAutoCompleteViewController {
    
    fileprivate func viewProfileAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.viewProfile
        
        APIHandler.NetworkSetupRequest(method: .get, params: nil, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSViewProfileModel.self, from: responseData)
                    
                    if let address_array = responseModel.data?.address {
                        
                        if weakSelf.savedAddress_array.count > 0 {
                            weakSelf.savedAddress_array.removeAll()
                        }
                        
                        weakSelf.addAutoDetectOption(needReload: false)
                        
                        for address in address_array {
                            let addressObject = GSPrefferedLocationsModel(address_obj: address, type: .address)
                            weakSelf.savedAddress_array.append(addressObject)
                        }
                        
                        if (weakSelf.navigationBar.navigSearchBar.text?.count ?? 0) == 0 {
                            weakSelf.placesTable.reloadData()
                        }
                        
                    } else {
                        weakSelf.addAutoDetectOption(needReload: true)
                    }
                    
                } catch {
                    print(error)
                    weakSelf.addAutoDetectOption(needReload: true)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                weakSelf.addAutoDetectOption(needReload: true)
            }
            
            weakSelf.navigationBar.navigSearchBar.becomeFirstResponder()
        }
    }
    
    private func addAutoDetectOption(needReload:Bool) {
        
        if savedAddress_array.count > 0 {
            savedAddress_array.removeAll()
        }
        
        let locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        if locationAuthorizationStatus == .authorizedAlways || locationAuthorizationStatus == .authorizedWhenInUse {
            savedAddress_array.append(GSPrefferedLocationsModel(address_obj: GSViewProfileAddressObject(location: nil, address: nil, isDefault: nil, type: nil, id: nil), type: .autoDetect))
        }
        
        if needReload && ((navigationBar.navigSearchBar.text?.count ?? 0) == 0) {
            placesTable.reloadData()
        }
    }
    
    fileprivate func removeAddressAPI(address_id:String) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.deleteAddress
        
        let parameters = ["id": address_id] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .delete, params: parameters, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    let successStatus = responseModel.success ?? false
                    
                    if successStatus {
                        weakSelf.viewProfileAPI()
                    } else {
                        CustomAlert.showAlert(title: GSString.AppName, message: responseModel.message ?? "", viewController: weakSelf)
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

// MARK: - UISearchBar Delegate Methods

extension GSPlacesAutoCompleteViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count > 2 {
            placeAutocomplete()
            
        } else if searchText.count == 0 {
            placesTable.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
}

// MARK: - UIScrollView Delegates

extension GSPlacesAutoCompleteViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}




