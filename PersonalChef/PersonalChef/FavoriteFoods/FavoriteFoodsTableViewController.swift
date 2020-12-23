//
//  FavoriteFoodsTableViewController.swift
//  PersonalChef
//
//  Created by Osman Bakari on 4/13/20.
//  Copyright © 2020 Osman Bakari. All rights reserved.
//

import UIKit
import CoreData

var foodnearby : String = ""

//API CALLS TO CORE DATA
class FavoriteFoodsTableViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext!
    var appDelegate: AppDelegate!
    var selectedRowIndex : Int = 0
    
    func initializeFoodItems()
    {
        let fetchedItems : [NSManagedObject] = mainMachine.coredata.fetchFoodItemsFromCoreData(self.managedObjectContext)
        if(fetchedItems.count > 0)
        {
            for fooditem in fetchedItems{
                mainMachine.favorites.foods.append(mainMachine.coredata.parseNSFoodObject(fooditem))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self

        self.tableView?.rowHeight = 187

        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.managedObjectContext = self.appDelegate.persistentContainer.viewContext
        
        // Uncomment the following line to preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainMachine.favorites.foods = []
        initializeFoodItems()
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mainMachine.favorites.foods.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath) as! FavoriteFoodTableViewCell

        let indexRow = indexPath.row
        print(cell)
        let foodItem = (mainMachine.favorites.foods[indexRow])
        // Configure the cell...
        cell.foodImage.image = UIImage(named: foodItem.filename)
    
        cell.caloriesLabel.text =  String(describing: foodItem.calories_per_serving) + " cals"
        cell.foodNameLabel.text = foodItem.name
        
        cell.searchNearbyFoods.addTarget(self, action: #selector(nearyByFavoriteFoodButtonClicked), for: .touchUpInside)
        
        return cell
    }

    @objc func nearyByFavoriteFoodButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "favFoodNearbySegue", sender: sender)
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            let row = indexPath.row
            //get item at the given cell index
            let id: String = mainMachine.favorites.foods[row].foodId
            print("id to DELETE:\(id)")
            mainMachine.coredata.deleteFoodFromCoreDataByIndex(id, self.managedObjectContext, self.appDelegate)
            print("After DELETION")
            mainMachine.favorites.foods.remove(at: row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    //A cell has been selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt: indexPath: Row= \(indexPath.row)")
        self.selectedRowIndex = indexPath.row
        
        //Segue to the favRecipes
        performSegue(withIdentifier: "favRecipesSegue", sender: self)
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "favRecipesSegue" {
            let savedRecipesTableViewController = segue.destination as! SavedRecipesTableViewController
            print("self.selectedRowIndex=\(self.selectedRowIndex)")
            let foodItem: FoodItem = (mainMachine.favorites.foods[self.selectedRowIndex])
            savedRecipesTableViewController.selectedFavFood = foodItem
        }
        else if segue.identifier == "favFoodNearbySegue" {
            let nearbyFavoriteFoodUIViewController = segue.destination as! NearbyFavoriteFoodUIViewController
            
            print("in FAVFoods")
            print(foodnearby)
            nearbyFavoriteFoodUIViewController.foodName = foodnearby
        }
    }
}
