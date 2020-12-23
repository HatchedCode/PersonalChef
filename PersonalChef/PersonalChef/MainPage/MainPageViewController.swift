//
//  MainPageViewController.swift
//  PersonalChef
//
//  Created by Osman Bakari on 4/13/20.
//  Copyright © 2020 Osman Bakari. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MainPageViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate  {

    var searchFood : String = ""
    var randomFood : FoodItem!
    
    
    var managedObjectContext: NSManagedObjectContext!
    var appDelegate: AppDelegate!
    var locationManager = CLLocationManager()
    
    
    @IBOutlet weak var cookTimeRandomFoodLabel: UILabel!
    @IBOutlet weak var randomRecipeNameLabel: UILabel!
    @IBOutlet weak var addFavoriteRandomFoodButton: UIButton!
    @IBOutlet weak var randomFoodUIImageView: UIImageView!
    @IBOutlet weak var nearbyFoodsUILabel: UILabel!
    @IBOutlet weak var findNearbyFoodsButton: UIButton!
    @IBOutlet weak var searchNearByFoodsTextField: UITextField!
    @IBOutlet weak var nearbyFoodMKMapView: MKMapView!
    
    
    
    func initializeLocation()
    {
        // called from start up method
        locationManager.delegate = self
        self.nearbyFoodMKMapView.delegate = self

        let status = CLLocationManager.authorizationStatus()
        print("initializeLocation()")
        
        switch status
        {
            case .authorizedAlways, .authorizedWhenInUse:
                startLocation()
            case .denied, .restricted:
                print("location not authorized")
                displayAlert()
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("initializeLocation(): Error could not determine status for location.")
        }
    }
    
    
    func displayAlert()
    {
        let alert = UIAlertController(title: "Next Action",
        message: "Choose your next action.", preferredStyle: .alert)
        
        
        let okayAction = UIAlertAction(title: "Okay", style: .default,
        handler: { (action) in
            // execute some code when this option is selected
            print("Okay!")
            //Segue back to TableView
            self.navigationController?.popViewController(animated: true)
        })
        
        alert.addAction(okayAction)
        alert.preferredAction = okayAction // only affects .alert style
        
        present(alert, animated: true, completion: nil)
    }
    

    // Delegate method called when location changes
    func locationManager(_ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        
        if let latitude = location?.coordinate.latitude
        {
            print("Latitude: \(latitude)")
        }
        
        if let longitude = location?.coordinate.longitude
        {
            print("Longitude: \(longitude)")
        }
    }
    
    
    // Delegate method called whenever location authorization status changes
    func locationManager(_ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus)
    {
        if ((status == .authorizedAlways) || (status == .authorizedWhenInUse))
        {
            self.startLocation()
        }
        else
        {
            self.stopLocation()
        }
    }
    
    // Delegate method called if location unavailable (recommended)
    func locationManager(_ manager: CLLocationManager,
    didFailWithError error: Error)
    {
        print("locationManager error: \(error.localizedDescription)")
    }
    
    func startLocation()
    {
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            self.nearbyFoodMKMapView.setRegion(viewRegion, animated: false)
        }
                
        locationManager.startUpdatingLocation()
    }
    
    
    func stopLocation()
    {
        locationManager.stopUpdatingLocation()
    }
    
    
    @IBAction func findNearbyFoods(_ sender: UIButton) {
        if(sender == self.findNearbyFoodsButton)
        {
            if(self.searchNearByFoodsTextField.text != nil && mainMachine.checkNewFoodName(self.searchNearByFoodsTextField.text!) )
            {
                print("Searching for Food")
                self.searchFood = self.searchNearByFoodsTextField.text!
                
                self.findFood()
            }
        }
    }
    
    
    @IBAction func addFoodAsFavorite(_ sender: UIButton) {
        if(sender == self.addFavoriteRandomFoodButton)
        {
            print("Is Clicked")
//            if(self.addFavoriteRandomFoodButton.tintColor == UIColor.systemBlue)
//            {
                self.addFavoriteRandomFoodButton.tintColor = UIColor.systemYellow
                print("UIColor.systemYellow")
                
//                self.addFavoriteRandomFoodButton.isEnabled = false
                
                //Fetch the food and make sure we don't double save the food
           
                var isExisting : Bool = false
                
                let fetchedItems : [NSManagedObject] = mainMachine.coredata.fetchFoodItemsFromCoreData(self.managedObjectContext)
                if(fetchedItems.count > 0)
                {
                    //No need to do anything.
                    for fooditem in fetchedItems{
                        let food : FoodItem
                            = mainMachine.coredata.parseNSFoodObject(fooditem)
                        if(food.foodId == randomFood.foodId)
                        {
                            isExisting = true
                            break
                        }
                    }
                }
                
                if(!isExisting)
                {
                    //save the food.
                    mainMachine.coredata.saveFoodToCoreData(randomFood, self.appDelegate, self.managedObjectContext)
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
                        if(recipe.recipeId == randomRecipe.recipeId)
                        {
                            isExisting = true
                            break
                        }
                    }
                }
                
                if(!isExisting)
                {
                    //save the food.
                    mainMachine.coredata.saveRecipeToCoreData(randomRecipe, self.appDelegate, self.managedObjectContext)
                }
//            }
        }
    }
    
    
    func initialize(){
        let spoonacularAPIKey : String = "f95872dc684f4eb2b803f01e40c2f5f5"
        self.randomFood = randomFoodGenerator.getRandomFood()
        
        let recipeURLString : String = "https://api.spoonacular.com/recipes/search?query\(randomFood.name)&apiKey=\(spoonacularAPIKey)"
        
        self.getRandomRecipe(recipeURLString)
    }
    
    
    func handleDetectedFoodResponse (data: Data?, response: URLResponse?, error: Error?){
        
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
            DispatchQueue.main.async {
                //Do somethings, but what??
            }
            return
        }
        

        guard let jsonObj = try? JSONSerialization.jsonObject(with: recipeData),
            let jsonDict = jsonObj as? [String: Any],
            let foods = jsonDict["annotations"] as? [Any]
            else {
                print("error: invalid JSON data")
                return
            }
        
        // 6. Returned data seems okay
        if (foods.count == 0)
        {
            print("Found nothin = ", foods)
        }
        else
        {
            print("There is food: ", foods)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.managedObjectContext = self.appDelegate.persistentContainer.viewContext
        
        self.addFavoriteRandomFoodButton.isEnabled = true
        self.initializeLocation()
        self.nearbyFoodMKMapView.userTrackingMode = .followWithHeading
        self.searchFood = self.randomFood.name
        self.findFood()
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageClicked(_:)))
        
        self.randomFoodUIImageView.isUserInteractionEnabled = true
        
        self.randomFoodUIImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageClicked(_ tapGuesture: UITapGestureRecognizer)
    {
        //Action or segue is done here
        print("Clicked")
        
        //Segue to the favRecipes
        performSegue(withIdentifier: "imageClicked", sender: self)
    }
    
    func findFood()
    {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = self.searchFood
        request.region = self.nearbyFoodMKMapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start(completionHandler: searchHandler)
    }
    
    
    func searchHandler (response: MKLocalSearch.Response?, error: Error?)
    {
        if let err = error
        {
            print("Error occured in search: \(err.localizedDescription)")
        }
        else if let resp = response
        {
            print("\(resp.mapItems.count) matches found")
            self.nearbyFoodMKMapView.removeAnnotations(self.nearbyFoodMKMapView.annotations)
            
            for item in resp.mapItems
            {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                self.nearbyFoodMKMapView.addAnnotation(annotation)
            }
        }
    }

    //Random recipe
    func getRandomRecipe(_ searchURL: String) {
        // May not know exactly what's in the URL, so replace special characters with % encoding
        if let urlStr = searchURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                if let url = URL(string: urlStr) {
                    let dataTask = URLSession.shared.dataTask(with: url,completionHandler: handleRecipeResponse)
                    dataTask.resume()
                }
        }
    }
    
    
    var randomRecipe : RecipeItem!
    
    private var noDataFoundMessge = "No recipe found"
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
            DispatchQueue.main.async {
                self.cookTimeRandomFoodLabel.text = "Cook Time: \(0)"
                self.randomRecipeNameLabel.text = self.noDataFoundMessge
                self.randomFoodUIImageView = nil
            }
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
                print(recipeData)
                print("error: invalid JSON data in handleRecipeResponse()")
                DispatchQueue.main.async {
                    self.randomRecipeNameLabel.text = self.noDataFoundMessge
                    self.randomFoodUIImageView.image = nil
                }
                return
            }
        
        print(jsonResultsDict)
        
        let randomIndex : Int = Int.random(in: 0 ..< jsonResultsDict.count)
        
        let result = jsonResultsDict[randomIndex] as? [String: Any]
        let recipeId = result!["id"] as? Int
        let recipeTitle = result!["title"] as? String
        let calories = result!["servings"] as? Int
        let recipeCookTime = result!["readyInMinutes"] as? Int
        let recipeimageUrl = result!["image"] as? String

        // 6. Everything has gone right and is good to do something with data
        print("success: reponse: id=\(String(describing: recipeId))   title=\(String(describing: recipeTitle))  cookTime=\(String(describing: recipeCookTime)) imageUri=\(String(describing: recipeimageUrl))")
        
        randomRecipe = RecipeItem(recipeTitle!, imagesBaseUriStr + recipeimageUrl!, String(recipeCookTime!), "", String(recipeId!), randomFood.foodId, String(calories!), 0)

        // 7. Change and upadte the neccessary information
        if(imagesBaseUriStr != "")
        {
            print("imagesBaseUriStr is not nil")
            let urlToImage = imagesBaseUriStr + recipeimageUrl!
            self.loadNewImage(urlToImage)
        }
        
        //These things have to be done on the main thread.
        DispatchQueue.main.async {
            self.randomRecipeNameLabel.text = recipeTitle
            self.cookTimeRandomFoodLabel.text = "Cook Time: \(String(recipeCookTime!))"
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
                self.randomFoodUIImageView.image = image
            }
        }
        else
        {
            print("Error: no image retrieved, not possible!")
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "imageClicked" {
            let randomFoodViewController = segue.destination as! RandomFoodViewController
            print("self.selectedRowIndex=\(self.randomRecipe.name)")
            randomFoodViewController.food = randomFood
            randomFoodViewController.recipe = randomRecipe
            randomFoodViewController.recipeImage = randomFoodUIImageView.image

        }
    }
}
