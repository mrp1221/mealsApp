//
//  MealsTests.swift
//  MealsTests
//
//  Created by Matthew Pohlhaus on 7/1/24.
//

import XCTest
@testable import Meals

final class MealsTests: XCTestCase {

    func testCategoryEndpoint() async throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        guard let url = URL(string: APIController.categoryListEndpoint) else {
            XCTFail("Failed to construct category URL")
            return
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        if let response = response as? HTTPURLResponse {
            XCTAssertEqual(response.statusCode, 200)
        } else {
            XCTFail("Category API returned bad response")
        }
        XCTAssertNotNil(data)
    }
    
    func testMealListEndpoint() async throws {
        guard let url = URL(string: "\(APIController.mealListEndpoint)Dessert") else {
            XCTFail("Failed to construct dessert category URL")
            return
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        if let response = response as? HTTPURLResponse {
            XCTAssertEqual(response.statusCode, 200)
        } else {
            XCTFail("Meal List API returned bad response")
        }
        XCTAssertNotNil(data)
    }
    
    func testMealEndpoint() async throws {
        guard let url = URL(string: "\(APIController.mealEndpoint)52932") else {
            XCTFail("Failed to construct meal URL")
            return
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        if let response = response as? HTTPURLResponse {
            XCTAssertEqual(response.statusCode, 200)
        } else {
            XCTFail("Meal API returned bad response")
        }
        XCTAssertNotNil(data)
    }
    
    func testGetCategoryList() async throws {
        do {
            let categories = try await APIController.fetchCategoryList()
            XCTAssertNotEqual(0, categories.count)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testGetMealList() async throws {
        do {
            let desserts: [MealReference] = try await APIController.fetchMealList(category: "Dessert")
            XCTAssertNotEqual(0, desserts.count)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testGetMeal() async throws {
        do {
            let meal: Meal = try await APIController.fetchMeal(mealId: "52932")
            XCTAssertNotNil(meal)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

}
