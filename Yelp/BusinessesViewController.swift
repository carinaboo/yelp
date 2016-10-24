//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, FiltersViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchBar: UISearchBar!
    var searchString: String = "food"
    
    var isMoreDataLoading = false
    
    var businesses: [Business]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set UITableView data source and delegate
        tableView.dataSource = self;
        tableView.delegate = self;
        
        // Auto size cells
        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Initialize the UISearchBar
        searchBar = UISearchBar()
        searchBar.delegate = self
        
        // Add SearchBar to the NavigationBar
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        // Populate search bar with default query
        searchBar.text = searchString
        
        // Navigation bar styling
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        Business.searchWithTerm(term: searchString, completion: {
            (businesses: [Business]?, error: Error?)
            -> Void in
            
                self.businesses = businesses
                if let businesses = businesses {
                    self.tableView.reloadData()
                    for business in businesses {
                        print(business.name!)
                        print(business.address!)
                    }
                }
            
            }
        )
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let businesses = businesses {
            return businesses.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        
        let business = businesses![(indexPath as NSIndexPath).row]
        cell.business = business
        
        return cell
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                loadMoreData()
            }
        }
    }
    
    func loadMoreData() {
        
        isMoreDataLoading = true
        // TODO: Show loading indicator
        
        Business.searchWithTerm(term: searchString) {
            (businesses: [Business]?, error: Error?)
            -> Void in
            
            // Update flag
            self.isMoreDataLoading = false
            
            // TODO: Hide loading indicator
            
            if let businesses = businesses {
                self.businesses.append(contentsOf: businesses)
                
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - FiltersViewController
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject]) {
        let deals = filters["deals"] as? Bool
        let sort = filters["sort"] as? YelpSortMode
        let distance = filters["distance"] as? Int
        let categories = filters["category"] as? [String]
        
        // TODO: search term should be stored
        Business.searchWithTerm(term: searchString, sort: sort, categories: categories, deals: deals, distance: distance) {
            (businesses: [Business]?, error: Error?)
            -> Void in
                self.businesses = businesses
                self.tableView.reloadData()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        
        filtersViewController.delegate = self
    }
    
}

// MARK: - UISearchBarDelegate
extension BusinessesViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true;
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = searchString
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchString = searchBar.text ?? searchString
        searchBar.resignFirstResponder()
        Business.searchWithTerm(term: searchString, sort: nil, categories: nil, deals: nil, distance: 0) {
            (businesses: [Business]?, error: Error?)
            -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
}
