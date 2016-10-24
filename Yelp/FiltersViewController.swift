//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Carina Boo on 10/20/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate: class {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])

}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate, SelectCellDelegate, ButtonCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FiltersViewControllerDelegate?
    
//    var filterStates = [Int:[Int:Bool]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set UITableView data source and delegate
        tableView.dataSource = self;
        tableView.delegate = self;
        
        // Auto size cells
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Navigation bar styling
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearchButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        
        var selectedFilters = [String : AnyObject]()
        
        // Deals
        if let dealsOn = filters["deals"]![0]["on"] {
            selectedFilters["deals"] = dealsOn as! Bool as AnyObject?
        }
        
        // Distance
        var distanceMode: Int = 0
        for distance in filters["distance"]! {
            if (distance["on"] as! Bool) {
                distanceMode = distance["code"] as! Int
                break
            }
        }
        selectedFilters["distance"] = distanceMode as AnyObject?
        
        // Sort by
        var sortMode: YelpSortMode = YelpSortMode.bestMatched
        for sort in filters["sort"]! {
            if (sort["on"] as! Bool) {
                let sortCode = sort["code"] as! String
                switch sortCode {
                case "default":
                    sortMode = YelpSortMode.bestMatched
                    break
                case "distance":
                    sortMode = YelpSortMode.distance
                    break
                case "high_rating":
                    sortMode = YelpSortMode.highestRated
                    break
                default:
                    break
                }
                break
            }
        }
        selectedFilters["sort"] = sortMode as AnyObject?
        
        // Categories
        var selectedCategories = [String]()
        for category in filters["category"]! {
            if (category["on"] as! Bool) {
                selectedCategories.append(category["code"] as! String)
            }
        }
        if selectedCategories.count > 0 {
            selectedFilters["category"] = selectedCategories as AnyObject?
        }
        
        delegate?.filtersViewController!(filtersViewController: self, didUpdateFilters: selectedFilters)
    }
    
    // MARK: - UITableViewDataSource
    
    // Number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return filters.count
    }
    
    // Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getFilterOptionsBySectionIndex(index: section).count
    }
    
    // Cell for section/row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var optionType = getFilterTypeBySectionIndex(index: indexPath.section)
        let options = getFilterOptionsBySectionIndex(index: indexPath.section)
        let option = options[indexPath.row]

        if let type = option["type"] {
            optionType = type as! String
        }
        if (optionType == "switch") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            cell.optionLabel.text = option["name"] as! String?
            cell.delegate = self
            cell.onSwitch.isOn = getFilterStateAt(sectionIndex: indexPath.section, andRowIndex: indexPath.row)
            return cell
        } else if (optionType == "button") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as! ButtonCell
            cell.button.titleLabel?.text = option["name"] as! String?
//            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCell", for: indexPath) as! SelectCell
            cell.optionLabel.text = option["name"] as! String?
            cell.delegate = self
            return cell
        }
    }
    
    // Section header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //Create label and autoresize it
        let headerLabel = UILabel(frame: CGRect(x: 8, y: 8, width: tableView.frame.width, height: 50))
        headerLabel.font = UIFont(name: "HelveticaNeue", size: 20)
//        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.text = getFilterNameBySectionIndex(index: section)
        headerLabel.sizeToFit()
        
        //Adding Label to existing headerView
        let headerView = UIView()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    // Section header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    // On select row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        if let cell = tableView.cellForRow(at: indexPath) {
