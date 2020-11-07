//
//  LocationVC.swift
//  SampleDesigns
//
//  Created by Ratheesh TR on 2/19/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import UIKit
import HNKGooglePlacesAutocomplete
import CoreLocation

protocol LocationSelectionDelegate {
    func selectedPlaceMarkAddress(address:String, index:Int)
}

class GSLocationVC: GSBaseViewController {
    
    @IBOutlet weak var navigationBarView: NavigationBarNormal!
    @IBOutlet var locSearchBar: UISearchBar!
    @IBOutlet var locTableView: UITableView!
    
    var locDelegate:LocationSelectionDelegate?
    
    var searchQuery:HNKGooglePlacesAutocompleteQuery!
    var searchResults = NSArray()
    
    var recentHistory = NSMutableArray()
    var searchResFromRecent = NSMutableArray()
    
    var textFieldIndex:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addFewIntializers()

        recentHistory = SharedPersistence.getRecentLocationList().mutableCopy() as! NSMutableArray
        
        if recentHistory.count > 0 {
            locTableView.isHidden = false
        }
        
        searchResFromRecent = recentHistory.mutableCopy() as! NSMutableArray
        searchResults = searchResFromRecent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - User Defined methods
    
    func addFewIntializers() {
        
        locTableView.delegate = self
        locTableView.dataSource = self
        locSearchBar.delegate = self
        
        navigationBarView.delegate = self
        navigationBarView.titleLable.text = GSString.NavBarTitle.PickzyShops
        
        searchQuery = HNKGooglePlacesAutocompleteQuery.shared()
        locTableView.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        let textField = locSearchBar.value(forKey: "_searchField") as! UITextField
        textField.clearButtonMode = .never
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        locSearchBar.showsCancelButton = false
    }
 
    func saveTheSelectedPlace(_ selectedPlace:HNKGooglePlacesAutocompletePlace){
        
        if recentHistory.contains(selectedPlace) {
            return
        }
        recentHistory.add(selectedPlace)
        SharedPersistence.storeRecentLocationList(locationList: recentHistory)
    }
    
    func searchFromRecentLocations(searchText:String) {
        
        if searchResFromRecent.count > 0 {
            searchResFromRecent.removeAllObjects()
        }
        
//        let localArray = recentHistory.filter({ (thisPlace) -> Bool in
//
//            let place = thisPlace as! HNKGooglePlacesAutocompletePlace
//            let tmp = place.name! as NSString
//            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
//            return range.location != NSNotFound
//        }) as! NSMutableArray
        
        let localArray = NSMutableArray(array: recentHistory.filter({ (thisPlace) -> Bool in
            
            let place = thisPlace as! HNKGooglePlacesAutocompletePlace
            let tmp = place.name! as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        }))
        
        searchResFromRecent = localArray.mutableCopy() as! NSMutableArray

    }
    
}

extension GSLocationVC:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "placeCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? GSLocationTableCell else {
            return UITableViewCell()
        }
        
        let thisPlace = searchResults[indexPath.row] as! HNKGooglePlacesAutocompletePlace
        let isHistory:Bool = recentHistory.contains(thisPlace)
        
        cell.configureTheCell(locationName: thisPlace.name, isHistory: isHistory)
        
        return cell
    }
}

extension GSLocationVC:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        loader.show()
        
        DispatchQueue.global().async { [weak weakSelf = self] in
            let selectedPlace = weakSelf?.searchResults[indexPath.row] as! HNKGooglePlacesAutocompletePlace
            weakSelf?.saveTheSelectedPlace(selectedPlace)
            CLPlacemark.hnk_placemark(fromGooglePlace: selectedPlace, apiKey: self.searchQuery.apiKey, completion: {(placemark, addressString, error) in

                if (placemark != nil) {
                    weakSelf?.getPlaceMarkInfo(addressString!)
                    
                } else {
                    weakSelf?.loader.hide()
                    if let theError = error {
                        print("\(theError.localizedDescription)")
                    }
                    if let theWeakSelf = weakSelf {
                    CustomAlert.showAlert(title: "Error", message: GSString.API.NetworkFailure, viewController: theWeakSelf)
                    }
                }
                
            })
            
            DispatchQueue.main.async {
                weakSelf?.locSearchBar.text = ""
                weakSelf?.locSearchBar.resignFirstResponder()
                weakSelf?.locTableView.isHidden = true
            }
        }
    }
}

