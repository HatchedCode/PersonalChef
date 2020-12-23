#   IOS Application Information:
**Application is built target**: mainly for iPhone 8\
**Orientation**: Portrait\
**Target**: iPhone and iPad\
**Features**:
  - **Main Page**
    - Random Recipe at the top
    - Nearby restaurants (If user accepts locationServices)
      - By default, the nearby restaurants have featured(random) food\
      - The user can type in and look for nearby foods
  - **Favorite Recipes**
    - Has all the recipes that users favorited
      - Retrieved via Core Data
    - Swipe deletes the food as a favorite
    - Clicking on it brings up a page where there is information on that food/recipe
      - Start Cooking button that will fire a notification after the cook time of the recipe.
  - **Browse Recipes**
    - Search for food
    - View result of searched food/recipe\
**IOS Frameworks**:
  - Core Data -- favorite foods.
  - Core Location – search nearby foods for eats.
  - UserNotifications – set cooking start\

**Similar Applications**:
  - Food application that we have created, but I am intending to allow user to browse\food and save them as favorites while seeing a random food
  
**Will be using https://spoonacular.com/food-api/ to get the food information**

**Additional information:**
There is a list of the user’s favorite foods with images. The user can add a new\
favorite food. This triggers an API request for this food, and up to 10 results (food\
name and image) are presented to the user. The user can select one (or cancel). If\
one is selected, then that food name and image is added to the favorites list.

- The user can search for nearby places related to a favorite food and view the
places on a map.
- Each favorite food has an associated favorite recipe for that food.
- The user can make an API request for recipes containing a favorite food, see a list of\
up to 10 of the recipe titles with images. If the user selects one, then that recipe is\
saved and associated with the favorite food.
- Tapping on a favorite recipe brings up the steps and cooking time of the recipe\
(extracted from the API request). The user can tap a button to schedule a\
notification to appear after the cooking time has passed.
- All of the above-mentioned data is stored persistently in the app, so it is still available\
when the app is terminated and restarted, even if an internet connection is\
unavailable.




#   How To Use The Application:
This documentation provides the different functionalities of the application with the
detailed steps on how to access those different functionalities.

**Browse Foods**:
1. Open the application
2. Click on the magnifying glass item on the tab bar (far right)
3. You are at the browse foods page


**Browse Recipes:**
1. Click on the magnifying glass on the tab bar menu
2. Click on any food
3. Another view controller should appear and the recipes for that food should be
there.


**Add Recipes as Favorites:**\
There are 3 ways to add a recipe was a favorite:
1. Through the Main (Home) tab\
  1.1. Launch the application, click on the Home tab\
  1.2. Click on the favorite button (should turn yellow)\
  1.3. The button will get disabled, the food should be in the favorites tab and the recipe is added as a favorite too.
2. Through the Detailed Random Recipe View\
  2.1. Launch the application, click on the Home tab\
  2.2. Click on the image\
  2.3. The detailed view will appear\
  2.4. Click on the Favorite bar button on the top right and the button should turn yellow and the recipe is saved as a favorite.
3. Through the Browse Foods\
  3.1. Open the application\
  3.2. Click on the magnifying glass item on the tab bar (far right)\
  3.3. Click on a food\
  3.4. Click on a recipe (click on refresh on the top right, if the images do not load up, loading took longer than usual threads)\
  3.5. Once you click on a recipe an alert should appear confirm that you want to add the recipe as a favorite, once yes is clicked then the recipe is added as a favorite.
6. If no is clicked, then nothing occurs

**View instructions of a random recipe:**
1. Click on the Home tab button item
2. Click on the image of the random recipe
3. The instructions for the recipe should be there if the recipe has any.

**Delete a favorite Food:**
1. Click on the favorites tab bar item
2. Swipe to delete on the food that you want to delete
3. The food and the associated recipes are now deleted

**Delete Favorite Recipe:**
1. Click on the favorites tab bar item
2. Click on the food that you want to view the recipes of.
3. Swipe to delete on the recipe that you want to delete and it will be deleted.

**Schedule Notification for recipe:**
1. Click on the favorites tab bar item
2. Click on the food that you want to view the recipes of.
3. Click on the recipe that you want to schedule an alert for.
4. Now click on Start cooking!
5. An alert will appear asking if you want to schedule the notification
6. Once you click yes, the notification is fired for the amount of time it takes to\prepare the recipe (in seconds OfCourse since minutes would take too long).
7. If no is clicked, nothing happens

**Search for Nearby Foods (Favorite Food):**
1. Click on the favorites tab bar item
2. Click on the search Nearby for Food button for the corresponding food that you\want to check nearby areas for.
3. Once click a new view controller will appear with the Map
4. You should see the food that are near you, if there are any

**Search for foods (available foods):**
1. Click on the Browse tab bar item
2. In the TextField type anything that you want to look up that is available
3. Click on search button
4. The result of the search will pop up (if there are any)

**Search for Nearby Foods (Any Food):**
1. Click on the Home tab bar item
2. Scroll down to see the Map and the TextField.
3. By default the food that is found on the map is the random food that was selected
4. You can type in some food name
5. Click Find! Then the nearby foods that you typed in should be there.

If you have any other questions or concerns please email at odbakari@gmail.com.
