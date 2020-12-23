//
//  RecipeInformationViewController.swift
//  PersonalChef
//
//  Created by Osman Bakari on 4/13/20.
//  Copyright © 2020 Osman Bakari. All rights reserved.
//

import UIKit

class RecipeInformationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var selectedFavRecipe : RecipeItem!
    var selectedFavRecipeImage : UIImage!
    var selectedFavfoodItem : FoodItem!
    var ingredients : [(String, String)] = []
    var spoonacularAPIKey : String!
    var recipeURLString : String!
    var ingredientsIndex : Int = 0
    
    
    @IBOutlet weak var startCookingButton: UIButton!
    
    @IBOutlet weak var ingredientsTableView: UITableView!
    
    @IBOutlet weak var recipeInformationTextView: UITextView!
    
    @IBOutlet weak var recipeImage: UIImageView!
    
    @IBOutlet weak var recipeNameLabel: UILabel!
    
    @IBOutlet weak var recipeCookTimeLabel: UILabel!
    
    
    
    @IBAction func startCookNotification(_ sender: UIButton) {
        if(sender == startCookingButton)
        {
            self.fireCookingNotification()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ingredientsTableView.dataSource = self
        self.ingredientsTableView.delegate = self
        
        ingredients = []
        
        self.initializeRecipeInformation()
        
        // Do any additional setup after loading the view.
    }
    
    
    func initializeRecipeInformation()
    {
        //Set the image
        self.recipeImage.image = self.selectedFavRecipeImage
        
        //Set the cook time label
        self.recipeCookTimeLabel.text = self.selectedFavRecipe.cookTime
        
        //set the recipe name
        self.recipeNameLabel.text = self.selectedFavRecipe.name
        
        //Set the Text and Ingredients
        self.retriveRecipeInformation()
        
    }
    
    func retriveRecipeInformation()
    {
        self.initializeRecipeTable()
    }
    
    func initializeRecipeTable()
    {
        self.spoonacularAPIKey = "f95872dc684f4eb2b803f01e40c2f5f5"
        self.recipeURLString = "https://api.spoonacular.com/recipes/\(self.selectedFavRecipe.recipeId)/information?includeNutrition=false&apiKey="+self.spoonacularAPIKey
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
            let instructions = jsonRetDict["instructions"] as? String,
            let extendedIngredients = jsonRetDict["extendedIngredients"] as? [Any]
            else {
                print("error: invalid JSON data in handleRecipeResponse()")
                return
            }
            
        // 6. Everything has gone right and is good to do something with data
        print("success: reponse: jsonRetDict=\(jsonRetDict)")
        print("success: reponse: instructions=\(instructions)")
        print("success: reponse: extendedIngredients=\(extendedIngredients)")

        self.parseIngregients(extendedIngredients)
  
        //
        // 7. Change and upadte the neccessary information

        //These things have to be done on the main thread.
            DispatchQueue.main.async {
                if(instructions.count > 0)
                {
                    self.recipeInformationTextView.text = instructions
                }
                else
                {
                    self.recipeInformationTextView.text = "There are no instructions"
                }

                self.ingredientsTableView.reloadData()
            }
    }
    
    
    func parseIngregients(_ extendedIngredients : [Any])
    {
        self.ingredientsIndex = 0
        for ingredientDict in extendedIngredients
        {
            let ingredient = ingredientDict as? [String: Any]
            let amount = ingredient!["amount"] as? Double
            let name = ingredient!["originalName"] as? String
            
            ingredients.append((name!, String(amount!)))
        }
        
    }
    
    
    func fireCookingNotification()
    {
        self.alert()
    }
    
    func createAlert()
    {
        let alert = UIAlertController(title: "Food Notification",
                                      message: "Do you want to schedule a notification for \(self.selectedFavRecipe.name) for \(self.selectedFavRecipe.cookTime)?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            // execute some code when this option is selected

            DispatchQueue.main.async {
                print("Setting color to RED")
            }

            print("Go to scheduleFoodNotification!")
            self.scheduleFoodNotification()
        })
        
        let noAction = UIAlertAction(title: "No", style: .destructive, handler: { (action) in
            print("No alert.")
        })
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        alert.preferredAction = yesAction
        
        present(alert, animated: true, completion: nil)
    }
    
    //Making sure that notifications are enabled
    func alert()
    {
        let center = UNUserNotificationCenter.current()
        print("alert(): checking settings")
        center.getNotificationSettings(completionHandler: { (settings) in
            print("checking settings if enabled")
            if settings.alertSetting == .enabled {
                        print("Going to alert")
                        DispatchQueue.main.async { // Correct
                            self.createAlert()
                      }
        } else {
        print("notifications disabled")
        } })
    }
    
    
    func handleNotification(_ response: UNNotificationResponse)
    {
        let message = response.notification.request.content.userInfo["FooduuidString"] as! String
        
        print("Message is = " + message)

        print("Setting color to BLACK")
        self.ingredientsTableView.reloadData()
    }
    
    
    
    func scheduleFoodNotification()
    {
        let content = UNMutableNotificationContent()

        content.title = "FoodTimer"
        content.body = "Time to start EATING " + self.selectedFavRecipe.name
        
        content.userInfo["FooduuidString"] = self.selectedFavRecipe.recipeId
        
        // Configure trigger for 5 seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (Double(self.selectedFavRecipe.cookTime)!),
        repeats: false)
        let request = UNNotificationRequest(identifier: self.selectedFavRecipe.recipeId,
                             content: content, trigger: trigger)
            // Schedule request
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: { (error) in
            if let err = error {
                print(err.localizedDescription)
            }
        })
    }
    
    
    
    //Ingredients TableView Stuff
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ingredients.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipe", for: indexPath)
        let rowIndex = indexPath.row
        
        if(ingredients.count > 0)
        {
            cell.textLabel?.text = ingredients[rowIndex].0
            cell.detailTextLabel?.text = ingredients[rowIndex].1
        }
        
        return cell;
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
