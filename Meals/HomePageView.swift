//
//  HomePageView.swift
//  Meals
//
//  Created by Matthew Pohlhaus on 7/3/24.
//

import SwiftUI

struct HomePageView: View {
    @State private var categoryData: [Category]?
    var body: some View {
        NavigationStack {
            if let categories = categoryData {
                List {
                    ForEach(categories, id: \.self) { category in
                        NavigationLink(destination: CategoryPageView(category: category.strCategory)
                            .navigationBarTitleDisplayMode(.inline)) {
                                Text(category.strCategory).font(.title).padding()
                            }
                    }
                }
                .navigationTitle("Meal Categories")
            } else {
                Text("Loading...").font(.title)
            }
        }
        .task {
            guard let _ = categoryData else {
                do {
                    print("FETCHING DATA")
                    categoryData = try await APIController.fetchCategoryList()
                } catch {
                    print("Error!")
                }
                return
            }
        }
    }
}

#Preview {
    HomePageView()
}
