//
//  RecipesTableViewController.swift
//  PersonalChef
//
//  Created by Osman Bakari on 4/13/20.
//  Copyright © 2020 Osman Bakari. All rights reserved.
//

import UIKit
import CoreData

class RecipesTableViewController: UITableViewController {
    
    //Variables
    var searchFood : FoodItem!
    var spoonacularAPIKey : String!
    var recipeURLString : String!
    var imagesRetrieved : [(UIImage, Int)] = []
    var selectedRowIndex : Int = 0
    var managedObjectContext: NSManagedObjectContext!
    var appDelegate: AppDelegate!
    
    
    @IBOutlet weak var refreshRecipesButton: UIBarButtonItem!
    
    @IBAction func refreshRecipes(_ sender: UIBarButtonItem) {
        if(sender == self.refreshRecipesButton)
        {
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

        
        print(searchFood!.name)
        
        mainMachine.browse.emptyRecipeLibrary()
        
        initializeRecipeTable()
        
        // Uncomment the following line to preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
        print("ViewDidAppear")
    }
    

    func initializeRecipeTable()
    {
        self.spoonacularAPIKey = "f95872dc684f4eb2b803f01e40c2f5f5"
        self.recipeURLString = "https://api.spoonacular.com/recipes/search?query=\(self.searchFood.name)&number=10&apiKey="+self.spoonacularAPIKey
        print(self.recipeURLString!)
        self.getRecipe(self.recipeURLString)
    }
    
    
    func getRecipe(_ searchURL: String) {
        // May not know exactly what's in the URL, so replace special characters with % encoding
        if let urlStr = searchURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                if let url = URL(string: urlStr) {
                    let dataTask = URLSession.shared.dataTask(with: url,completionHandler: handleRecipeResponse)
                    dataTask.resume()
                }
        }
    }
    
    
        func handleRecipeResponse (data: Data?, response: URLResponse?, error: Error?){
            
            // 1. Check for error in request (e.g., no network connection)
            if let err = error {
                print("error: \(err.localizedDescription)")
                return
            }
            
            // 2. Check for improperly-formatted response
            guard let httpResponse = response as? HTTPURLResponse
            else {
                print("error: improperly-formatted response")
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            // 3. Check for HTTP error
            guard statusCode == 200 else{
                let msg = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                print("HTTP \(statusCode) error \(msg)")
                return
            }
            
            // 4. Check for no data
            guard let recipeData = data else {
                print("Error: no data retrieved")
                return
            }
            
            // 5. Check for properly-formatted JSON data
            guard let jsonObj = try? JSONSerialization.jsonObject(with: recipeData),
                let jsonRetDict = jsonObj as? [String: Any],
                jsonRetDict.count > 0,
                let imagesBaseUriStr = jsonRetDict["baseUri"] as? String,
                let jsonResultsDict = jsonRetDict["results"] as? [Any],
                jsonResultsDict.count > 0
                else {
                    print("error: invalid JSON data in handleRecipeResponse()")
                    return
                }
                
            // 6. Everything has gone right and is good to do something with data
            print("success: reponse: jsonRetDict=\(jsonRetDict)")
            print("success: reponse: imagesBaseUriStr=\(imagesBaseUriStr)")
            print("success: reponse: jsonResultsDict=\(jsonResultsDict)")

            // 7. Change and upadte the neccessary information
            if(imagesBaseUriStr != "")
            {
                    print("imagesBaseUriStr is not nil")
                    self.initializeEachRecipe(jsonResultsDict, imagesBaseUriStr)
            }
        }
    
    var tempRecipe : RecipeItem!
    var index : Int = 0

    func initializeEachRecipe(_ resultFoodsDict: [Any] ,_ imagesBaseUriStr: String)
    {
        self.index = 0
        for dictFood in resultFoodsDict
        {
            let food = dictFood as? [String: Any]
            let titleStr = food!["title"] as? String
            let idStr = food!["id"] as? Int
            let cookTime = food!["readyInMinutes"] as? Int
            let cookCal = food!["servings"] as? Int
            let imageStr = food!["image"] as? String
            
            self.tempRecipe = RecipeItem()
            
            tempRecipe.name = titleStr!
            tempRecipe.filename = imagesBaseUriStr + imageStr!
            tempRecipe.foodId = searchFood.foodId
            tempRecipe.recipeId = String(idStr!)
            tempRecipe.calories_per_serving = String(cookCal!)
            tempRecipe.cookTime = String(cookTime!)
            tempRecipe.position_Index = index
            loadNewImage(tempRecipe.filename)
            let response : (Bool, String) = mainMachine.browse.addRecipe(newrecipe: self.tempRecipe)
            print(response.1)

            index+=1

            print("Added")
        }
        
        print("Finished")
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
//            print(image!)
//            print(image?.accessibilityIdentifier!)
                self.tempRecipe.actualImage = image
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
        return mainMachine.browse.recipes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "displayBrowsedRecipes", for: indexPath)
        let row : Int = indexPath.row
        // Configure the cell...
        if(mainMachine.browse.recipes.count > 0)
        {
            if(self.imagesRetrieved.count > row)
            {
                cell.imageView?.image  = self.imagesRetrieved[row].0 //mainMachine.browse.recipes[row].actualImage
            }
            cell.textLabel?.text = mainMachine.browse.recipes[row].name
            cell.detailTextLabel?.text = mainMachine.browse.recipes[row].cookTime
        }
        

        return cell
    }
    
    
    //A cell has been selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt: indexPath: Row= \(indexPath.row)")
        self.selectedRowIndex = indexPath.row
        
