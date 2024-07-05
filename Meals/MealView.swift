//
//  MealView.swift
//  Meals
//
//  Created by Matthew Pohlhaus on 7/1/24.
//

import SwiftUI

struct MealView: View {
    var mealId: String
    @State private var mealData: Meal?
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    var body: some View {
        NavigationStack {
            if let meal = mealData {
                if verticalSizeClass != .compact {
                    ScrollView {
                        VStack {
                            AsyncImage(url: URL(string: meal.strMealThumb))
                                .frame(width: 380, height: 380)
                                .clipShape(.rect(cornerRadius: 10))
                            
                            HStack {
                                VStack {
                                    Text("Ingredients: ").frame(alignment: .leading).font(.title2)
                                    if let youtubeLink = meal.strYoutube {
                                        Text(.init("[YouTube Link](\(youtubeLink))"))
                                    }
                                }
                                ScrollView {
                                    ForEach(meal.ingredients, id: \.self) { ingredientData in
                                        Text("\(ingredientData.ingredient): \(ingredientData.measurement)")
                                    }
                                }
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10).stroke(.gray, lineWidth: 3)
                            )
                            Text("\(meal.strCategory) -- \(meal.strArea)").font(.footnote)
                            
                            Text("**Instructions:**").font(.title2)
                            Text(meal.strInstructions)
                                .font(.caption)
                                .padding()
                        }
                    }.navigationBarTitle(meal.strMeal)
                } else {
                    GeometryReader { metrics in
                        HStack {
                            ScrollView {
                                Text("\(meal.strCategory) -- \(meal.strArea)").font(.footnote)
                                VStack {
                                    AsyncImage(url: URL(string: "\(meal.strMealThumb)/preview"))
                                        .frame(width: metrics.size.width * 0.5)
                                        .clipShape(.rect(cornerRadius: 10))
                                
                                    Text("Ingredients:").font(.title3)
                                    ForEach(meal.ingredients, id: \.self) { ingredientData in
                                        Text("\(ingredientData.ingredient): \(ingredientData.measurement)")
                                    }
                                    if let youtubeLink = meal.strYoutube {
                                        Text(.init("[YouTube Link](\(youtubeLink))")).font(.footnote).padding()
                                    }
                                }
                            }
                            .frame(width: metrics.size.width * 0.5, alignment: .leading)
                            ScrollView {
                                Text("**Instructions:**").font(.title3)
                                Text(meal.strInstructions)
                                    .font(.caption)
                                    .padding()
                            }
                            .frame(width: metrics.size.width * 0.5)
                        }.navigationBarTitle(meal.strMeal)
                    }
                }
            } else {
                Text("Loading...")
            }
        }
        .task {
            guard let _ = mealData else {
                do {
                    mealData = try await APIController.fetchMeal(mealId: mealId)
                } catch {
                    print("Could not fetch meal!")
                }
                return
            }
        }
    }
}

#Preview {
    MealView(mealId: "52932")
}
