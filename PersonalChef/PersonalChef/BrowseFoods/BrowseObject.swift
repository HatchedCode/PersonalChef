//
//  BrowseObject.swift
//  PersonalChef
//
//  Created by Osman Bakari on 4/18/20.
//  Copyright © 2020 Osman Bakari. All rights reserved.
//

import Foundation

class BrowseMachine
{
    public var browsedFood : FoodItem!
    
    public var foods : [FoodItem] = []
    
    public var recipes : [RecipeItem] = []
    
    public var recipe : RecipeItem!
    
    private var selectedRowIndex:Int = 0
    
    
    
    
    //Check the textbox value and make sure that something is entered
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
    
    //  (c_time, f_id, ingredients, name, r_id)
    func isExistingRecipe(_ crecipe: RecipeItem) -> Bool
    {
        for recipe in self.recipes{
            if(recipe.areEqual(crecipe))
            {
                return true
            }
        }
        return false
    }

    func isExistingFood(_ cfood: FoodItem) -> Bool
    {
        for food in self.foods{
            if(food.areEqual(cfood))
            {
                return true
            }
        }
        return false
    }
    
    public func addRecipe(newrecipe: RecipeItem) -> (Bool, String)
    {
        if(self.isExistingRecipe(newrecipe) == false)
        {
            self.recipes.append(newrecipe)
            return (true, "")
        }
        return (false, "Recipe already in the library of recipes")
    }
    
    public func addFood(newFood: FoodItem) -> (Bool, String)
    {
        if(self.isExistingFood(newFood) == false)
        {
            self.foods.append(newFood)
            return (true, "")
        }
        return (false, "Food already in the library of foods")
    }
    
    public func emptyRecipeLibrary()
    {
        self.recipes = []
    }
    
    public func emptyFoodLibrary()
    {
        self.foods = []
    }
    
}
