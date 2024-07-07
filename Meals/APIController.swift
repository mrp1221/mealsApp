//
//  APIController.swift
//  Meals
//
//  Created by Matthew Pohlhaus on 7/1/24.
//

import Foundation

struct GetMealListResponse: Decodable {
    let meals: [MealReference]
}

struct MealReference: Decodable, Hashable {
    enum MealRefCodingKeys: String, CodingKey {
        case strMeal, strMealThumb, idMeal
    }
    enum CategoryRefKeys: String, CodingKey {
        case strCategory
    }
    
    let strMeal: String
    let strMealThumb: String
    let idMeal: String
    let strCategory: String
    
    init(from decoder: any Decoder) throws {
        let mealContainer = try decoder.container(keyedBy: MealRefCodingKeys.self)
        let categoryContainer = try decoder.container(keyedBy: CategoryRefKeys.self)
        self.strMeal = try mealContainer.decodeIfPresent(String.self, forKey: .strMeal) ?? ""
        self.strMealThumb = try mealContainer.decodeIfPresent(String.self, forKey: .strMealThumb) ?? ""
        self.idMeal = try mealContainer.decodeIfPresent(String.self, forKey: .idMeal) ?? ""
        self.strCategory = try categoryContainer.decodeIfPresent(String.self, forKey: .strCategory) ?? ""
    }
}

// Individual meals are returned in a list of size 1
struct GetMealDataResponse: Decodable {
    let meals: [Meal]
}

final class Meal: Decodable, ObservableObject {
    enum StringCodingKeys: String, CodingKey {
        case idMeal, strMeal, strDrinkAlternate, strCategory, strArea, strInstructions, strMealThumb, strTags, strYoutube, strSource, strImageSource, strCreativeCommonsConfirmed, dateModified
    }
    
    struct IngredientData: Hashable {
        let ingredient: String
        let measurement: String
    }
    
    struct DynamicCodingKeys: CodingKey {
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
        let customContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        let defaultContainer = try decoder.container(keyedBy: StringCodingKeys.self)
        
        self.idMeal = try defaultContainer.decodeIfPresent(String.self, forKey: .idMeal) ?? ""
        self.strMeal = try defaultContainer.decodeIfPresent(String.self, forKey: .strMeal) ?? ""
        self.strDrinkAlternate = try defaultContainer.decodeIfPresent(String.self, forKey: .strDrinkAlternate) ?? ""
        self.strCategory = try defaultContainer.decodeIfPresent(String.self, forKey: .strCategory) ?? ""
        self.strArea = try defaultContainer.decodeIfPresent(String.self, forKey: .strArea) ?? ""
        self.strInstructions = try defaultContainer.decodeIfPresent(String.self, forKey: .strInstructions) ?? ""
        self.strMealThumb = try defaultContainer.decodeIfPresent(String.self, forKey: .strMealThumb) ?? ""
        self.strTags = try defaultContainer.decodeIfPresent(String.self, forKey: .strTags) ?? ""
        self.strYoutube = try URL(string: defaultContainer.decodeIfPresent(String.self, forKey: .strYoutube) ?? "") ?? nil
        self.strSource = try URL(string: defaultContainer.decodeIfPresent(String.self, forKey: .strSource) ?? "") ?? nil
        self.strImageSource = try URL(string: defaultContainer.decodeIfPresent(String.self, forKey: .strImageSource) ?? "") ?? nil
        self.strCreativeCommonsConfirmed = try defaultContainer.decodeIfPresent(String.self, forKey: .strCreativeCommonsConfirmed) ?? ""
        self.dateModified = try defaultContainer.decodeIfPresent(String.self, forKey: .dateModified) ?? ""
        
        self.ingredients = []
        for i in 1...20 {
            let ingredientKey = DynamicCodingKeys(stringValue: "strIngredient\(i)")
            let measurementKey = DynamicCodingKeys(stringValue: "strMeasure\(i)")
            
            if let ingredient = try? customContainer.decodeIfPresent(String.self, forKey: ingredientKey),
               let measurement = try? customContainer.decodeIfPresent(String.self, forKey: measurementKey) {
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
    
    static func fetchList(categoryQuery: String? = nil) async throws -> [MealReference] {
        let urlString = categoryQuery.map { "\(mealListEndpoint)\($0)" } ?? categoryListEndpoint
        print(urlString)
        
        guard let url = URL(string: urlString) else {
            print("URL Error!! Check list endpoint")
            throw MealError.URLError
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        print(type(of: data))
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            print("Response Error! Check list endpoint")
            throw MealError.ResponseError
        }
        
        do {
            let mealsData = try JSONDecoder().decode(GetMealListResponse.self, from: data)
            print("Success!!")
            return mealsData.meals
        } catch {
            print("Error parsing data from list, check list endpoint!", data)
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
