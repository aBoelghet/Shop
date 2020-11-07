//
//  GSCountryViewController.swift
//  PickZyShoppingApp
//
//  Created by Mac Mini 01 on 12/06/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import SDWebImage

protocol CountrySelectedDelegate {
    func countrySelectedWith(_ name:String, imageUrl:String)
}

class GSCountryViewController: GSPaymentViewController {
    
    @IBOutlet weak var navigationBar_view:NavigationWithSearchBar!
    @IBOutlet weak var country_tableView:UITableView!
    
    var countryListData_array = [[String : Any]]()
    var country_array = Dictionary<String, Any>()
    var sectionTitle_array = [String]()
    
    var countryListData = [GSCountryListDataClassElement]()
    var countryListDictionary = [String:[GSCountryListDataClassElement]]()
    var delegate:CountrySelectedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFewInitializers()
        countryApi()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- User defined methods
    
    private func addFewInitializers() {
        
        navigationBar_view.delegate = self
        navigationBar_view.navigSearchBar.delegate = self
        navigationBar_view.cartIconView.isHidden = true
        country_tableView.dataSource = self
        country_tableView.delegate = self
        country_tableView.sectionIndexColor = UIColor(hexString: defaultTheme.countryList_sideIndex_text)
        
        let dataDictionary = self.dataFromPlist("Country")
        countryListData_array = dataDictionary.value(forKey: "result") as! [[String : Any]]
        
        country_array = Dictionary(grouping: countryListData_array, by: { value -> String in
            let someThing = value["name"] as! String
            return "\(someThing.first!)"
        })
        
        sectionTitle_array = country_array.keys.sorted()
        
            country_tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
    }
    
}

extension GSCountryViewController:UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sectionTitle_array.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionChar = sectionTitle_array[section]
        guard let dictAtSection = countryListDictionary[sectionChar] else {return 0}
        return dictAtSection.count
        
        //        return countryListData.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sectionTitle_array[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = GSString.CellIdentifier.CountryVC_country_tableCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? GSCountryListTableCell else {
            return UITableViewCell()
        }
        let sectionChar = sectionTitle_array[indexPath.section]
        if let arrayAtSection = countryListDictionary[sectionChar] {
            //
            //        let theRowValue = arrayAtSection[indexPath.row]
            
            let itemAtIndex = arrayAtSection[indexPath.row]
            
            cell.countryName_lbl.text = itemAtIndex.name
//            let imageUrl = URL(string: "http://www.geognos.com/api/en/countries/flag/\(itemAtIndex.alpha2Code).png")
            guard let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String else {
                print("Unique Id is nil...")
                return UITableViewCell()
            }
            SDWebImageDownloader.shared.setValue(accessToken, forHTTPHeaderField: "Authorization")
            let imageUrl = URL(string: "https://www.countryflags.io/\(itemAtIndex.alpha2Code)/flat/64.png")
            cell.countryIcon_imageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: .progressiveLoad, completed: nil)

        }
        
        
        //        do {
        //            let imageData = try Data(contentsOf: URL(string: itemAtIndex.flag)!)
        //            cell.countryIcon_imageView.image = UIImage(data: imageData)
        //        } catch{
        //            print(error)
        //        }
        
        return cell
    }
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //
    //        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
    //
    //        return headerView
    //    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //        return 0.075 * self.view.frame.height
        return 60
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //        navigationController?.popViewController(animated: true)
        
        let sectionChar = sectionTitle_array[indexPath.section]
        guard let arrayAtSection = countryListDictionary[sectionChar] else {return}
        
        let theRowValue = arrayAtSection[indexPath.row]
        let selCountryName = theRowValue.name
        delegate?.countrySelectedWith(selCountryName, imageUrl: "https://www.countryflags.io/\(theRowValue.alpha2Code)/flat/64.png")
        GSCustomPushPop.doCustomPop(from: self)
    }
    
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitle_array
    }
    
}

extension GSCountryViewController:UISearchBarDelegate {
    // MARK: - Search Bar delegate Methods
    
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
        
        if countryListDictionary.count > 0 {
            countryListDictionary.removeAll()
        }
        
        if searchText.count > 0 {
            
            let someFilteredArray = countryListData.filter { item -> Bool in
                let countryName = item.name as NSString
                let range = countryName.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            }
            countryListDictionary = Dictionary(grouping: someFilteredArray, by: { element -> String in
                guard let firsStr = element.name.first else { return ""}
                return "\(firsStr)"
            })
            
        } else {
            countryListDictionary = Dictionary(grouping: self.countryListData, by: { (element) -> String in
                
                guard let firsStr = element.name.first else { return ""}
                return "\(firsStr)"
            })
        }
        sectionTitle_array = countryListDictionary.keys.sorted()
        country_tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        country_tableView.reloadData()
    }
}

extension GSCountryViewController {
    
    func countryApi() {
            
        APIHandler.NetworkSetupRequest(method: .get, params: nil, urlString: APIurl.countryListURL, headers: [:], withLoader:true) { (response, error) in
            
            do {
                guard let responseData = response else {return}
                
                let jsonDecoder = JSONDecoder()
                let listData = try jsonDecoder.decode(GSCountryListDataClass.self, from: responseData)
                
                self.countryListData = listData.sorted(by: { (value1, value2) -> Bool in
                    return value1.name.localizedCaseInsensitiveCompare(value2.name) == ComparisonResult.orderedAscending
                })
                
                self.countryListDictionary = Dictionary(grouping: self.countryListData, by: { (element) -> String in
                    guard let firsStr = element.name.first else { return ""}
                    return "\(firsStr)"
                })
                
                self.sectionTitle_array = Array(self.countryListDictionary.keys).sorted()
                
                self.country_tableView.reloadData()
                
            }  catch {
                print(error)
            }
        }
        
        
    }
}




extension GSCountryViewController:NavigationWithSearchBarDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        //        navigationController?.popViewController(animated: true)
        GSCustomPushPop.doCustomPop(from: self)
    }
    func rightBarBtnPressed(sender:UIButton) {
        
    }
}

class CountryListDataClass: Codable {
    
}

