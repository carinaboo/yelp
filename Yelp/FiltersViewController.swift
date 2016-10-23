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

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FiltersViewControllerDelegate?
    
    var switchStates = [Int:Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set UITableView data source and delegate
        tableView.dataSource = self;
        tableView.delegate = self;
        
        // Auto size cells
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
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
        
        var selectedCategories = [String]()
        for (row,isSelected) in switchStates {
            if isSelected {
                selectedCategories.append(filters["category"]![row]["code"]!)
            }
        }
        if selectedCategories.count > 0 {
            selectedFilters["categories"] = selectedCategories as AnyObject?
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
        
        let options = getFilterOptionsBySectionIndex(index: indexPath.section)
        let option = options[indexPath.row]
        
//        let category = filters["category"]![(indexPath as NSIndexPath).row]
        cell.switchLabel.text = option["name"]
        cell.delegate = self
        
        cell.onSwitch.isOn = switchStates[indexPath.row] ?? false
        
        return cell
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
    
    // Deselect row after tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - SwitchCellDelegate
    
    // User tapped switch on Filters category
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!
        
        switchStates[indexPath.row] = value
    }
    
    // MARK: - Private
    
    let filters: [String:[[String: String]]] =
        ["deals" : [["name" : "Offering a deal"]],
        "distance" : [["name" : "Auto"],
                      ["name" : "0.3 miles"],
                      ["name" : "1 mile"],
                      ["name" : "5 miles"],
                      ["name" : "20 miles"]],
        "sort" : [["name" : "Best match"],
                  ["name" : "Distance"],
                  ["name" : "Highest rated"]],
        "category": [["name" : "Barbeque", "code": "bbq"],
                     ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                     ["name" : "Thai", "code": "thai"],
                     ["name" : "Vietnamese", "code": "vietnamese"]]]
    
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
    
    func getFilterOptionsBySectionIndex(index: Int) -> [[String: String]] {
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
