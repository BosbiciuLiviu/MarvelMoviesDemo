
# MarvelMoviesDemo

Bunch of Marvel’s movies has been released till today. The problem is the movie has not
been released in chronological order. We have simple JSON API which is providing list of all
Marvel’s movies and detail information for each movie. This API is not publicly available and
require some authorization. We need application with 3 simple screens. Login screen (to get
access to API), list of movies which show list of all movies and allow sorting of movies in
chronological order or by release date and detail screen showing more detail information +
DVD cover image for chosen movie if it is available.

## Third-party libraries

* **KeychainAccess** was used to provide an abstract layer over the default Keychain methods. It helps when the app gets more complex.
* **AlertToast** was used to display the invalid credentials pop-up, mainly because it's lightweight and customizable for future uses.

## Notes

* available on **iOS15+**, could easily be made available on lower versions of iOS (13, 14) if we replaced **AsyncImage**.
* Given the size of the project, I’ve only used the main branch to develop this app. Of course, in a production environment, feature branches shall be used.
* Pagination should be implemented both on the server and client sides.
* The UI could be improved, but I kept it simple
* In a production environment, CoreData could be used to persist the data for offline use.



