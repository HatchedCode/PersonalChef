//
//  BrowseFoodViewController.swift
//  PersonalChef
//
//  Created by Osman Bakari on 4/30/20.
//  Copyright © 2020 Osman Bakari. All rights reserved.
//

//UITableView is: FoodName      Cals

import UIKit

class BrowseFoodViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate{

    var filteredData: [FoodItem]!
    
    private var prevText : String = ""
    
    @IBOutlet weak var searchFoodTextBox: UITextField!
        
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchForFoodUIButton: UIButton!
    
    var selectedRowIndex : Int = 0
    
    
    
    
    
    
    @IBAction func findFoodSearched(_ sender: UIButton) {
        if(self.searchFoodTextBox.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0)
        {
            self.filteredData = randomFoodGenerator.randomFoods
        }
        else
        {
            self.filteredData = randomFoodGenerator.randomFoods.filter({$0.name.lowercased().hasPrefix((self.searchFoodTextBox.text?.lowercased())!) || $0.name.lowercased().hasSuffix((self.searchFoodTextBox.text?.lowercased())!) || self.searchFoodTextBox.text?.lowercased() == $0.name.lowercased() })
        }
        
        tableView.reloadData()
    }
    
    
    @IBAction func newFoodSearched(_ sender: UITextField) {
        print("BrowseFoodUIViewController: TextField Done Editing")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Setup delegates */
//        tableView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        self.filteredData = randomFoodGenerator.randomFoods
        
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredData.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "browseFood", for: indexPath)
        let rowIndex = indexPath.row
        
        if(filteredData.count > 0)
        {
        //Set the image
//  print("Filename="+self.filteredData[rowIndex].filename)
        cell.imageView!.image = UIImage(named: self.filteredData[rowIndex].filename)
        
            //Set the food name
        cell.textLabel?.text = self.filteredData[rowIndex].name ////String(FoodName)
            
            //Set the calories
        cell.detailTextLabel?.text = self.filteredData[rowIndex].calories_per_serving  ////String(Calories)
        }
        
        return cell;
    }
    
    //A cell has been selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt: indexPath: Row= \(indexPath.row)")
        self.selectedRowIndex = indexPath.row
        performSegue(withIdentifier: "browseRecipesSegue", sender: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.

        if segue.identifier == "browseRecipesSegue" {
            let recipeTableViewController = segue.destination as! RecipesTableViewController
            print("self.selectedRowIndex=\(self.selectedRowIndex)")
            let foodItem: FoodItem = (self.filteredData[self.selectedRowIndex])
            recipeTableViewController.searchFood = foodItem
        }
        
    }
    

}
