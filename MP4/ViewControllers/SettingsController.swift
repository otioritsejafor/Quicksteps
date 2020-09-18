//
//  SettingsController.swift
//  MP4
//
//  Created by Oti Oritsejafor on 9/14/20.
//  Copyright © 2020 Magloboid. All rights reserved.
//

import Foundation
import UIKit

class SettingsController: UITableViewController {
    
    @IBOutlet weak var weightTextField: UITextField!
    let defaults = UserDefaults.standard
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        configureFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let weight = defaults.integer(forKey: "Weight")
        weightTextField.text = "\(weight)"
    }
    
    
    // MARK: Helpers
    func configureFields() {
        weightTextField.delegate = self
        weightTextField.font = UIFont.boldSystemFont(ofSize: 17)
    }
}

extension SettingsController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        var number = Int(textField.text!)
        defaults.set(number, forKey: "Weight")
        //defaults.set(Int(textField.text), forKey: "")
        print("Finished editing")
    }
}
