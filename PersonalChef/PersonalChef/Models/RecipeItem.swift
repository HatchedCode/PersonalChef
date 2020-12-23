//
//  RecipeItem.swift
//  PersonalChef
//
//  Created by Osman Bakari on 4/18/20.
//  Copyright © 2020 Osman Bakari. All rights reserved.
//

import Foundation
import UIKit

class RecipeItem
{
    public var name: String
    public var filename: String
    public var cookTime : String
    public var ingredients : String
    public var recipeId : String
    public var foodId : String
    public var calories_per_serving: String
    public var position_Index: Int
    public var actualImage : UIImage!
    
    init()
    {
        self.calories_per_serving = ""
        self.name = ""
        self.filename = ""
        self.ingredients = ""
        self.recipeId = ""
        self.position_Index = -1
        self.cookTime = ""
        self.foodId = ""
//        DispatchQueue.main.async {
            self.actualImage = UIImage()
//        }
    }
    
    init(_ name : String, _ filename : String,_ cookTime : String,_ ingredients : String,_ recipeId : String,_ foodId : String,_ calories_per_serving : String,_ position_index : Int) {
        self.calories_per_serving = calories_per_serving
        self.name = name
        self.filename = filename
        self.ingredients = ingredients
        self.recipeId = recipeId
        self.position_Index = position_index
        self.cookTime = cookTime
        self.foodId = foodId
    }
    
    func areEqual(_ recipe: RecipeItem) -> Bool
    {
        return (recipe.recipeId == self.recipeId && recipe.foodId == self.foodId)
    }
    
    func printRecipe()
    {
        let recipe : String =
        "{ \n" +
        "Name: \(self.name)  \n" +
            "r_id:  \(self.recipeId)  \n" +
        "f_id:  \(self.foodId)  \n" +
        "Cook Time:  \(self.cookTime)  \n" +
        "Ingredients:  \(self.ingredients)  \n" +
        "Filename:  \(self.filename)  \n" +
        "Positional Index:  \(self.position_Index)  \n" +
        "Calories Per Serving:  \(self.calories_per_serving)  \n" +
        "}"
        print(recipe)
    }
}
