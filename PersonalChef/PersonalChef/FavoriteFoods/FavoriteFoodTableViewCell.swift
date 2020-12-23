//
//  FavoriteFoodTableViewCell.swift
//  PersonalChef
//
//  Created by Osman Bakari on 5/6/20.
//  Copyright © 2020 Osman Bakari. All rights reserved.
//

import UIKit

class FavoriteFoodTableViewCell: UITableViewCell {

    @IBOutlet weak var foodImage: UIImageView!
    
    @IBOutlet weak var searchNearbyFoods: UIButton!
    
    @IBOutlet weak var caloriesLabel: UILabel!
    
    @IBOutlet weak var foodNameLabel: UILabel!
    
    
    @IBAction func nearbyFoodClicked(_ sender: UIButton) {
        if(sender == searchNearbyFoods)
        {
            print("Actually performing segue to nearbyFavoriteFoods")
            foodnearby = self.foodNameLabel.text!
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "favFoodNearbySegue" {
            let nearbyFavoriteFoodUIViewController = segue.destination as! NearbyFavoriteFoodUIViewController
            print("in FAVFoodsCell")
            print("self.selectedRowIndex=" + String(describing: self.foodNameLabel.text))
            nearbyFavoriteFoodUIViewController.foodName = self.foodNameLabel.text
        }
    }

}
