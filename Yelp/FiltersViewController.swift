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
    
    var categoriesExpanded: Bool = false
    
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
        let dealsOn = getFilterState(filterOption: filters["deals"]![0])
        if dealsOn {
            selectedFilters["deals"] = dealsOn as AnyObject?
        }
        
        // Distance
        var distanceMode: Int = 0
        for distance in filters["distance"]! {
            if (getFilterState(filterOption: distance)) {
                distanceMode = distance["code"] as! Int
                break
            }
        }
        selectedFilters["distance"] = distanceMode as AnyObject?
        
        // Sort by
        var sortMode: YelpSortMode = YelpSortMode.bestMatched
        for sort in filters["sort"]! {
            if (getFilterState(filterOption: sort)) {
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
            if (getFilterState(filterOption: category)) {
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
            if (!cell.expanded) {
                cell.button.setTitle(option["name"] as! String?, for: UIControlState.normal)
            } else {
                cell.button.setTitle(option["nameOn"] as! String?, for: UIControlState.normal)
            }
            cell.delegate = self
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
        
        if let indexPath = tableView.indexPath(for: switchCell) {
            setFilterStateAt(sectionIndex: indexPath.section, andRowIndex: indexPath.row, toState: value)
        }
    }
    
    // MARK: - SelectCellDelegate
    
    // User tapped select
    func selectCell(selectCell: SelectCell,
                    didChangeValue value: Bool) {
        
        if let indexPath = tableView.indexPath(for: selectCell) {
            setFilterStateAt(sectionIndex: indexPath.section, andRowIndex: indexPath.row, toState: value)
        }
    }
    
    // MARK: - ButtonCellDelegate
    
    // User tapped see more categories button
    func buttonCell(buttonCell: ButtonCell,
                    didChangeValue value: Bool) {
        
        if let indexPath = tableView.indexPath(for: buttonCell) {
            buttonCell.expanded = !buttonCell.expanded;
            self.categoriesExpanded = !self.categoriesExpanded

            if (self.categoriesExpanded) {
                showAdditionalCategoriesAfter(indexPath: indexPath)
            } else {
                hideAdditionalCategoriesAfter(indexPath: indexPath)
            }
            
//            let categoryCount = filters["category"]!.count
//            let insertIndexPath = IndexPath(row: categoryCount-1, section: indexPath.section)
//            print(indexPath)
//            print(insertIndexPath)
        }
    }
    
    func showAdditionalCategoriesAfter(indexPath: IndexPath) {
        filters["category"]?.append(contentsOf: categories)
        
        tableView.reloadData()
        
//        This method doesn't work. Adds another ButtonCell instead of reading from filters data.
//        tableView.beginUpdates()
//        tableView.insertRows(at: [indexPath], with: .automatic)
//        tableView.endUpdates()

    }
    
    func hideAdditionalCategoriesAfter(indexPath: IndexPath) {
        let categoriesExpanded = filters["category"]!
        
        let startCategoriesExpandedIndex = categoriesExpanded.count - categories.count
        let categoriesCollapsed = Array(categoriesExpanded[0..<startCategoriesExpandedIndex])
        
        filters["category"] = categoriesCollapsed
        tableView.reloadData()
    }
    
    // MARK: - Private
    
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
    
    func getFilterState(filterOption: [String: Any]) -> Bool {
        if let optionIsOn = filterOption["on"] {
            return optionIsOn as! Bool
        } else {
            return false
        }
    }
    
    func getFilterStateAt(sectionIndex: Int, andRowIndex rowIndex: Int) -> Bool {
        let option = getOptionBy(sectionIndex: sectionIndex, andRowIndex: rowIndex)
        return getFilterState(filterOption: option)
    }

}