extension GSLocationVC {
    
    func getPlaceMarkInfo(_ placeName:String) {
    
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(placeName, completionHandler: {[weak weakSelf = self] placeMarks, error in
            
            weakSelf?.loader.hide()
            
            if(error != nil) {
                if let theWeakSelf = weakSelf {
                //CustomAlert.showAlert(title: "Error", message: "\(error!.localizedDescription)", viewController: theWeakSelf)
                    CustomAlert.showAlert(title: "Error", message: GSString.API.NetworkFailure, viewController: theWeakSelf)
                    print("\(error!.localizedDescription)")
                }
            } else {
                
                let placeMark = placeMarks?.last
                
                var addressString : String = ""
                if placeMark?.subLocality != nil {
                    addressString = addressString + (placeMark?.subLocality!)! + ", "
                }
                if placeMark?.thoroughfare != nil {
                    addressString = addressString + (placeMark?.thoroughfare!)! + ", "
                }
                if placeMark?.locality != nil {
                    addressString = addressString + (placeMark?.locality!)! + ", "
                } else {
                    addressString = addressString + (placeMark?.name!)! + ", "
                }
                if placeMark?.country != nil {
                    addressString = addressString + (placeMark?.country!)! + ", "
                }
                if placeMark?.postalCode != nil {
                    addressString = addressString + (placeMark?.postalCode!)! + " "
                }
                
                print("Longitude - \((placeMark?.location?.coordinate.longitude)!)  \nLattitude - \((placeMark?.location?.coordinate.latitude)!)")
                
                weakSelf?.locDelegate?.selectedPlaceMarkAddress(address: addressString, index: (weakSelf?.textFieldIndex)!)
//                self.navigationController?.popViewController(animated: true)
//                weakSelf?.dismiss(animated: true, completion: nil)
                GSCustomPushPop.doCustomPop()
                
            }
        })
        
    }
    
}

extension GSLocationVC:UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        locSearchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        locSearchBar.showsCancelButton = false
        
        var searchBarTextField:UITextField? = nil
        
        for mainView:UIView in searchBar.subviews {
            for subView:UIView in mainView.subviews {
                
                if subView.isKind(of: UITextField.self) {
                    searchBarTextField = subView as? UITextField
                    break
                }
                
            }
        }
        searchBar.enablesReturnKeyAutomatically = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count > 0 {
            locTableView.isHidden = false
            
            searchFromRecentLocations(searchText: searchText)
            
            searchQuery.fetchPlaces(forSearch: searchText, completion: {[weak weakSelf = self] places , error -> Void in
                
                if (error != nil) {
                    if let theWeakSelf = weakSelf {
                    CustomAlert.showAlert(title: "", message: GSString.API.NetworkFailure, viewController: theWeakSelf)
                        print("\(error!.localizedDescription)")
                    }
                    
                } else {
                    
                    guard weakSelf != nil else { return}
                    
                    if ((weakSelf?.searchResFromRecent.count)! > 0) {
                        
                        weakSelf?.searchResFromRecent.addObjects(from: places!)
                        let someArray = Array(NSOrderedSet(array: weakSelf?.searchResFromRecent as! [HNKGooglePlacesAutocompletePlace])) as! NSMutableArray
                        
                        weakSelf?.searchResults = someArray
                        
                    } else {
                        weakSelf?.searchResults = places! as NSArray
                    }
                    weakSelf?.locTableView.reloadData()
                }
            })
        } else {
            if searchResFromRecent.count > 0 {
                searchResFromRecent.removeAllObjects()
                searchResFromRecent = recentHistory.mutableCopy() as! NSMutableArray
            }
            searchResults = searchResFromRecent
            self.locTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        locTableView.isHidden = true
        locTableView.reloadData()
    }
}

extension GSLocationVC:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        //dismiss(animated: true, completion: nil)

        GSCustomPushPop.doCustomPop()
    }
    func rightBarBtnPressed(sender: UIButton) {
        
    }
}


