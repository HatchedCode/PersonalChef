//
//  RandomFoodViewController.swift
//  PersonalChef
//
//  Created by Osman Bakari on 4/13/20.
//  Copyright © 2020 Osman Bakari. All rights reserved.
//

import UIKit
import CoreData

class RandomFoodViewController: UIViewController {

    var food : FoodItem!
    var recipe : RecipeItem!
    var recipeImage : UIImage!
    var spoonacularAPIKey : String!
    var recipeURLString : String!
    
    
    var managedObjectContext: NSManagedObjectContext!
    var appDelegate: AppDelegate!
    
    
    @IBOutlet weak var recipeNameLabel: UILabel!
    
    @IBOutlet weak var recipeImageView: UIImageView!
    
    @IBOutlet weak var cookTimeLabel: UILabel!
    
    @IBOutlet weak var instructionsTextView: UITextView!
    
    @IBOutlet weak var addAsFavoriteBarButton: UIBarButtonItem!
    
    
    @IBAction func addAsFavorite(_ sender: UIBarButtonItem) {
        self.addAsFavoriteBarButton.tintColor = UIColor.systemYellow
        
        //Save recipe (make sure it is not in the coreData already
//        self.addAsFavoriteBarButton.isEnabled = false
        
             //Fetch the food and make sure we don't double save the food
        
             var isExisting : Bool = false
             
             let fetchedItems : [NSManagedObject] = mainMachine.coredata.fetchFoodItemsFromCoreData(self.managedObjectContext)
             if(fetchedItems.count > 0)
             {
                 //No need to do anything.
                 for fooditem in fetchedItems{
                     let food : FoodItem
                         = mainMachine.coredata.parseNSFoodObject(fooditem)
                     if(food.foodId == food.foodId)
                     {
                         isExisting = true
                         break
                     }
                 }
             }
             
             if(!isExisting)
             {
                 //save the food.
                 mainMachine.coredata.saveFoodToCoreData(food, self.appDelegate, self.managedObjectContext)
             }
        else
             {
                print("Random: Food already exists")
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
                     if(recipe.recipeId == recipe.recipeId)
                     {
                         isExisting = true
                         break
                     }
                 }
             }
             
             if(!isExisting)
             {
                 //save the food.
                 mainMachine.coredata.saveRecipeToCoreData(recipe, self.appDelegate, self.managedObjectContext)
             }
        else
             {
                print("Random: Recipe already exists")
        }
        
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        self.addAsFavoriteBarButton.isEnabled = true

        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.managedObjectContext = self.appDelegate.persistentContainer.viewContext
        
        
        // Do any additional setup after loading the view.
    }
    
    
    func initialize()
    {
        self.recipeImageView.image = recipeImage
        cookTimeLabel.text = recipe.cookTime
        recipeNameLabel.text = recipe.name
        
        //API Call to get instructions
        print("Got instructions")
        self.getInstructions()
    }
    
    func getInstructions()
    {
        initializeRecipe()
    }
    
    
    func initializeRecipe()
    {
        self.spoonacularAPIKey = "f95872dc684f4eb2b803f01e40c2f5f5"
        self.recipeURLString = "https://api.spoonacular.com/recipes/\(self.recipe.recipeId)/information?includeNutrition=false&apiKey="+self.spoonacularAPIKey
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
            let instructions = jsonRetDict["instructions"] as? String
            else {
                print("error: invalid JSON data in handleRecipeResponse()")
                return
            }
            
        // 6. Everything has gone right and is good to do something with data
        print("success: reponse: jsonRetDict=\(jsonRetDict)")
        print("success: reponse: instructions=\(instructions)")

        // 7. Change and upadte the neccessary information

        //These things have to be done on the main thread.
            DispatchQueue.main.async {
                if(instructions.count > 0)
                {
                    self.instructionsTextView.text = instructions
                }
                else
                {
                    self.instructionsTextView.text = "There are no instructions"
                }
            }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
