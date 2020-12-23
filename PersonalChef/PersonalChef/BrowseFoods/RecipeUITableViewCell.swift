//
//  RecipeUITableViewCell.swift
//  PersonalChef
//
//  Created by Osman Bakari on 5/6/20.
//  Copyright © 2020 Osman Bakari. All rights reserved.
//

import UIKit

class RecipeUITableViewCell: UITableViewCell {

    @IBOutlet weak var recipeImage: UIImageView!
    
    @IBOutlet weak var recipeNameLabel: UILabel!
    
    @IBOutlet weak var cookTimeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