//            cell.selectionStyle = .none
//        }
    }
    
    // On deselect row
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) {
//            cell.selectionStyle = .blue
//        }
    }
    
    // MARK: - SwitchCellDelegate
    
    // User tapped switch
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!
        
        setFilterStateAt(sectionIndex: indexPath.section, andRowIndex: indexPath.row, toState: value)
    }
    
    // MARK: - SelectCellDelegate
    
    // User tapped select
    func selectCell(selectCell: SelectCell,
                    didChangeValue value: Bool) {
        
        let indexPath = tableView.indexPath(for: selectCell)!
        
        setFilterStateAt(sectionIndex: indexPath.section, andRowIndex: indexPath.row, toState: value)
    }
    
    // MARK: - Private
    
    var filters: [String:[[String: Any]]] =
        ["deals" : [["name" : "Offering a deal", "on" : false]],
        "distance" : [["name" : "Auto", "code": 0, "on" : false],
                      ["name" : "0.3 miles", "code": 483, "on" : false],
                      ["name" : "1 mile", "code": 1609, "on" : false],
                      ["name" : "5 miles", "code": 8047, "on" : false],
                      ["name" : "20 miles", "code": 32187, "on" : false]],
        "sort" : [["name" : "Best match", "code": "default", "on" : false],
                  ["name" : "Distance", "code": "distance", "on" : false],
                  ["name" : "Highest rated", "code": "high_rating","on" : false]],
        "category": [["name" : "Barbeque", "code": "bbq", "on" : false],
                     ["name" : "Breakfast & Brunch", "code": "breakfast_brunch", "on" : false],
                     ["name" : "Thai", "code": "thai", "on" : false],
                     ["name" : "Vietnamese", "code": "vietnamese", "on" : false],
                     ["name" : "See all categories", "on" : false, "type" : "button"]]]
    
    func getFilterTypeBySectionIndex(index: Int) -> String {
        switch index {
        case 0:
            return "switch"
        case 1:
            return "select"
        case 2:
            return "select"
        case 3:
            return "switch"
        default:
            return "none"
        }
    }
    
    func getFilterNameBySectionIndex(index: Int) -> String {
        switch index {
        case 0:
            return "Deals"
        case 1:
            return "Distance"
        case 2:
            return "Sort"
        case 3:
            return "Category"
        default:
            return "Untitled"
        }
    }
    
    func getFilterOptionsBySectionIndex(index: Int) -> [[String: Any]] {
        switch index {
        case 0:
            return filters["deals"]!
        case 1:
            return filters["distance"]!
        case 2:
            return filters["sort"]!
        case 3:
            return filters["category"]!
        default:
            return [["":""]]
        }
    }
    
    func getOptionBy(sectionIndex: Int, andRowIndex rowIndex: Int) -> [String:Any] {
        var filterOptions = getFilterOptionsBySectionIndex(index: sectionIndex)
        return filterOptions[rowIndex]
    }
    
    func setFilterStateAt(sectionIndex: Int, andRowIndex rowIndex: Int, toState on: Bool) {
        switch sectionIndex {
        case 0:
            filters["deals"]![rowIndex]["on"] = on
        case 1:
            filters["distance"]![rowIndex]["on"] = on
        case 2:
            filters["sort"]![rowIndex]["on"] = on
        case 3:
            filters["category"]![rowIndex]["on"] = on
        default:
            break
        }
//        Passes by value instead of by reference
//        var option = getOptionBy(sectionIndex: sectionIndex, andRowIndex: rowIndex)
//        option["on"] = on
    }
    
    func getFilterStateAt(sectionIndex: Int, andRowIndex rowIndex: Int) -> Bool {
        var option = getOptionBy(sectionIndex: sectionIndex, andRowIndex: rowIndex)
        return option["on"] as! Bool
    }
    
