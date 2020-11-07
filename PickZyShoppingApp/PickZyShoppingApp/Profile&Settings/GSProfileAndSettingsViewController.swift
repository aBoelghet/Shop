//
//  GSProfileViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 3/29/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import GooglePlaces
import SDWebImage

class GSProfileAndSettingsViewController: GSLoggedInBaseViewController {
    
    @IBOutlet weak var navigationBarView: NavigationBarNormal!
    @IBOutlet weak var profAndSettings_tableView:UITableView!
    
    var nearByLowCostSelectedIndex = 0
    
//    var profileData: GSViewProfileData?
//    var addressObj_array = [GSViewProfileAddressObject]()
    
    var customProfileData = [GSViewProfileCustomModel]()
    var editAddressPopUp:GSEditAddressPopUpView?
    
    var isEditAddress:Bool = false
    
    // MARK: - Customized Profile Model For easy use
    
    struct GSViewProfileCustomModel {
        let sectionHeader:String?
        let rowItems:Any
        let sectionType:GSViewProfileSectionTypes
    }
    
    enum GSViewProfileSectionTypes {
        case profile
        case address
        case notification
        case signOut
    }
    
    // MARK: - View Controller LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        addFewIntializers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarView.navigationBarReload()
        viewProfileAPI()
    }
    
    // MARK: User defined Methods
    
    func addFewIntializers() {
        navigationBarView.delegate = self
        
        profAndSettings_tableView.delegate = self
        profAndSettings_tableView.dataSource = self
    }
}

// MARK: - API Methods

extension GSProfileAndSettingsViewController {
    
    fileprivate func viewProfileAPI() {

        let urlString = APIurl.baseURL + APIurl.subURL.viewProfile

        APIHandler.NetworkSetupRequest(method: .get, params: nil, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }

            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSViewProfileModel.self, from: responseData)
                    
                    if weakSelf.customProfileData.count > 0 {
                        weakSelf.customProfileData.removeAll()
                    }
                    
