//
//  CategorySelectionTableViewController.swift
//  jashdraft
//
//  Created by Sabrina Ip on 2/6/17.
//  Copyright © 2017 Sabrina. All rights reserved.
//

import UIKit

class CategorySelectionTableViewController: UITableViewController {
    //MARK: - Properties
    //these values need to correspond with UploadViewController
    var categories = CategoryManager.shared.catagoryTitlesArray
    var cellBackgroundImage = CategoryManager.shared.catagoryImages
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "CATEGORIES"
        self.tabBarItem.title = ""
        self.tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.cellIdentifier)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = JashColors.primaryColor
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.cellIdentifier, for: indexPath) as! CategoryTableViewCell

        cell.categoryTitleLabel.text = categories[indexPath.row]
        cell.cellBackgroundImage.image = cellBackgroundImage[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let navController = self.navigationController{
            let categoryController = CategoryPhotosCollectionViewController(collectionViewLayout: .init())
            let backItem = UIBarButtonItem()
            backItem.title = " "
            navigationItem.backBarButtonItem = backItem
            categoryController.title = categories[indexPath.row]
           // categoryController.modalPresentationStyle = .popover
            navController.pushViewController(categoryController, animated: true)
        }
    }
    
    //Sets status bar to white
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }


}
