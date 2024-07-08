# Meals App

This repo is my submission for the take-home assessment for the iOS Engineer position at Fetch. It is a wrapper for the API found here: https://themealdb.com/api.php. It allows users to browse categories of meals, browse each meal of a selected category, and view a page with details of any meal they may select. My implementation of the logic for communicating with the API is located in Meals/APIController.swift, and the views are located in the files Meals/HomePageView.swift, Meals/CategoryPageView.swift, and Meals/MealView.swift. There are also a couple of basic unit tests to ensure the functionality of the API located in MealsTests/MealsTests.swift. The views for the home page and the pages displaying the list of meals in each category are both filterable via a search bar at the top of the list, and the pages that display the meal data has custom views that update dynamically when the display is rotated sideways.

Here you can see the page the user is greeted with when first opening up the app:

<img width="419" alt="image" src="https://github.com/mrp1221/mealsApp/assets/83693148/b34fdb61-7261-4bd1-adfa-381adae76693">

It is a simple view that displays each category in a scrollable list. When the user selects a category, they will be taken to a page listing each meal that belongs to that category, as seen here:

<img width="477" alt="image" src="https://github.com/mrp1221/mealsApp/assets/83693148/95a99511-0212-4e1a-809f-4b5f8991b2ff">

Notice how a user can scroll to the top to reveal a search bar, which can be used to filter the results:

<img width="498" alt="image" src="https://github.com/mrp1221/mealsApp/assets/83693148/1b390da0-8667-4036-93ed-63a5eca0c9d5">

When a user selects a meal, they are directed to a page showing all available data the API has for that meal in am organized, readable view, which includes details on the ingredients required and instructions for making the meal, and if available, a link to a YouTube video with instructions for preparing the dish.

<img width="479" alt="image" src="https://github.com/mrp1221/mealsApp/assets/83693148/ee99a766-9576-4295-8cce-4c94a97d5a8b">

If the device is turned horizontally while in this view, it will render in a different manner, displaying two different scrollable displays on each half of the screen. One contains the thumbnail image, if present, and other details about the dish, while the other contains the instructions.

<img width="853" alt="image" src="https://github.com/mrp1221/mealsApp/assets/83693148/38ea9b1d-c1bc-43b0-9313-281dc653eac4">

Please let me know if you have any questions about the app's implementation or functionality. Thank you very much for taking the time to review my work -- I had a lot of fun completing this project, and I am grateful for your consideration.
