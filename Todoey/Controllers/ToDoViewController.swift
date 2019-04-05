//
//  ViewController.swift
//  Todoey
//
//  Created by Easyway_Mac2 on 05/04/19.
//  Copyright © 2019 Easyway_Mac2. All rights reserved.
//

import UIKit

class ToDoViewController: UITableViewController {
    
    //Instance Variables
    
    let cellId = "ToDoItemCell"
    var toDoList = ["Buy Apples", "Do Laundry", "Destroy people"]
    
    var itemArray = [Item]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadData()
    }


    //MARK - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.itemName
        
        cell.accessoryType = item.done == true ? .checkmark : .none
        
        return cell
    }
    
    //MARK - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add Item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add New Item", style: .default) { (action) in
        let item = Item()
            item.itemName = textField.text!
            
         self.itemArray.append(item)
            
         self.saveData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(addAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: Manipulate Model Data
    
    func saveData(){
        
        let encoder = PropertyListEncoder()
        
        do {
           let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Encoder failed error, \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadData(){
        if let data = try? Data.init(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("decoding failed error, \(error)")
            }
        }
    }
    
}