                    if let profileData = responseModel.data {
                        let customProfileObj = GSViewProfileCustomModel(sectionHeader: "Profile", rowItems: profileData, sectionType: .profile)
                        weakSelf.customProfileData.append(customProfileObj)
                        
                        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.user.profile_image, value: responseModel.data?.image ?? "")
                    }
                    
                    if let address_array = responseModel.data?.address {
                        let customAddressObject = GSViewProfileCustomModel(sectionHeader: "Favourite delivery locations", rowItems: address_array, sectionType: .address)
                        weakSelf.customProfileData.append(customAddressObject)
                        
                    } else {            // To show the add location option
                        let customAddressObject = GSViewProfileCustomModel(sectionHeader: "Favourite delivery locations", rowItems: [Any](), sectionType: .address)
                        weakSelf.customProfileData.append(customAddressObject)
                    }
                    
                    let notification = GSViewProfileCustomModel(sectionHeader: nil, rowItems: "Notification", sectionType: .notification)
                    let signout = GSViewProfileCustomModel(sectionHeader: nil, rowItems: "Sign Out", sectionType: .signOut)
                    weakSelf.customProfileData.append(notification)
                    weakSelf.customProfileData.append(signout)
                    
                    weakSelf.profAndSettings_tableView.reloadData()

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
    
    fileprivate func removeProfilePhotoAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.removeProfileImage
        
        APIHandler.NetworkSetupRequest(method: .delete, params: nil, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
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
    
    fileprivate func changeProfileImageAPI(selectedImage: UIImage) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.changeProfileImage
        
        let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
        let headers = ["Authorization": accessToken,
                       "Content-Type":"multipart/form-data"]
        
        APIHandler.multiPartNetworkRequestWith(method: .post, multiPartItems: [UIImageJPEGRepresentation(selectedImage, 0.5)!], keyNames: ["image"], fileName: "test.doc", params: nil, urlString: urlString, headers: headers, needToResignKeyboard: true) { [weak self] (response, error) in
            
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
    
    fileprivate func addAddressToProfile(place: GMSPlace) {     // Not using this method as of now.. can delete it later
        
        let urlString = APIurl.baseURL + APIurl.subURL.addAddressToProfile
        
        var street = ""
        var area = ""
        var zipCode:Int32 = 0
        
        if let unwrappedAddressComponents = place.addressComponents {
            
            for component in unwrappedAddressComponents {
                if component.type == "street_number" || component.type == "route" || component.type == "sublocality_level_2" || component.type == "sublocality_level_1" {
                    street = (street == "") ? component.name : (street + ", " + component.name)
                } else if component.type == "postal_code" {
                    zipCode = Int32(component.name) ?? 0
                } else {
                    area = (area == "") ? component.name : (area + ", " + component.name)
                }
            }
        }
        
        let parameters = ["deliveryAddress": ["location": ["type": "Point",
                                                           "coordinates": [place.coordinate.longitude,place.coordinate.latitude]],
                                   "address": ["street": street,
                                               "area": area,
                                               "zipcode": zipCode],
                                   "is_default": false,
                                   "type": "Home"]] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
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
    
    fileprivate func logoutAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.logout
        
        APIHandler.NetworkSetupRequest(method: .get, params: nil, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    let successStatus = responseModel.success ?? false
                    
                    if successStatus {
                        
                        SharedPersistence.removeUserDefaults()
                        menuBar = nil
                        
                        if let welcomeScreen = UIStoryboard(name: GSString.storyboard.LoginSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSWelcomeScreenViewController) as? GSWelcomeScreenViewController {
                            let navigationController = GSBaseNavigationController(rootViewController: welcomeScreen)
                            navigationController.navigationBar.isHidden = true
                            UIApplication.shared.keyWindow?.rootViewController = navigationController
                        }
                        
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

// MARK: - UITableView Methods

extension GSProfileAndSettingsViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return customProfileData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let rowObject = customProfileData[section].rowItems as? [Any] {
            return rowObject.count + 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionItem = customProfileData[indexPath.section]
        
        switch sectionItem.sectionType {
        case .profile:
            return profileCell(indexPath)
        case .address:
            return addressCell(indexPath)
        default:
            return commonTableViewCell(indexPath)
        }
    }
    
    //MARK:- UITableview additional user defined methods
    
    private func profileCell(_ indexPath:IndexPath) -> UITableViewCell {
        
        let cellIdentifier = GSString.CellIdentifier.ProfileAndSettingVC_profSettings_tableCell
        
        guard let cell = profAndSettings_tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? GSProfileSettingTableCell else {
            return UITableViewCell()
        }
        
        let sectionItem = customProfileData[indexPath.section]
        guard let profileData = sectionItem.rowItems as? GSViewProfileData else {
            return UITableViewCell()
        }
        
        cell.profileName_lbl.text = ((profileData.firstName ?? "") == "") ? (profileData.lastName ?? "") : ((profileData.firstName ?? "") + " " + (profileData.lastName ?? ""))
        cell.emailId_lbl.text = profileData.email?.id ?? ""
        cell.phoneNo_lbl.text = (profileData.mobile?.number != nil) ? "\(profileData.mobile!.number!)" : ""
        
        cell.editBtn.addTarget(self, action: #selector(cell_editPhotoAction(_:)), for: .touchUpInside)
        
        var imageUrl:String = ""
        if let imageUrlFromProfile = profileData.image {
            imageUrl = APIurl.baseURL + "/profile/image/view?img=\(imageUrlFromProfile)&format=jpeg&width=\(GSConstant.tumbnailImgHeight)"
        }
        
        let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
        SDWebImageDownloader.shared().setValue(accessToken, forHTTPHeaderField: "Authorization")
        
        cell.profile_imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: #imageLiteral(resourceName: "placeHolderProfile_icon"), options: .progressiveDownload) { (image, error, cache_type, url) in
            cell.profile_imageView.image =  GSCommonHelper.cropToBounds(image: cell.profile_imageView.image!, width: Double(cell.profile_imageView.frame.width), height: Double(cell.profile_imageView.frame.height))
        }
        
        return cell
    }
    
    
    @objc private func cell_editPhotoAction(_ sender:UIButton) {
        
        let buttonPosition = sender.convert(CGPoint.zero, to: profAndSettings_tableView)
        guard let indexPath = profAndSettings_tableView.indexPathForRow(at: buttonPosition) else { return }
        
        guard customProfileData.count > indexPath.section else { return }
        let sectionItem = customProfileData[indexPath.section]
        guard let profileData = sectionItem.rowItems as? GSViewProfileData else { return }
        
        var optionsArray = ["Add / Replace"]
        
        if profileData.image != nil {
            optionsArray.append("Remove")
        }
        
        CustomAlert.showActionSheet(title: "Choose", message: nil, cancelTitle: "Cancel", optionArray: optionsArray, sourceView: sender, in: self) { btnIndex in
            
            if btnIndex == 0 {
                self.addOrReplacePhoto(sender)
            } else {
                self.removeProfilePhotoAPI()
            }
        }
    }
    
    private func addOrReplacePhoto(_ sender:UIButton) {
        
        CustomAlert.showActionSheet(title: "Choose", message: nil, cancelTitle: "Cancel", optionArray: ["Camera", "Photos"], sourceView: sender, in: self) { btnIndex in
            
            if btnIndex == 0 {
                self.openCamera()
            } else {
                self.openPhotosAlbum()
            }
        }
    }
    
    private func openPhotosAlbum() {
        
        if GSCommonHelper.checkForUsagePermission(resourceType: .photoLibrary, viewController: self) == false { return }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    private func openCamera() {
        
        if GSCommonHelper.checkForUsagePermission(resourceType: .camera, viewController: self) == false { return }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.allowsEditing = true
            imagePickerController.sourceType = .camera
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    private func addressCell(_ indexPath:IndexPath) -> UITableViewCell {
        
        guard let address_array = customProfileData[indexPath.section].rowItems as? [GSViewProfileAddressObject] else {
            return UITableViewCell()
        }
        if indexPath.row == address_array.count {
            
            let cellIdentifier = GSString.CellIdentifier.ProfileAndSettingVC_addLoc_tableCell
            
            guard let cell = profAndSettings_tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? GSPSAddLocationTableCell else {
                return GSPSAddLocationTableCell()
            }
            
            return cell
            
        } else {
            let cellIdentifier = GSString.CellIdentifier.ProfileAndSettingVC_favoriteDelLoc_tableCell
            
            guard let cell = profAndSettings_tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? GSPSFavDelLocationTableCell else {
                return GSPSFavDelLocationTableCell()
            }
            let address_item = address_array[indexPath.row]
            
            let addressType = address_item.type ?? ""
            
            cell.delLocTitle_lbl.text = address_item.type ?? ""
            
            var addressIcon = #imageLiteral(resourceName: "ShopDetails_Shop_icon")
            
            switch addressType.lowercased() {
            case "home":
                addressIcon = #imageLiteral(resourceName: "editAddressTypeHome_icon")
                break
            case "work":
                addressIcon = #imageLiteral(resourceName: "editAddressTypeWork_icon")
                break
            default:
                addressIcon = #imageLiteral(resourceName: "ShopDetails_Shop_icon")
                break
            }
            
            cell.delLocIcon_imageView.image = addressIcon
            cell.deleteAddress_btn.tag = indexPath.row
            cell.deleteAddress_btn.addTarget(self, action: #selector(deleteAddressAction(_:)), for: .touchUpInside)
            
            _ = (address_item.address?.zipcode != nil) ? "\(address_item.address!.zipcode!)" : ""
            cell.delLocPlaceMarkName_lbl.text = (address_item.address?.street ?? "") + " " + (address_item.address?.area ?? "")
            
            return cell
        }
        
    }

    private func commonTableViewCell(_ indexPath:IndexPath) -> GSPSCommonTableCell {
        
        let cellIdentifier = "commonPScell"
        
        guard let cell = profAndSettings_tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? GSPSCommonTableCell else {
            return GSPSCommonTableCell()
        }
        
        let sectionItem = customProfileData[indexPath.section]
        guard let rowString = sectionItem.rowItems as? String else {
            return GSPSCommonTableCell()
        }
        cell.title_lbl.text = rowString

        cell.right_imageView.image = nil
        
        if sectionItem.sectionType == .notification {
            cell.right_imageView.image = #imageLiteral(resourceName: "RightArrow")
            cell.icon_imageView.image = #imageLiteral(resourceName: "profile_notification_icon")
        } else if sectionItem.sectionType == .signOut {
            cell.icon_imageView.image = #imageLiteral(resourceName: "profile_signout_icon")
        }
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sectionItem = customProfileData[indexPath.section]
        
        switch sectionItem.sectionType {
        case .profile:
            
            if let profSettings = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
                .instantiateViewController(withIdentifier: GSString.Push.GSProfileEditViewController) as? GSProfileEditViewController {
                
                if let profile = sectionItem.rowItems as? GSViewProfileData {
                    profSettings.profileObject = profile
                }
                if let navigator = navigationController {
                    navigator.pushViewController(profSettings, animated: true)
                }
            }
            
            break
        case .address:
            
            guard let address_array = customProfileData[indexPath.section].rowItems as? [GSViewProfileAddressObject] else { return }
            if indexPath.row == address_array.count {
                
                if let placesAutoCompleteVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSPlacesAutoCompleteViewController) as? GSPlacesAutoCompleteViewController {
                    placesAutoCompleteVC.delegate = self
                    placesAutoCompleteVC.isFromProfileView = true
                    GSCustomPushPop.doCustomPush(from: self, to: placesAutoCompleteVC)
                }
                
            } else {
                
                let itemAtIndex = address_array[indexPath.row]
                
                if editAddressPopUp != nil {
                    if editAddressPopUp!.isDescendant(of: self.view) {
                        return
                    }
                    editAddressPopUp = nil
                }
                editAddressPopUp = GSEditAddressPopUpView()
                editAddressPopUp?.delegate = self
                editAddressPopUp?.configureWith(addressObj: itemAtIndex)
                editAddressPopUp!.showTheViewFromBottom(on: self.view, for: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom), completionHandler: {
                    
                    self.editAddressPopUp?.setTextViewHeightBasedOnContent()
                })
                
            }
            
            break
        case .notification:
            
            if let notSettings = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
                .instantiateViewController(withIdentifier: GSString.Push.GSNotificationSettingsViewController) as? GSNotificationSettingsViewController {
                
                guard let profile = customProfileData[0].rowItems as? GSViewProfileData else { return }
                notSettings.settingsData = profile.setting
                
                if let navigator = navigationController {
                    navigator.pushViewController(notSettings, animated: true)
                }
            }
            
            break
        case .signOut:
            
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.sureSignout, alertButtonsArray: ["No","Yes"], isLastButtonDestructive: true, viewController: self) { btnIndex in
                
                if btnIndex == 1 {
                    self.logoutAPI()
                }
            }
            
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let sectionItem = customProfileData[indexPath.section]
        
        switch sectionItem.sectionType {
            
        case .profile:
            return UITableViewAutomaticDimension
            
        case .address:
            if let address_array = customProfileData[indexPath.section].rowItems as? [GSViewProfileAddressObject] {
                if indexPath.row == address_array.count {
                    return 55.0
                }
            }
            
            return UITableViewAutomaticDimension
            
        default:
            return 55.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let sectionItem = customProfileData[section]
        if sectionItem.sectionHeader == nil {
            return 8.0
        }
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionItem = customProfileData[section]
        if sectionItem.sectionHeader == nil {
            return UIView()
        }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30.0))
        headerView.backgroundColor = UIColor.clear
        
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 0, width: headerView.frame.size.width - 10.0, height: headerView.frame.size.height))
        headerLabel.textColor = UIColor(hexString: defaultTheme.profileAndSettings_header_title)
        headerView.addSubview(headerLabel)
        
        headerLabel.text = sectionItem.sectionHeader
        
        return headerView
    }
    
    // MARK: - Cell Action Methods
    
    @objc private func deleteAddressAction(_ sender:UIButton) {
        
        CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.deleteAddress, alertButtonsArray: ["No","Yes"], isLastButtonDestructive: true, viewController: self) { btnIndex in
            if btnIndex == 1 {
                
                let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to: self.profAndSettings_tableView)
                guard let indexPath = self.profAndSettings_tableView.indexPathForRow(at: buttonPosition) else { return }
                
                guard let address_array = self.customProfileData[indexPath.section].rowItems as? [GSViewProfileAddressObject] else { return }
                if address_array.count <= indexPath.row { return }
                let itemAtIndex = address_array[indexPath.row]
                self.removeAddressAPI(address_id: itemAtIndex.id ?? "")
            }
        }
    }
    
    // MARK: - UITableView Delete Methods
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//
//        let sectionItem = customProfileData[indexPath.section]
//
//        switch sectionItem.sectionType {
//        case .address:
//            if let address_array = customProfileData[indexPath.section].rowItems as? [GSViewProfileAddressObject] {
//                if indexPath.row == address_array.count {
//                    return false
//                }
//            }
//            return true
//
//        default:
//            return false
//        }
//    }
//
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//
//        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (rowAction, selectedIndexPath) in
//
//            guard let address_array = self.customProfileData[selectedIndexPath.section].rowItems as? [GSViewProfileAddressObject] else { return }
//            if address_array.count <= selectedIndexPath.row { return }
//            let itemAtIndex = address_array[selectedIndexPath.row]
//            self.removeAddressAPI(address_id: itemAtIndex.id ?? "")
//        }
//
//        return [deleteAction]
//    }
}

