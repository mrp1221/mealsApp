//
//  APIController.swift
//  Meals
//
//  Created by Matthew Pohlhaus on 7/1/24.
//

import Foundation

struct GetCategoryListResponse: Decodable {
    let meals: [Category]
}

struct Category: Decodable, Hashable {
    let strCategory: String
}

struct GetMealListResponse: Decodable {
    let meals: [MealReference]
}

struct MealReference: Decodable, Hashable {
    let strMeal: String
    let strMealThumb: String
    let idMeal: String
}

struct GetMealDataResponse: Decodable {
    let meals: [Meal]
}

struct IngredientData: Hashable {
    let ingredient: String
    let measurement: String
}

struct Meal: Decodable {
    enum StringCodingKeys: String, CodingKey {
        case idMeal, strMeal, strDrinkAlternate, strCategory, strArea, strInstructions, strMealThumb, strTags, strYoutube, strSource, strImageSource, strCreativeCommonsConfirmed, dateModified
    }
    
    struct CodingKeys: CodingKey {
        var intValue: Int? // Not used, but needed for CodingKey conformity
        var stringValue: String
        init(stringValue: String) {
            self.stringValue = stringValue
        }
        // Not used, but needed for conformity
        init?(intValue: Int) {
            self.intValue = intValue
            self.stringValue = ""
        }
    }
    
    let idMeal: String
    let strMeal: String
    let strDrinkAlternate: String
    let strCategory: String
    let strArea: String
    let strInstructions: String
    let strMealThumb: String
    let strTags: String
    let strYoutube: URL?
    var ingredients: [IngredientData]
    let strSource: URL?
    let strImageSource: URL?
    let strCreativeCommonsConfirmed: String
    let dateModified: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.idMeal = try container.decodeIfPresent(String.self, forKey: CodingKeys(stringValue: "idMeal")) ?? ""
        self.strMeal = try container.decodeIfPresent(String.self, forKey: CodingKeys(stringValue: "strMeal")) ?? ""
        self.strDrinkAlternate = try container.decodeIfPresent(String.self, forKey: CodingKeys(stringValue: "strDrinkAlternate")) ?? ""
        self.strCategory = try container.decodeIfPresent(String.self, forKey: CodingKeys(stringValue: "strCategory")) ?? ""
        self.strArea = try container.decodeIfPresent(String.self, forKey: CodingKeys(stringValue: "strArea")) ?? ""
        self.strInstructions = try container.decodeIfPresent(String.self, forKey: CodingKeys(stringValue: "strInstructions")) ?? ""
        self.strMealThumb = try container.decodeIfPresent(String.self, forKey: CodingKeys(stringValue: "strMealThumb")) ?? ""
        self.strTags = try container.decodeIfPresent(String.self, forKey: CodingKeys(stringValue: "strTags")) ?? ""
        self.strYoutube = try URL(string: container.decodeIfPresent(String.self, forKey: CodingKeys(stringValue: "strYoutube")) ?? "") ?? nil
        self.strSource = try URL(string: container.decodeIfPresent(String.self, forKey: CodingKeys(stringValue: "strSource")) ?? "") ?? nil
        self.strImageSource = try URL(string: container.decodeIfPresent(String.self, forKey: CodingKeys(stringValue: "strImageSource")) ?? "") ?? nil
        self.strCreativeCommonsConfirmed = try container.decodeIfPresent(String.self, forKey: CodingKeys(stringValue: "strCreativeCommonsConfirmed")) ?? ""
        self.dateModified = try container.decodeIfPresent(String.self, forKey: CodingKeys(stringValue: "dateModified")) ?? ""
        
        self.ingredients = []
        for i in 1...20 {
            let ingredientKey = CodingKeys(stringValue: "strIngredient\(i)")
            let measurementKey = CodingKeys(stringValue: "strMeasure\(i)")
            
            if let ingredient = try? container.decodeIfPresent(String.self, forKey: ingredientKey),
               let measurement = try? container.decodeIfPresent(String.self, forKey: measurementKey) {
                if ingredient.count > 0 {
                    ingredients.append(IngredientData(ingredient: ingredient, measurement: measurement))
                } else {
                    break
                }
            }
        }
    }
}

class APIController {
    static let categoryListEndpoint = "https://themealdb.com/api/json/v1/1/list.php?c=list"
    static let mealListEndpoint = "https://themealdb.com/api/json/v1/1/filter.php?c="
    static let mealEndpoint = "https://themealdb.com/api/json/v1/1/lookup.php?i="
    
    static func fetchCategoryList() async throws -> [Category] {
        guard let url = URL(string: categoryListEndpoint) else {
            print("URL Error!! Check category lsit endpoint")
            throw MealError.URLError
        }
        print(url)
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            print("Response error! Check category list endpoint")
            throw MealError.ResponseError
        }
        
        do {
            let categoryData = try JSONDecoder().decode(GetCategoryListResponse.self, from: data)
            print("Success!!!")
            return categoryData.meals
        } catch {
            print("Error parsing category data from list, check endpoint and respone!", error)
            throw MealError.DataParseError
        }
    }
    
    static func fetchMealList(category: String, search: String = "") async throws -> [MealReference] {
        guard let url = URL(string: "\(mealListEndpoint)\(category)") else {
            print("URL Error!! Check list endpoint")
            throw MealError.URLError
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            print("Response Error! Check list endpoint")
            throw MealError.ResponseError
        }
        
        do {
            let mealsData = try JSONDecoder().decode(GetMealListResponse.self, from: data)
            print("Success!!")
            return mealsData.meals
        } catch {
            print("Error parsing data from list, check list endpoint!")
            throw MealError.DataParseError
        }
    }
    
    static func fetchMeal(mealId: String) async throws -> Meal {
        guard let url = URL(string: "\(mealEndpoint)\(mealId)") else {
            print("URL Error! Check endpoint for meal \(mealId)")
            throw MealError.URLError
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            print("Response error! Check endpoint for ID \(mealId)")
            throw MealError.ResponseError
        }
        
        do {
            /*
             ***API Returns a list of size 1 on success, nested in 'meals' field. GetMealDataResponse provides workaround for this***
             */
            let mealData = try JSONDecoder().decode(GetMealDataResponse.self, from: data)
            print("Success!")
            if mealData.meals.count == 0 {
                print("Parsing failed halfway through, see endpoint for id \(mealId)")
                throw MealError.DataParseError
            }
            return mealData.meals[0]
        } catch {
            print("Error parsing data from meal \(mealId), check endpoint: \(error)")
            throw MealError.DataParseError
        }
    }
    
}

enum MealError: Error {
    case URLError
    case ResponseError
    case DataParseError
}