//    let categories: [[String: String]] =
//        [["name" : "Afghan", "code": "afghani"],
//         ["name" : "African", "code": "african"],
//         ["name" : "American, New", "code": "newamerican"],
//         ["name" : "American, Traditional", "code": "tradamerican"],
//         ["name" : "Arabian", "code": "arabian"],
//         ["name" : "Argentine", "code": "argentine"],
//         ["name" : "Armenian", "code": "armenian"],
//         ["name" : "Asian Fusion", "code": "asianfusion"],
//         ["name" : "Asturian", "code": "asturian"],
//         ["name" : "Australian", "code": "australian"],
//         ["name" : "Austrian", "code": "austrian"],
//         ["name" : "Baguettes", "code": "baguettes"],
//         ["name" : "Bangladeshi", "code": "bangladeshi"],
//         ["name" : "Barbeque", "code": "bbq"],
//         ["name" : "Basque", "code": "basque"],
//         ["name" : "Bavarian", "code": "bavarian"],
//         ["name" : "Beer Garden", "code": "beergarden"],
//         ["name" : "Beer Hall", "code": "beerhall"],
//         ["name" : "Beisl", "code": "beisl"],
//         ["name" : "Belgian", "code": "belgian"],
//         ["name" : "Bistros", "code": "bistros"],
//         ["name" : "Black Sea", "code": "blacksea"],
//         ["name" : "Brasseries", "code": "brasseries"],
//         ["name" : "Brazilian", "code": "brazilian"],
//         ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
//         ["name" : "British", "code": "british"],
//         ["name" : "Buffets", "code": "buffets"],
//         ["name" : "Bulgarian", "code": "bulgarian"],
//         ["name" : "Burgers", "code": "burgers"],
//         ["name" : "Burmese", "code": "burmese"],
//         ["name" : "Cafes", "code": "cafes"],
//         ["name" : "Cafeteria", "code": "cafeteria"],
//         ["name" : "Cajun/Creole", "code": "cajun"],
//         ["name" : "Cambodian", "code": "cambodian"],
//         ["name" : "Canadian", "code": "New)"],
//         ["name" : "Canteen", "code": "canteen"],
//         ["name" : "Caribbean", "code": "caribbean"],
//         ["name" : "Catalan", "code": "catalan"],
//         ["name" : "Chech", "code": "chech"],
//         ["name" : "Cheesesteaks", "code": "cheesesteaks"],
//         ["name" : "Chicken Shop", "code": "chickenshop"],
//         ["name" : "Chicken Wings", "code": "chicken_wings"],
//         ["name" : "Chilean", "code": "chilean"],
//         ["name" : "Chinese", "code": "chinese"],
//         ["name" : "Comfort Food", "code": "comfortfood"],
//         ["name" : "Corsican", "code": "corsican"],
//         ["name" : "Creperies", "code": "creperies"],
//         ["name" : "Cuban", "code": "cuban"],
//         ["name" : "Curry Sausage", "code": "currysausage"],
//         ["name" : "Cypriot", "code": "cypriot"],
//         ["name" : "Czech", "code": "czech"],
//         ["name" : "Czech/Slovakian", "code": "czechslovakian"],
//         ["name" : "Danish", "code": "danish"],
//         ["name" : "Delis", "code": "delis"],
//         ["name" : "Diners", "code": "diners"],
//         ["name" : "Dumplings", "code": "dumplings"],
//         ["name" : "Eastern European", "code": "eastern_european"],
//         ["name" : "Ethiopian", "code": "ethiopian"],
//         ["name" : "Fast Food", "code": "hotdogs"],
//         ["name" : "Filipino", "code": "filipino"],
//         ["name" : "Fish & Chips", "code": "fishnchips"],
//         ["name" : "Fondue", "code": "fondue"],
//         ["name" : "Food Court", "code": "food_court"],
//         ["name" : "Food Stands", "code": "foodstands"],
//         ["name" : "French", "code": "french"],
//         ["name" : "French Southwest", "code": "sud_ouest"],
//         ["name" : "Galician", "code": "galician"],
//         ["name" : "Gastropubs", "code": "gastropubs"],
//         ["name" : "Georgian", "code": "georgian"],
//         ["name" : "German", "code": "german"],
//         ["name" : "Giblets", "code": "giblets"],
//         ["name" : "Gluten-Free", "code": "gluten_free"],
//         ["name" : "Greek", "code": "greek"],
//         ["name" : "Halal", "code": "halal"],
//         ["name" : "Hawaiian", "code": "hawaiian"],
//         ["name" : "Heuriger", "code": "heuriger"],
//         ["name" : "Himalayan/Nepalese", "code": "himalayan"],
//         ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
//         ["name" : "Hot Dogs", "code": "hotdog"],
//         ["name" : "Hot Pot", "code": "hotpot"],
//         ["name" : "Hungarian", "code": "hungarian"],
//         ["name" : "Iberian", "code": "iberian"],
//         ["name" : "Indian", "code": "indpak"],
//         ["name" : "Indonesian", "code": "indonesian"],
//         ["name" : "International", "code": "international"],
//         ["name" : "Irish", "code": "irish"],
//         ["name" : "Island Pub", "code": "island_pub"],
//         ["name" : "Israeli", "code": "israeli"],
//         ["name" : "Italian", "code": "italian"],
//         ["name" : "Japanese", "code": "japanese"],
//         ["name" : "Jewish", "code": "jewish"],
//         ["name" : "Kebab", "code": "kebab"],
//         ["name" : "Korean", "code": "korean"],
//         ["name" : "Kosher", "code": "kosher"],
//         ["name" : "Kurdish", "code": "kurdish"],
//         ["name" : "Laos", "code": "laos"],
//         ["name" : "Laotian", "code": "laotian"],
//         ["name" : "Latin American", "code": "latin"],
//         ["name" : "Live/Raw Food", "code": "raw_food"],
//         ["name" : "Lyonnais", "code": "lyonnais"],
//         ["name" : "Malaysian", "code": "malaysian"],
//         ["name" : "Meatballs", "code": "meatballs"],
//         ["name" : "Mediterranean", "code": "mediterranean"],
//         ["name" : "Mexican", "code": "mexican"],
//         ["name" : "Middle Eastern", "code": "mideastern"],
//         ["name" : "Milk Bars", "code": "milkbars"],
//         ["name" : "Modern Australian", "code": "modern_australian"],
//         ["name" : "Modern European", "code": "modern_european"],
//         ["name" : "Mongolian", "code": "mongolian"],
//         ["name" : "Moroccan", "code": "moroccan"],
//         ["name" : "New Zealand", "code": "newzealand"],
//         ["name" : "Night Food", "code": "nightfood"],
//         ["name" : "Norcinerie", "code": "norcinerie"],
//         ["name" : "Open Sandwiches", "code": "opensandwiches"],
//         ["name" : "Oriental", "code": "oriental"],
//         ["name" : "Pakistani", "code": "pakistani"],
//         ["name" : "Parent Cafes", "code": "eltern_cafes"],
//         ["name" : "Parma", "code": "parma"],
//         ["name" : "Persian/Iranian", "code": "persian"],
//         ["name" : "Peruvian", "code": "peruvian"],
//         ["name" : "Pita", "code": "pita"],
//         ["name" : "Pizza", "code": "pizza"],
//         ["name" : "Polish", "code": "polish"],
//         ["name" : "Portuguese", "code": "portuguese"],
//         ["name" : "Potatoes", "code": "potatoes"],
//         ["name" : "Poutineries", "code": "poutineries"],
//         ["name" : "Pub Food", "code": "pubfood"],
//         ["name" : "Rice", "code": "riceshop"],
//         ["name" : "Romanian", "code": "romanian"],
//         ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
//         ["name" : "Rumanian", "code": "rumanian"],
//         ["name" : "Russian", "code": "russian"],
//         ["name" : "Salad", "code": "salad"],
//         ["name" : "Sandwiches", "code": "sandwiches"],
//         ["name" : "Scandinavian", "code": "scandinavian"],
//         ["name" : "Scottish", "code": "scottish"],
//         ["name" : "Seafood", "code": "seafood"],
//         ["name" : "Serbo Croatian", "code": "serbocroatian"],
//         ["name" : "Signature Cuisine", "code": "signature_cuisine"],
//         ["name" : "Singaporean", "code": "singaporean"],
//         ["name" : "Slovakian", "code": "slovakian"],
//         ["name" : "Soul Food", "code": "soulfood"],
//         ["name" : "Soup", "code": "soup"],
//         ["name" : "Southern", "code": "southern"],
//         ["name" : "Spanish", "code": "spanish"],
//         ["name" : "Steakhouses", "code": "steak"],
//         ["name" : "Sushi Bars", "code": "sushi"],
//         ["name" : "Swabian", "code": "swabian"],
//         ["name" : "Swedish", "code": "swedish"],
//         ["name" : "Swiss Food", "code": "swissfood"],
//         ["name" : "Tabernas", "code": "tabernas"],
//         ["name" : "Taiwanese", "code": "taiwanese"],
//         ["name" : "Tapas Bars", "code": "tapas"],
//         ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
//         ["name" : "Tex-Mex", "code": "tex-mex"],
//         ["name" : "Thai", "code": "thai"],
//         ["name" : "Traditional Norwegian", "code": "norwegian"],
//         ["name" : "Traditional Swedish", "code": "traditional_swedish"],
//         ["name" : "Trattorie", "code": "trattorie"],
//         ["name" : "Turkish", "code": "turkish"],
//         ["name" : "Ukrainian", "code": "ukrainian"],
//         ["name" : "Uzbek", "code": "uzbek"],
//         ["name" : "Vegan", "code": "vegan"],
//         ["name" : "Vegetarian", "code": "vegetarian"],
//         ["name" : "Venison", "code": "venison"],
//         ["name" : "Vietnamese", "code": "vietnamese"],
//         ["name" : "Wok", "code": "wok"],
//         ["name" : "Wraps", "code": "wraps"],
//         ["name" : "Yugoslav", "code": "yugoslav"]]

}
