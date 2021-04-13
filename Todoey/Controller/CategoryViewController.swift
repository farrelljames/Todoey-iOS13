//
//  CategoryViewController.swift
//  Todoey
//
//  Created by James  Farrell on 20/03/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController {
    
    var categoryArray: Results<Category>?
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Date())
        
        // setup Category list
        loadCategories()
    }
}

//MARK: - Data Manipulation Methods

extension CategoryViewController {
    func save(category: Category) {
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            print("Error saving category: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
    }
}

//MARK: - TableView Delegate Methods
//click on cell in tableview

extension CategoryViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
//        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - Add new category

extension CategoryViewController {
    //add new categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //create alert
        let alert = UIAlertController(title: "Add new Todoey Category", message: "", preferredStyle: .alert)
        var textField = UITextField()
        
        //Add textfield to alertcontroller
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        //Create alert action
        let action = UIAlertAction(title: "Add category", style: .default) { (action) in
            //what happened when add item butotn is clicked
            guard let categoryName = textField.text, !categoryName.isEmpty else {
                print("You didn't provide a category")
                return
            }
            
            let newCategory = Category()
            newCategory.name = categoryName
            
            //Adding to User defaults
            //self.defaults.set(self.todoItems, forKey: "ToDoListArray")
            
            self.save(category: newCategory)
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Table view data source

extension CategoryViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            guard let categoryForDeletion = self.categoryArray?[indexPath.row] else {
                return
            }
            
            do {
                try self.realm.write({
                    let items = categoryForDeletion.items
                    
                    for item in items {
                        self.realm.delete(item)
                    }
        
                    self.realm.delete(categoryForDeletion)
                })
            } catch {
                print("Error when deleting \(error)")
            }
        }
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No categories added yet"
        
        return cell
    }
}

//MARK: - Prepare Segue Navigation

extension CategoryViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let destinationVC = segue.destination as! ToDoListViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categoryArray?[indexPath.row]
            }
            
            
        }
    }
}
