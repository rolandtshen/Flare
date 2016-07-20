//
//  CategoryHelper.swift
//  Questions
//
//  Created by Roland Shen on 7/20/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation

struct CategoryHelper {
    func colorChooser(category: String) -> UIColor {
        var color: UIColor?
        switch(category) {
        case "Travel":
            color = UIColor.flatRedColor()
            break
        case "Entertainment":
            color = UIColor.flatOrangeColor()
            break
        case "Meetup":
            color = UIColor.flatYellowColor()
            break
        case "Listings":
            color = UIColor.flatGreenColor()
            break
        case "Recommendations":
            color = UIColor.flatSkyBlueColor()
            break
        case "Other":
            color = UIColor.flatMagentaColor()
            break
        default:
            color = UIColor.flatBlackColor()
        }
        return color!
    }
}