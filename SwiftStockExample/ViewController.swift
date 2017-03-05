//
//  ViewController.swift
//  SwiftStockExample
//
//  Created by Mike Ackley on 5/3/15.
//  Copyright (c) 2015 Michael Ackley. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    var searchResults: [StockSearchResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.tableFooterView = UIView() 
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "StockCell", bundle: Bundle.main), forCellReuseIdentifier: "stockCell")
        tableView.rowHeight = 60
        searchBar.delegate = self
        
    }
    
    
    // *** Here's the important bit *** //
    func searchYahooFinanceWithString(_ searchText: String) {
        
        SwiftStockKit.fetchStocksFromSearchTerm(term: searchText) { (stockInfoArray) -> () in
            
            self.searchResults = stockInfoArray
            self.tableView.reloadData()
            
        }
    
    }
    
    
    
    // Search code
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let length = searchText.characters.count
        
        if length > 0 {
            searchYahooFinanceWithString(searchText)
        } else {
            searchResults.removeAll()
            tableView.reloadData()
        }
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        tableView.reloadData()
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = false
        tableView.reloadData()
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
    
    
    //SearchBar stuff
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(_ sender: Notification) {
        if let userInfo = sender.userInfo {
            // if let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height { // commenting out because of "Initializer for conditional binding must have Optional type", which occurs if the RHS is not optional
                let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
                tableViewBottomConstraint.constant = keyboardHeight
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            // }
        }
    }
    
    func keyboardWillHide(_ sender: Notification) {
        if let userInfo = sender.userInfo {
            // if let _ = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height { // commenting out because of "Initializer for conditional binding must have Optional type", which occurs if the RHS is not optional
                tableViewBottomConstraint.constant = 0.0
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            // }
        }
    }
    
    
    //TableView stuff
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let controller: DetailViewController = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
        controller.stockSymbol = searchResults[indexPath.row].symbol!
        navigationController?.pushViewController(controller, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: StockCell = tableView.dequeueReusableCell(withIdentifier: "stockCell") as! StockCell
            cell.symbolLbl.text = searchResults[indexPath.row].symbol
            cell.companyLbl.text = searchResults[indexPath.row].name
            let exchange = searchResults[indexPath.row].exchange!
            let assetType = searchResults[indexPath.row].assetType!
            cell.infoLbl.text = exchange + "  |  " + assetType
        
        return cell
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

