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
                CategoryListView(categoryData: categories)
                    .navigationTitle("Meal Categories")
            } else {
                Text("Loading...").font(.title)
            }
        }
        .task {
            guard let _ = categoryData else {
                do {
                    print("FETCHING DATA")
                    categoryData = try await APIController.fetchCategoryList().sorted {
                        $0.strCategory < $1.strCategory
                    }
                } catch {
                    print("Error!")
                }
                return
            }
        }
    }
}

struct CategoryListView: View {
    @State var categoryData: [Category]
    @State var searchText: String = ""
    var body: some View {
        List {
            ForEach(categories, id: \.self) { category in
                NavigationLink(destination: CategoryPageView(category: category.strCategory)
                    .navigationBarTitleDisplayMode(.inline)) {
                        Text(category.strCategory).font(.title).padding()
                    }
            }
        }.searchable(text: $searchText)
    }
    
    var categories: [Category] {
        return searchText.isEmpty ? categoryData : categoryData.filter { $0.strCategory.contains(searchText) }
    }
}

#Preview {
    HomePageView()
}
