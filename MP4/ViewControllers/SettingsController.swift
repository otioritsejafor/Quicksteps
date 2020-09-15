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
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        configureFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    
    // MARK: Helpers
    func configureFields() {
        weightTextField.delegate = self
    }
}

extension SettingsController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Finished editing")
    }
}
