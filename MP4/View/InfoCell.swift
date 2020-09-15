//
//  InfoCell.swift
//  MP4
//
//  Created by Oti Oritsejafor on 9/14/20.
//  Copyright © 2020 Magloboid. All rights reserved.
//

import Foundation
import UIKit

class InfoCell: UITableViewCell {
    @IBOutlet var viewBackground: UIView!
    @IBOutlet var labelDate: UILabel!
    @IBOutlet var labelDistance: UILabel!
    @IBOutlet var labelDuration: UILabel!
    @IBOutlet var labelCalories: UILabel!
    
    //var currentRun: Run!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewBackground.layer.borderWidth = 1
        viewBackground.layer.borderColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
    }
    
    func configureData(currentRun: Run) {
        labelDate.text = "\(FormatDisplay.date(currentRun.timestamp))"
        labelDate.textColor = UIColor.purple
        let rDistance = currentRun.distance.rounded(toPlaces: 2)
        let distanceLabel = FormatDisplay.distance(rDistance)
        labelDistance.text = distanceLabel
        labelDuration.text = "\(FormatDisplay.time(Int(currentRun.duration)))"
//        if let calories = currentRun.calories {
//
//        }
        labelCalories.text = "\(Int(currentRun.calories)) kcal"
    }
}
