//
//  buttonWithShadow.swift
//  MP4
//
//  Created by Oti Oritsejafor on 10/30/19.
//  Copyright © 2019 Magloboid. All rights reserved.
//

import Foundation
import UIKit

class ButtonWithShadow: UIButton {
    var mode = 0
    
    override func draw(_ rect: CGRect) {
        updateLayerProperties()
    }
    
    func updateLayerProperties() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 10.0
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.size.height / 2 
        
    }
}