        //Confirm that the user really wants to save the recipe.
        self.displayRecipeAddAlert(mainMachine.browse.recipes[self.selectedRowIndex].name)
        
        //This is where we want to make a call to CoreData to save the food and the recipe.
        
    }

    
    func displayRecipeAddAlert(_ recipeName: String)
    {
        let alert = UIAlertController(title: "Next Action",
                                      message: "Do you really want to add the recipe: \(recipeName) to the food:\(self.searchFood.name)?", preferredStyle: .alert)
        
        
        let yesAction = UIAlertAction(title: "Yes", style: .default,
        handler: { (action) in
            // execute some code when this option is selected
            print("YES!")
            //Add new recipe as favorite
            self.addNewRecipe()
        })
        
        let noAction = UIAlertAction(title: "No", style: .default,
        handler: { (action) in
            // execute some code when this option is selected
            print("NO!")
            //Do Nothing
        })
        
        alert.addAction(yesAction)
        alert.addAction(noAction)

        alert.preferredAction = noAction // only affects .alert style
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func addNewRecipe()
    {
        print("Adding New Recipe")
        
             //Fetch the food and make sure we don't double save the food
             var isExisting : Bool = false
             
             let fetchedItems : [NSManagedObject] = mainMachine.coredata.fetchFoodItemsFromCoreData(self.managedObjectContext)
             if(fetchedItems.count > 0)
             {
                 //No need to do anything.
                 for fooditem in fetchedItems{
                     let food : FoodItem
                         = mainMachine.coredata.parseNSFoodObject(fooditem)
                     if(food.foodId == searchFood.foodId)
                     {
                         isExisting = true
                         break
                     }
                 }
             }
             
             if(!isExisting)
             {
                 //save the food.
                 mainMachine.coredata.saveFoodToCoreData(searchFood, self.appDelegate, self.managedObjectContext)
             }
             else{
                print("Food already exists")
        }
             
             
             //Now we check the recipe
             isExisting = false
             
             let allfetchedItems : [NSManagedObject] = mainMachine.coredata.fetchRecipeItemsFromCoreData(self.managedObjectContext)
             if(allfetchedItems.count > 0)
             {
                 //No need to do anything.
                 for recipeitem in allfetchedItems{
                     let recipe : RecipeItem
                         = mainMachine.coredata.parseNSRecipeObject(recipeitem)
                     if(recipe.recipeId == mainMachine.browse.recipes[self.selectedRowIndex].recipeId)
                     {
                         isExisting = true
                         break
                     }
                 }
             }
             
             if(!isExisting)
             {
                 //save the food.
                 mainMachine.coredata.saveRecipeToCoreData(mainMachine.browse.recipes[self.selectedRowIndex], self.appDelegate, self.managedObjectContext)
             }
        else
             {
                print("Recipe already exists")
        }
        
        print("They have been added")
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
