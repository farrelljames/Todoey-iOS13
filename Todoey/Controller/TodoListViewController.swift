//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: SwipeTableViewController {
    
    //var itemArray: [String] = []
    var todoItems: Results<Item>?
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    //let defaults = UserDefaults.standard
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = selectedCategory!.name!
        //Another way to retrieve userdefault
        //todoItems = defaults.object(forKey: "ToDoListArray") as? [String] ?? [String]()
        
        //        if let items = defaults.array(forKey: "ToDoListArray") as? [Item] {
        //            todoItems = items
        //        }
    }
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        guard let itemForDeletion = todoItems?[indexPath.row] else {
            return
        }
        
        do {
            try self.realm.write({
                realm.delete(itemForDeletion)
            })
        } catch {
            print("Error deleting item: \(error)")
        }
    }
}

//MARK: - TableView Datasource Methods

extension ToDoListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
}

//MARK: - TableView Delegate Methods

extension ToDoListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write({
                    item.done = !item.done
                    // delete method
                    //realm.delete(item)
                })
            } catch {
                print("Error saving done status \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
//
////MARK: - Add New Items
//
extension ToDoListViewController {
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //create alert
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        var textField = UITextField()
        
        //Add textfield to alertcontroller
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        //Create alert action
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            //what happened when add item butotn is clicked
            guard let itemTitle = textField.text, !itemTitle.isEmpty else {
                print("You didn't provide an item")
                return
            }
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write({
                        let newItem = Item()
                        newItem.title = itemTitle
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    })
                } catch {
                    print("Error while saving: \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - UISearchBarDelegate

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            print("please enter a search term")
            return
        }
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
        
        //        guard let searchText = searchBar.text else {
        //            print("please enter a search term")
        //            return
        //        }
        //
        //        let request: NSFetchRequest<Item> = Item.fetchRequest()
        //
        //        // How to search coredata using NS predicate
        //        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        //
        //        //sort data
        //        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        //
        //        loadItems(with: request, predicate: predicate)
    }
    
    //If search text is empty reload original list
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty) {
            loadItems()
            
            //goes back to original state - i.e., removes keybaord
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

