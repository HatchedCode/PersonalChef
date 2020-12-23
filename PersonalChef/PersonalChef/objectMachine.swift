//
//  objectMachine.swift
//  PersonalChef
//
//  Created by Osman Bakari on 4/13/20.
//  Copyright © 2020 Osman Bakari. All rights reserved.
//

import Foundation
import CoreData

class chefMachine{
    
    public var foodLibrary = [FoodItem]()
    public var defaultFoodFilename: String = "default.jpg"
    public var defaultFoodName: String = "Default"
    public var defaultFoodcalories: Int = 500
    public var global_Food_Index : Int = 0
    public var global_Recipe_Index : Int = 0

    
    public var favorites : FavoriteMachine = FavoriteMachine()
    public var browse : BrowseMachine = BrowseMachine()
    public var mainpage : MainPageMachine = MainPageMachine()

    init() {

    }
    
    public var coredata : CoreDataMachine = CoreDataMachine()
    
    
    public func checkNewFoodName(_ text : String) -> Bool
    {
        let temp = text
        if(temp.isEmpty)
        {
            return false
        }
        else if(temp.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        {
            return false
        }
        
        return true
    }
}



class CoreDataMachine
{
    public func saveFoodToCoreData(_ newFoodItem: FoodItem,_ appDelegate: AppDelegate,_ managedObjectContext: NSManagedObjectContext)
    {
        let fooditem = NSEntityDescription.insertNewObject(forEntityName: "Food", into: managedObjectContext)
        fooditem.setValue(newFoodItem.calories_per_serving, forKey: "calories")
        fooditem.setValue(newFoodItem.foodId, forKey: "f_id")
        fooditem.setValue(newFoodItem.filename, forKey: "imageFileName")
        fooditem.setValue(newFoodItem.name, forKey: "name")
        fooditem.setValue(String(newFoodItem.index), forKey: "positional_index")
        appDelegate.saveContext() //This is in the AppDelegate.swift file
        print("FoodItem saved to CoreData [BELOW]:")
        newFoodItem.printFood()
    }
    
    func fetchFoodItemsFromCoreData(_ managedObjectContext: NSManagedObjectContext) -> [NSManagedObject]
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Food")
        var foodItems : [NSManagedObject] = []
        do{
            foodItems = try managedObjectContext.fetch(fetchRequest)
        }
        catch{
            print("fetchFood Error: \(error)")
        }
        return foodItems
    }
    
    func parseNSFoodObject(_ fooditem : NSManagedObject) -> FoodItem
    {
        let name = fooditem.value(forKey: "name") as? String
        let calories = fooditem.value(forKey: "calories") as? String
        let imageFileName = fooditem.value(forKey: "imageFileName") as? String
        let id = fooditem.value(forKey: "f_id") as? String
        let index = fooditem.value(forKey: "positional_index") as? String
        let parsedFoodItem: FoodItem = FoodItem(name!, id!, imageFileName!, calories!, Int(index!) ?? 0)
        print("fetched from Core Data [BELOW]:")
        parsedFoodItem.printFood()
        return parsedFoodItem
    }
    
    
    //Recipe
    public func saveRecipeToCoreData(_ newFoodItem: RecipeItem,_ appDelegate: AppDelegate,_ managedObjectContext: NSManagedObjectContext)
    {
        let fooditem = NSEntityDescription.insertNewObject(forEntityName: "Recipe", into: managedObjectContext)
        fooditem.setValue(newFoodItem.calories_per_serving, forKey: "calories")
        fooditem.setValue(newFoodItem.foodId, forKey: "f_id")
        fooditem.setValue(newFoodItem.filename, forKey: "filename")
        fooditem.setValue(newFoodItem.name, forKey: "name")
        fooditem.setValue(String(newFoodItem.position_Index), forKey: "positional_index")
        fooditem.setValue(newFoodItem.recipeId, forKey: "r_id")
        fooditem.setValue(newFoodItem.cookTime, forKey: "c_time")
        fooditem.setValue(newFoodItem.ingredients, forKey: "ingredients")
        appDelegate.saveContext() //This is in the AppDelegate.swift file
        print("FoodItem saved to CoreData [BELOW]:")
        newFoodItem.printRecipe()
    }
    
