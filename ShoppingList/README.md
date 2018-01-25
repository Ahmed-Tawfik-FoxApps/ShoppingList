# Shopping List - v 1.0

## App Description - User Experience:
Shopping List App is designed to manage the shopping lists for the house, school, store, etc..
The user has to login using a _Google_ account (Tester account details mentioned below), once the user login, the App will show all the shopping lists associated to this specific user, if it is the first login for this user, the App will create a Demo List.

>Tester account details:

>Email: shoppinglist.tester@gmail.com

>Password: shoppinglist@udacity.com

>This account never been used to sign in with Shopping List, to give the tester the full experience.

After Sign In, The User can:
- **Sign Out** by clicking the "Sign Out" button located at the upper left corner.
- **Sign In** again using the same _Google_ account or a different _Google_ Account by clicking the sign in button.
- **Add** new list by clicking the "+" button located in the upper right corner.
- **Sort** the existing lists by "Name" or by "Due Date" by clicking the "ABC" or "123" button located at the left side of the "+" button.
- **Edit** a specific list by long press (0.5 sec) on any of the existing lists which enables the user to change the "List Name", "Due Date", and add/remove items from the list.
- **Put** a specific list in action by clicking the selected list and then the user will be able to see all the items associated with the selected list in 2 sections "ToDo" section for the items need to be purchased and "Done" section for the purchased items. The User has the ability to mark any item as purchased or un purchased at any time.
- **Delete** any list by left swipe on the desired list.

## User Interface
The ViewControllers are described in details below:

### SigninViewController:
Allow the user to sign in with _Google_ Account, then it checks if the user is not found in the database it creates a new user and attach a Demo List to this user, and if the user is already there it will get all the user information including the user lists. After that the App will show the ListsViewController.

### ListsViewController:
This view show all the associated shopping lists for the current user and allow the user to:
- **Sign Out** by clicking the "_Sign Out_" button located at the upper left corner.
- **Add** new lists by clicking the "_+_" button located in the upper right corner, then it shows the next appropriate view "AddEditListViewController".
- **Sort** the existing lists by "**Name**" or by "**Due Date**" by clicking the "_ABC_" or "_123_" button located at the left side of the "_+_" button.
- **Edit** a specific list by _long press_ (**0.5 sec**) on any of the existing lists, then it shows the next appropriate view "AddEditListViewController".
- **Put** a specific list in action by _clicking_ the selected Shopping List, then it shows the next appropriate view "ListDetailsViewController".
- **Delete** any list by left swipe on the desired list.

### AddEditListViewController:
- If the user decide to add a new list by clicking "_+_" in the previous view, this view will open with a new fresh list with no items selected either list name. Once the User is finished just click "_Done_" to create this list and store it in the DB.
- But if the user decide to edit a current list, this view will open the current list for edit and will enable the user to change the List Name, the Due Date, add/remove items from the list. Once the User is finished just click "_Done_" to update this list and store it in the DB.

If the user want to discard all the changes or cancel the new list creation, all what is required is clicking the back button "_< Shopping Lists_"


### ListDetailsViewController:
This view will show:
- List Name
- Number of completed items / total number of items, and if all the items is marked as Done it will show the text "All items have been purchased and will show a green check mark as well.
- If this list has no items, will notify the user that this list has no items (in red color)
- Section for the items marked as **ToDo** which still need to be purchased
- Section for the items marked as **Done** which already marked as purchased

The user mark the item as purchased by just clicking on that items in the **ToDo** section, if the user need to return this item back into the **ToDo** section, just click on that item again but this time at the **Done** Section.

## Network Activities
As _Firebase_ reads from the local database in case of no internet connection or a weak connection, the activity indicator may not be show very often.

Regarding the items images, the App using a library (_SDWebImage_) that download the images from the URL and cache it on the device. That is why the activity indicator for the items collection view images will be shown **only for the first time** the App is running or again in case the cache is deleted and the App will download the images again.

In case of no internet connection and the user is signed out, a notification in red will be shown in the login screen that notify the user there is no internet connection and the online feature (DB sync) will be no longer available. If the user click on the signing button the browser will also tell the user that no internet connection.

## Persistent
Shopping List is using _Firebase_ as a backend and uses the persistence provided by the _Firebase_. And based on the offline capabilities of _Firebase_ the app works properly even without internet connection, except it will alert the user that there is no internet connection and the online feature (DB sync) will be no longer available.

If the User lost connection during the usage of the App, all the features will continue working _except a notification will show_. Once the connection is retrieved the App will sync all the offline data on the local database with the _Firebase_ however it take some time to sync the data with the _Firebase_.
