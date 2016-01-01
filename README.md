
## YACA

#### yet another calendar application

The main intention here was to create an application used as capstone project for the iOS nanoDegree at udacity.com

#### Introduction
The application was started with the idea to show meetings of an individual Calendar (selectable in the Settings Tab) and pull additional information like Attendees and use available API's to get more information about attendees, like Timezone, Weather ( all based on location of attendee usually available through Contacts ). After running into some challenges like the Exchange Contacts are not retrievable through the Contacts App in iOS, I decided to switch the focus a bit but keep some functionality still available.

YACA is now able to take notes by Meetings which will be stored in Core Data.
In addition, at least the timezone will be retrieved from the restcountries API in case a Contact got found in the Contacts APP. In addition all attendees will be stored in Core Data as well, especially because information like timezone can be retrieved offline as well (which is anyway no problem for the Meetings in the Calendar ... that's the reason why Meetings are not stored in CoreData! ). Notes taken can either be reviewed on the Home Screen, whereat past meetings will not be shown anymore. Because of that there is a All Notes Tab which is presenting All Notes in a TableView, with the opportunity to delete them and also to review them (editing them was not added!)

The app takes use of a CollectionView on the Homescreen which got slightly adjusted to look like Cards placed horizontally. X represents the timeline and sections were introduced to distinguish between days.

To get the app probably tested it is required to have a Calendar with at least 1 meeting in there. To see the full functionality it is required to have a meeting with invited attendees which are having an entry in the Contacts, including at least a Country (for retrieving the timezone).

The app does not take care of recurring meetings at the moment !
In addition iCloud storage was enabled as well which provides the opportunity to have the same Core Data information synched between devices... this is more or less a test implementation, it does not add much value but shows how easy it is to have Core Data running in combination with iCloud!

#### Features at a glance

* retrieve data from Calendar (requiring to allow access, otherwise nothing will be shown !)
* retrieve data from Contacts based on attendees in Meetings from Calendar (access have to be allowed as well)
* Show information in a special formated Collection View including sections (per day)
* embedded TableView into Collection View Cell to visualize participants
* Notes section in Collection View ... possibility to switch between Notes and Participants
* Custom Segment Control on Home Screen
* Store Participants + additional information from API in Core Data
* Store notes in Core data
* Store Core Data on iCloud

#### Requirements/Recommendations to have the Application tested

* If you are running in Simulator it is recommended to have iCloud activated, with that you get the ability to invite other folks to your Events in your Calendar
* Create some events today and in the next days including attendees, just invite the Standard installed folks like *John Appleseed*
* It is required to have an Internet Connection to have the restclient working, if not available you are still able to use the app but you will not get the proper information
* As soon at least 1 event is setup you can start YACA.
* At first time startup you will get asked to select a calendar, which will be used as basis for the Overview ( can be changed everytime in the settings )
* To have the notes tested you just put some notes into one of the meetings, those will be either saved by taping outside of the notefield or by hitting the *Save Button*
* You can review the notes under All Notes with the ability to delete by either opening the note and using the basket-icon or by swiping from right to left and using the appearing DELETE button
* Typing on an attendee in the Collection View Cell gives you some information about the location of the attendee and some current facts, like weather, time + ...

Thats all folks, seems to be quiet easy app and far away from being something I would call final, but it is a working app demonstrating some nice techniques in several aspects.