// MARK: - GSEditAddress Popup Delegate

extension GSProfileAndSettingsViewController: GSEditAddressPopViewDelegate {
    
    func saveAddressWith(editAddressObj: GSEditAddressModel) {
        viewProfileAPI()
    }
}

// MARK: - Places Auto Complete View Controller Delegate

extension GSProfileAndSettingsViewController: GSPlaceAutoCompleteDelegate {
    
    func locationAddressSelected() {
        viewProfileAPI()
    }
}

// MARK: - UIImagePicker Controller Delegate

extension GSProfileAndSettingsViewController:UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
//        if let resultImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            var oriented = resultImage
//
//            if UIDevice.current.userInterfaceIdiom == .pad, picker.sourceType == .camera {
//                oriented = GSCommonHelper.fixOrientation(img: resultImage)
//            }
//            changeProfileImageAPI(selectedImage: oriented)
//
//        } else {
//            // Need to manage this case
//        }
        
        if let selectedImage = UIImage.from(info: info) {
            
            var oriented = selectedImage
            
//            if UIDevice.current.userInterfaceIdiom == .pad, picker.sourceType == .camera {
//                oriented = GSCommonHelper.fixOrientation(img: selectedImage)
//            }
            
            oriented = GSCommonHelper.fixOrientation(img: selectedImage)
            changeProfileImageAPI(selectedImage: oriented)


        } else {
            picker.dismiss(animated: true) {
                CustomAlert.showAlert(title: "Error", message: "Unable to fetch the photo", viewController: self)
            }
            return
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Navigation Bar Delegate Methods

extension GSProfileAndSettingsViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        addSideMenu()
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
    }
}