    func fetchRecipeItemsFromCoreData(_ managedObjectContext: NSManagedObjectContext) -> [NSManagedObject]
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Recipe")
        var recipeItem : [NSManagedObject] = []
        do{
            recipeItem = try managedObjectContext.fetch(fetchRequest)
        }
        catch{
            print("fetchRecipe Error: \(error)")
        }
        return recipeItem
    }
    
    func parseNSRecipeObject(_ recipeitem : NSManagedObject) -> RecipeItem
    {
        let name = recipeitem.value(forKey: "name") as? String
        let calories = recipeitem.value(forKey: "calories") as? String
        let imageFileName = recipeitem.value(forKey: "filename") as? String
        let id = recipeitem.value(forKey: "f_id") as? String
        let index = recipeitem.value(forKey: "positional_index") as? String
        let ingredients = recipeitem.value(forKey: "ingredients") as? String
        let RecipeId = recipeitem.value(forKey: "r_id") as? String
        let cookTime = recipeitem.value(forKey: "c_time") as? String
        
        let parsedRecipeItem: RecipeItem = RecipeItem(name!, imageFileName!, cookTime!, ingredients!, RecipeId!, id!, calories!, Int(index!) ?? 0)
        
        print("fetched Recipe from Core Data [BELOW]:")
        parsedRecipeItem.printRecipe()
        return parsedRecipeItem
    }
    
    
    func deleteFoodFromCoreDataByIndex(_ id: String, _ managedObjectContext: NSManagedObjectContext,_ appDelegate: AppDelegate)
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Food")
        fetchRequest.predicate = NSPredicate(format: "f_id == %@", id)
        var fooditems: [NSManagedObject]!
        do{
            fooditems = try managedObjectContext.fetch(fetchRequest)
        }
        catch{
            print("remove foodItem by index error: \(error)")
        }
        
        
        let recipefetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Recipe")
        recipefetchRequest.predicate = NSPredicate(format: "f_id == %@", id)
        var recipeitems: [NSManagedObject]!
        do{
            recipeitems = try managedObjectContext.fetch(recipefetchRequest)
        }
        catch{
            print("remove foodItem by index error: \(error)")
        }
        
        //Remove all the recipes
        for recipe in recipeitems{
            print("d-id:\(id)      id: \((recipe.value(forKey: "f_id") as? String)!)")
            if(id == (recipe.value(forKey: "f_id") as? String)!)
            {
                print("DELETE from Core Data: name: \((recipe.value(forKey: "name") as? String)!)  f_id: \((recipe.value(forKey: "f_id") as? String)!)  r_id: \((recipe.value(forKey: "r_id") as? String)!)")
                managedObjectContext.delete(recipe)
            }
        }
        
        
        //Remove the food
        for fooditem in fooditems{
            print("d-id:\(id)      id: \((fooditem.value(forKey: "f_id") as? String)!)")
            if(id == (fooditem.value(forKey: "f_id") as? String)!)
            {
                print("DELETE from Core Data: name: \((fooditem.value(forKey: "name") as? String)!) calories: \((fooditem.value(forKey: "calories") as? String)!)  imageFilename: \((fooditem.value(forKey: "imageFileName") as? String)!)  index: \((fooditem.value(forKey: "f_id") as? String)!)")
                managedObjectContext.delete(fooditem)
            }
        }
        
        appDelegate.saveContext() // In AppDelegate.swift file in the FoodApp folder under the FoodApp proj.
    }

    
    //Remove Recipe by id
    func deleteRecipeFromCoreDataByID(_ id: String, _ managedObjectContext: NSManagedObjectContext,_ appDelegate: AppDelegate)
    {
        
        let recipefetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Recipe")
        recipefetchRequest.predicate = NSPredicate(format: "r_id == %@", id)
        var recipeitems: [NSManagedObject]!
        do{
            recipeitems = try managedObjectContext.fetch(recipefetchRequest)
        }
        catch{
            print("remove Recipe by index error: \(error)")
        }
        
        //Remove all the recipes
        for recipe in recipeitems{
            print("d-id:\(id)      id: \((recipe.value(forKey: "f_id") as? String)!)")
            if(id == (recipe.value(forKey: "r_id") as? String)!)
            {
                print("DELETE RECIPE from Core Data: name: \((recipe.value(forKey: "name") as? String)!)  f_id: \((recipe.value(forKey: "f_id") as? String)!)  r_id: \((recipe.value(forKey: "r_id") as? String)!)")
                managedObjectContext.delete(recipe)
            }
        }
        
        appDelegate.saveContext() // In AppDelegate.swift file in the FoodApp folder under the FoodApp proj.
    }

    
}
