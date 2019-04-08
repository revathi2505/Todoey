//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Easyway_Mac2 on 08/04/19.
//  Copyright © 2019 Easyway_Mac2. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    let cellId = "CategoryCell"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categoryArray: [Category] = [Category]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return categoryArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)

        cell.textLabel?.text = self.categoryArray[indexPath.row].name
        
        return cell
    }
    
    //MARK: UITableview datasource methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoViewController
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[selectedIndexPath.row]
        }
    }
    
    //MARK: - Add Category
 

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alertController = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let alert = UIAlertAction(title: "Add Category", style: .default) {
            (alertAction) in
            
            let category = Category(context: self.context)
            category.name = textField.text!
            
            self.categoryArray.append(category)
            
            self.saveData()
        }
        
        alertController.addTextField() {
            (alertTextField) in
            textField = alertTextField
        }
        
        alertController.addAction(alert)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: Data Model Manipulation Methods
    
    func saveData() {
        
        do {
            try context.save()
        } catch {
            print("Error saving contect \(context)")
        }
        
        tableView.reloadData()
    }
    
    func loadData(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            self.categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching request \(error)")
        }
        
        tableView.reloadData()
    }
}

//MARK: - Search bar methods

extension CategoryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
    
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        loadData(with: request)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text!.count == 0 {
            
            loadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
