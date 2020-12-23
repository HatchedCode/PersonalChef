//
//  SavedRecipesTableViewController.swift
//  PersonalChef
//
//  Created by Osman Bakari on 4/13/20.
//  Copyright © 2020 Osman Bakari. All rights reserved.
//

import UIKit
import CoreData

class SavedRecipesTableViewController: UITableViewController {
    
    var selectedFavFood : FoodItem!
    var managedObjectContext: NSManagedObjectContext!
    var appDelegate: AppDelegate!
    var imagesRetrieved : [(UIImage, Int)] = []
    var index : Int = 0
    var selectedRowIndex : Int = 0
    
    @IBOutlet weak var refreshTableView: UIBarButtonItem!
    
    
    @IBAction func refreshTable(_ sender: UIBarButtonItem) {
        if(sender == refreshTableView)
        {
            print("Refresh counts: recipes=\(mainMachine.favorites.recipes.count)")
            print("Refresh counts: recipesImages=\(imagesRetrieved.count)")
            self.tableView.reloadData()
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.rowHeight = 58
        
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.managedObjectContext = self.appDelegate.persistentContainer.viewContext

        mainMachine.favorites.emptyRecipeLibrary()
        self.imagesRetrieved = []
        self.initailizeTable()
                    
        // Uncomment the following line to preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    func initailizeTable()
    {
        initializeRecipeItems()
        self.initializeRecipeImages()
    }
    
    
    func initializeRecipeItems()
    {
        let fetchedItems : [NSManagedObject] = mainMachine.coredata.fetchRecipeItemsFromCoreData(self.managedObjectContext)
        if(fetchedItems.count > 0)
        {
            for recipeitem in fetchedItems{
                let recipe : RecipeItem = mainMachine.coredata.parseNSRecipeObject(recipeitem)
                if(recipe.foodId == self.selectedFavFood.foodId)
                {
                    mainMachine.favorites.recipes.append(recipe)
                }
            }
        }
    }
    
    func initializeRecipeImages()
    {
        self.index = 0
       for recipe in mainMachine.favorites.recipes
       {
            loadNewImage(recipe.filename)
            self.index += 1
        }
        
    }
    
    func loadNewImage(_ imageURLString: String){
            // May not know exactly what's in the URL, so replace special characters with % encoding
            if let urlStr = imageURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                if let url = URL(string: urlStr) {
                    let dataTask = URLSession.shared.dataTask(with: url,completionHandler: handleImageResponse)
                    dataTask.resume()
                }
            }
        }
        
        
        func handleImageResponse (data: Data?, response: URLResponse?, error: Error?){
            
            // 1. Check for error in request (e.g., no network connection)
            if let err = error {
                print("error: \(err.localizedDescription)")
                return
            }
            
            // 2. Check for improperly-formatted response
            guard let httpResponse = response as? HTTPURLResponse
            else {
                print("error: improperly-formatted response in handleImageResponse()")
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            // 3. Check for HTTP error
            guard statusCode == 200 else{
                let msg = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                print("HTTP \(statusCode) error \(msg)")
                return
            }
            
            // 4. Check for no image data
            // Handle data since we got data back.
            if let imageData = data {
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    self.imagesRetrieved.append((image!, self.index))
                }
            }
            else
            {
                print("Error: no image retrieved, not possible!")
                DispatchQueue.main.async {
                    self.imagesRetrieved.append((UIImage(), self.index))
                }
            }
        }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mainMachine.favorites.recipes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favRecipes", for: indexPath)
        let row = indexPath.row
        // Configure the cell...
        print("count=\(mainMachine.favorites.recipes.count)")
        if(mainMachine.favorites.recipes.count > 0)
        {
            if(self.imagesRetrieved.count > row)
              {
                  cell.imageView?.image  = self.imagesRetrieved[row].0
              }
            
            cell.textLabel?.text = mainMachine.favorites.recipes[row].name
            cell.detailTextLabel?.text = mainMachine.favorites.recipes[row].cookTime
            
            print(mainMachine.favorites.recipes[row].name)
        }

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let row = indexPath.row
            //get item at the given cell index
            let id: String = mainMachine.favorites.recipes[row].recipeId
            print("id to DELETE:\(id)")
            mainMachine.coredata.deleteRecipeFromCoreDataByID(id, self.managedObjectContext, self.appDelegate)
            
            mainMachine.favorites.recipes.remove(at: row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    //A cell has been selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt: indexPath: Row= \(indexPath.row)")
        self.selectedRowIndex = indexPath.row
        
        //Segue to the favRecipes
        performSegue(withIdentifier: "singleRecipeSegue", sender: self)
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
        if segue.identifier == "singleRecipeSegue" {
            let recipeInformationViewController = segue.destination as! RecipeInformationViewController
            print("self.selectedRowIndex=\(self.selectedRowIndex)")
            let recipeItem: RecipeItem = (mainMachine.favorites.recipes[self.selectedRowIndex])
            let recipeImage : (UIImage, Int) = imagesRetrieved[self.selectedRowIndex]
            recipeInformationViewController.selectedFavRecipe = recipeItem
           
            recipeInformationViewController.selectedFavfoodItem = self.selectedFavFood
            recipeInformationViewController.selectedFavRecipeImage = recipeImage.0

        }
    }
    

}
