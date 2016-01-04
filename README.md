
## YACA

#### yet another calendar application

The main intention here was to create an application used as capstone project for the iOS nanoDegree at udacity.com

#### Introduction
The application was started with the idea to show meetings of an individual Calendar (selectable in the Settings Tab) and pull additional information like Attendees and use available API's to get more information about attendees, like Timezone, Weather ( all based on location of attendee usually available through Contacts ). After running into some challenges like the Exchange Contacts are not retrievable through the Contacts App in iOS, I decided to add an additional functionality to be able to place notes per meeting.

The notes will be stored in Core Data and do have a reference to the original meeting, even if this meeting is not available anymore a TableView Controller does provide the note itself.

The app takes use of a CollectionView on the Homescreen which got slightly adjusted to look like Cards placed horizontally. X represents the timeline and sections were introduced to distinguish between days.

To get the app probably tested it is required to have a Calendar with at least 1 meeting in there. To see the full functionality it is required to have a meeting with invited attendees which are having an entry in the Contacts, including at least a Country (for retrieving the timezone and weather information).

The app does not take care of recurring meetings at the moment !


#### Features at a glance

* retrieve **data from Calendar** (requiring to allow access, otherwise nothing will be shown !)
* retrieve **data from Contacts** based on attendees in Meetings from Calendar (access have to be allowed as well)
* Show information in a special formated **Collection View** including sections (per day)
* embedded **TableView** into Collection View Cell to visualize participants
* Notes section in Collection View ... possibility to switch between Notes and Participants
* **Custom Segment Control** on Home Screen
* Store Participants + additional information from API's in **Core Data** and refresh on hourly basis only (weather + timezone -information does not change that frequently, so it's possible to work with cached Core Data information only for some time)
* Store notes in Core data

#### Requirements/Recommendations to have the Application tested

* Create some events today and in the next days including attendees, just invite the Standard installed folks like *John Appleseed* (they have an address entry as well which is a requirement)
* It is required to have an Internet Connection to have the restclient working, if not available you are still able to use the app but you will not get the proper information
* As soon at least 1 event is setup you can see the cards within YACA.
* At first time startup you will get asked to select a calendar, which will be used as basis for the Overview ( can be changed everytime in the settings )
* To have the notes tested you just put some notes into one of the meetings, those will be either saved by taping outside of the notefield or by hitting the *Save Button*
* You can review the notes under All Notes with the ability to delete by either opening the note and using the basket-icon or by swiping from right to left and using the appearing DELETE button
* Typing on an attendee in the Collection View Cell gives you some information about the location of the attendee and some current facts, like weather and times

#### Things to improve in a possible future version (just some kind of notes)

* Show some additional information in CollcetionView to visualise current location in Calendar (showing week on top or similar)
* Model to be splitted up into more entities including proper relationships, Location > Weather and Location > Timezone
* Currently only local Contacts are used to determine a Location, LDAP search for i.e. exchange would add a lot of value for Enterprise customers
* iCloud support (especially for Notes)

Thats all folks, seems to be quiet easy app and far away from being something I would call final, but it is a working app demonstrating some nice techniques in several aspects.

##### References ( and used code from other parties)

* Custom segmented control by appdesignvault ( https://www.youtube.com/watch?v=qT1ZEE2CBDQ ) 
* Ray Wenderlich ( http://www.raywenderlich.com/ ) helped me with a lot of challenges during my dev process as well as
* Andrew Bancroft ( https://www.andrewcbancroft.com/category/software-development/ios-mac/swift/ )