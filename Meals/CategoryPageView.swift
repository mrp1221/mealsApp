//
//  HomepageView.swift
//  Meals
//
//  Created by Matthew Pohlhaus on 7/1/24.
//

import SwiftUI

struct CategoryPageView: View {
    @State private var mealsData: [MealReference]?
    @State private var searchText = ""
    var category: String
    var body: some View {
        NavigationStack {
            if var meals = mealsDisplay {
                List {
                    ForEach(meals, id: \.self) { meal in
                        NavigationLink(destination: MealView(mealId: meal.idMeal)
                            .navigationBarTitleDisplayMode(.inline)) {
                            HStack {
                                AsyncImage(url: URL(string: "\(meal.strMealThumb)/preview"))
                                    .frame(width: 120, height: 70)
                                    .clipShape(.rect(cornerRadius: 10))
                                Text(meal.strMeal).padding()
                            }
                        }
                    }.listRowSeparator(.visible, edges: .all)
                }
                .listStyle(.insetGrouped)
                .searchable(text: $searchText)
                .navigationTitle("\(category) Dishes")
            } else {
                Text("Loading...").font(.title)
            }
        }
        .task {
            guard let _ = mealsData else {
                do {
                    mealsData = try await APIController.fetchMealList(category: category).sorted {
                        $0.strMeal < $1.strMeal
                    }
                } catch {
                    print("Error!")
                }
                return
            }
        }

    }
    
    var mealsDisplay: [MealReference]? {
        if let data = mealsData {
            if searchText.isEmpty {
                return data
            } else {
                return data.filter { $0.strMeal.contains(searchText) }
            }
        } else {
            return []
        }
    }
}

#Preview {
    CategoryPageView(category: "Dessert")
}
