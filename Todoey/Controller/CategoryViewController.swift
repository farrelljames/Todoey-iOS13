//
//  CategoryViewController.swift
//  Todoey
//
//  Created by James  Farrell on 20/03/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    var categoryArray: Results<Category>?
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Date())
        
        // setup Category list
        loadCategories()
    }
    
    //MARK: - Data Manipulation Methods
    
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
    
    override func updateModel(at indexPath: IndexPath) {
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
            newCategory.colourHex = UIColor.randomFlat().hexValue()
            
            //Adding to User defaults
            //self.defaults.set(self.todoItems, forKey: "ToDoListArray")
            
            self.save(category: newCategory)
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Table view data source

extension CategoryViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categoryArray?[indexPath.row] {
            cell.textLabel?.text = category.name
            cell.backgroundColor = UIColor(hexString: category.colourHex)
        } else {
            cell.textLabel?.text = "No categories added yet"
            cell.backgroundColor = UIColor(hexString: "#FFFFFF")
        }
        
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
