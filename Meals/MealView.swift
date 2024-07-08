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
                    VerticalMealView()
                        .environmentObject(meal)
                        .navigationBarTitle(meal.strMeal)
                } else {
                    HorizontalMealView()
                        .environmentObject(meal)
                        .navigationBarTitle(meal.strMeal)
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

struct VerticalMealView: View {
    @EnvironmentObject var meal: Meal
    var hasAdtlDetails: Bool {
        return meal.strDrinkAlternate != nil || meal.strTags != nil || meal.strSource != nil || meal.strCreativeCommonsConfirmed != nil || meal.dateModified != nil
    }
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: meal.strMealThumb))
                    .frame(width: 380, height: 380)
                    .clipShape(.rect(cornerRadius: 10))
                if let src = meal.strImageSource {
                    Text(.init("[(image source)](\(src.absoluteString))")).font(.footnote)
                }
                Text("\(meal.strCategory) -- \(meal.strArea)").font(.footnote)
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
                
                Text("**Instructions:**").font(.title2)
                Text("\(meal.strInstructions)\n")
                    .font(.callout)
                    .padding()

                if hasAdtlDetails {
                    Text("**Adtl Details:**")
                    if let drink = meal.strDrinkAlternate {
                        Text("Drink alternate: \(drink)")
                    }
                    if let tags = meal.strTags {
                        Text("Tags: \(tags)")
                    }
                    if let src = meal.strSource {
                        Text(.init("Original source: [HERE](\(src.absoluteString))"))
                    }
                    if let comm = meal.strCreativeCommonsConfirmed {
                        Text("Creative Commons Confirmed: \(comm)")
                    }
                    if let mod = meal.dateModified {
                        Text("Date modified: \(mod)")
                    }
                }
            }
                
        }
    }
}


struct HorizontalMealView: View {
    @EnvironmentObject var meal: Meal
    var hasAdtlDetails: Bool {
        return meal.strDrinkAlternate != nil || meal.strTags != nil || meal.strSource != nil || meal.strCreativeCommonsConfirmed != nil || meal.dateModified != nil
    }
    var body: some View {
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
                    if hasAdtlDetails {
                        Text("**Adtl Details:**")
                        if let drink = meal.strDrinkAlternate {
                            Text("Drink alternate: \(drink)")
                        }
                        if let tags = meal.strTags {
                            Text("Tags: \(tags)")
                        }
                        if let src = meal.strSource {
                            Text(.init("Original source: [HERE](\(src.absoluteString))"))
                        }
                        if let comm = meal.strCreativeCommonsConfirmed {
                            Text("Creative Commons Confirmed: \(comm)")
                        }
                        if let mod = meal.dateModified {
                            Text("Date modified: \(mod)")
                        }
                    }
                }
                .frame(width: metrics.size.width * 0.5, alignment: .leading)
                ScrollView {
                    Text("**Instructions:**").font(.title3)
                    Text(meal.strInstructions)
                        .font(.callout)
                        .padding()
                }
                .frame(width: metrics.size.width * 0.5)
            }
        }
    }
}

#Preview {
    MealView(mealId: "52932")
}
