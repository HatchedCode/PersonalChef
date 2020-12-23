//
//  FoodItem.swift
//  PersonalChef
//
//  Created by Osman Bakari on 4/18/20.
//  Copyright © 2020 Osman Bakari. All rights reserved.
//

import Foundation

class FoodItem
{
    public var name: String
    public var filename: String
    public var calories_per_serving: String
    public var foodId : String
    public var index: Int
    
    init(_ name: String,_ foodId: String,_ filename: String, _ calories_per_serving: String, _ positionIndex: Int) {
        self.calories_per_serving = calories_per_serving
        self.filename = filename
        self.name = name
        self.index = positionIndex
        self.foodId = foodId
    }
    
    func areEqual(_ food: FoodItem) -> Bool
    {
        return (food.index == self.index && food.foodId == self.foodId)
    }
    
    func printFood()
    {
        let food : String =
        "{ \nName: \(self.name)  \n" +
        "f_id:  \(self.foodId)  \n" +
        "imageFileName:  \(self.filename)  \n" +
        "Calories:  \(self.calories_per_serving)  \n" +
        "positional Index:  \(self.index)  \n" +
        "}"

        print(food)
    }
}
