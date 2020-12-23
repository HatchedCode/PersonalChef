//
//  RandomFoodGenerator.swift
//  PersonalChef
//
//  Created by Osman Bakari on 5/5/20.
//  Copyright © 2020 Osman Bakari. All rights reserved.
//

import Foundation

class RandomFoodGenerator
{
    public var randomFoods : [FoodItem] = []
    private var error : NSError?
    private var filename : String = ""
    
    init(_ filename : String) {
        self.filename = filename
        initializeFoods()
    }
    
    
    private func initializeFoods()
    {
        let foods = self.readFromCSVFile()
        print(foods!)
        parseCSVData(foods!)
    }
    
    
    private func readFromCSVFile() -> [String]!
    {
        guard let file = Bundle.main.path(forResource: self.filename, ofType: "csv")
            else {
               print("filepath incorrect")
                return nil
        }
        do {
            let foods = try String(contentsOfFile: file, encoding: .utf8)
            let result = foods.components(separatedBy: "\r\n")
            print(result)
           return result
        } catch {
            print("Error reading from \(file)")
            return nil
        }
    }
    
    
    private func parseCSVData(_ foods: [String])
    {
        var index : Int = 0
        for food in  foods
        {
            print(food)
            let foodParts = food.components(separatedBy: ",")
            let foodName = foodParts[0]
            let calories = foodParts[1]
            let filename = foodParts[2]
            self.randomFoods.append(FoodItem(foodName, String(index), filename, calories, index))
            index += 1
        }
    }
    
    private func getRandomIndex() -> Int
    {
        return Int.random(in: 0 ..< self.randomFoods.count)
    }
    
    public func getRandomFood() -> FoodItem
    {
        let rIndex : Int = getRandomIndex()
        return self.randomFoods[rIndex]
    }
}
