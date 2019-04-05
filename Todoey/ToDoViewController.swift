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
    let toDoList = ["Buy Apples", "Do Laundry", "Destroy people"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    //MARK - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = toDoList[indexPath.row]
        return cell
    }
    
    //MARK - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if  tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
        else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

