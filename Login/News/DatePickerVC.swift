//
//  DatePickerVC.swift
//  SamplePod
//
//  Created by Easyway_Mac2 on 19/09/19.
//  Copyright © 2019 Easyway_Mac2. All rights reserved.
//

import UIKit

class DatePickerVC: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if (touch.view == self.view) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: datePicker.date)
    }
    
    var onSave: ((String, String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.maximumDate = Date()
    }
    
    @IBAction func saveDate(_ sender: Any) {
        let longValue = datePicker.date.millisecondsSince1970
        onSave?(formattedDate, String(longValue))
        dismiss(animated: true, completion: nil)
    }

}
