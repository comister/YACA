//
//  MeetingsViewController.swift
//  YACA
//
//  Created by Andreas Pfister on 13/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import Foundation
import UIKit
import EventKit
import Contacts
import CoreData

class MeetingsViewController: UIViewController, DataSourceDelegate, CLLocationManagerDelegate {
    
    var backgroundGradient: CAGradientLayer? = nil
    var meeting: Meeting!
    var locationManager: CLLocationManager!
    var events = [EKEvent]()
    let eventStore = EKEventStore()
    var calendars: [EKCalendar]?
    var selectedCalendar: String?
    var duration: Int = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var tapRecognizer: UITapGestureRecognizer? = nil
    @IBOutlet weak var meetingCollectionView: UICollectionView!
    @IBOutlet weak var calendarName: UILabel!
    @IBOutlet weak var durationSgements: CustomSegmentedControl!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noConnectionIndicator: UILabel!
    @IBOutlet weak var noConnectionIndicatorText: UILabel!
    @IBOutlet weak var noAccessView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.meetingCollectionView?.register(UINib(nibName: "MeetingListCellHeader", bundle: nil), forSupplementaryViewOfKind:UICollectionElementKindSectionHeader, withReuseIdentifier: "meetingCellHeader")
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MeetingsViewController.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1
        tapRecognizer?.cancelsTouchesInView = false
        Datasource.sharedInstance.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(MeetingsViewController.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        Reach().monitorReachabilityChanges()
        
    }
    
    @objc func networkStatusChanged(_ note: Notification) {
        let status = Reach().connectionStatus()
        switch status {
            case .unknown, .offline:
                startConnectivityAnimation()
            case .online(.wwan), .online(.wiFi):
                stopConnectivityAnimation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
        addKeyboardDismissRecognizer()
        
        // Check authorization for Calendar and Contacts
        if checkCalendarAndContactsAccess() {
            self.noAccessView.isHidden = true
        }
        
        // Initialize LocationManager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        
        // MARK: - Load Events from selected Calendar
        if (UserDefaults.standard.string(forKey: "selectedCalendar") != nil) {
            self.selectedCalendar = UserDefaults.standard.string(forKey: "selectedCalendar")
            calendarName.text = self.eventStore.calendar(withIdentifier: self.selectedCalendar!)?.title
        } else {
            self.tabBarController?.selectedIndex = 2
            return
        }
        // MARK: - Adjust custom control and set duration
        durationSgements.items = ["1 day", "1 week", "1 month"]
        durationSgements.font = UIFont(name: "Roboto-Regular", size: 12)
        durationSgements.borderColor = UIColor(white: 1.0, alpha: 0.3)
        durationSgements.addTarget(self, action: #selector(MeetingsViewController.changeDuration(_:)), for: .valueChanged)
        
        self.duration = getDurationOfIndex(UserDefaults.standard.integer(forKey: "durationIndex"))
        self.loadEvents()
        
        let status = Reach().connectionStatus()
        switch status {
        case .unknown, .offline:
            noConnectionIndicatorText.text = "no connection\nworking offline"
            startConnectivityAnimation()
        default:
            noConnectionIndicatorText.text = "bad connection"
            stopConnectivityAnimation()
        }
    }
    
    func checkCalendarAndContactsAccess() -> Bool {
        var returnValue = true
        appDelegate.checkCalendarAuthorizationStatus() {
            granted in
            if !granted {
                self.noAccessView.isHidden = false
                self.noAccessView.fadeIn()
                returnValue = false
            }
        }
        
        appDelegate.checkContactsAuthorizationStatus() {
            granted in
            if !granted {
                self.noAccessView.isHidden = false
                self.noAccessView.fadeIn()
                returnValue = false
            }
        }
        return returnValue
    }
    
    // MARK: - Using the delegate of Datasource to determine Indicator appearance
    func DataSourceFinishedProcessing() {
        DispatchQueue.main.async {
            self.meetingCollectionView.isHidden = false
            self.meetingCollectionView.reloadData()
            self.loadIndicator.stopAnimating()
        }
    }
    
    func DataSourceStartedProcessing() {
        DispatchQueue.main.async {
            self.loadIndicator.startAnimating()
        }
    }
    
    func ConnectivityProblem(_ status: Bool) {
        if status == true {
            startConnectivityAnimation()
        } else {
            stopConnectivityAnimation()
        }
    }
    
    func startConnectivityAnimation() {
        if self.noConnectionIndicatorText.layer.animation(forKey: "animateOpacity") == nil {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.duration = 0.4
            animation.repeatCount = 45
            animation.autoreverses = true
            animation.fromValue = 0.1
            animation.toValue = 1.0
            DispatchQueue.main.async {
                self.noConnectionIndicator.isHidden = false
                self.noConnectionIndicatorText.isHidden = false
                self.noConnectionIndicatorText.layer.add(animation, forKey: "animateOpacity")
                self.noConnectionIndicator.layer.add(animation, forKey: "animateOpacity")
            }
        }
    }
    
    func stopConnectivityAnimation() {
        DispatchQueue.main.async {
            self.noConnectionIndicator.layer.removeAnimation(forKey: "animateOpacity")
            self.noConnectionIndicator.isHidden = true
            self.noConnectionIndicatorText.layer.removeAnimation(forKey: "animateOpacity")
            self.noConnectionIndicatorText.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // MARK: - Apply value to segmented control after view is visible, otherwise uiview.animate is not working
        durationSgements.selectedIndex = UserDefaults.standard.integer(forKey: "durationIndex")
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardDismissRecognizer()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "kRefetchDatabaseNotification"),object: nil )
    }
    
    func locationManager(_ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedAlways || status == .authorizedWhenInUse {
                locationManager.startUpdatingLocation()
            } else if status == .authorizedWhenInUse || status == .restricted || status == .denied {
                let alertController = UIAlertController(
                    title: "Background Location Access Disabled",
                    message: "To be able to see information about your current location it is recommended to enable location access.",
                    preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                    if let url = URL(string:UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.openURL(url)
                    }
                }
                alertController.addAction(openAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
    }
    
    // MARK: - Returns seconds for 1 day (index=0), 1 week (index=1) and 1 month (index=2)
    func getDurationOfIndex(_ index: Int) -> Int {
        var duration = 0
        switch index {
            case 0:
                duration = 86400
            case 1:
                duration = 604800
            case 2:
                duration = 2419200
            default:
                duration = 0
        }
        return duration
    }
    
    @objc func changeDuration(_ sender: AnyObject?) {
        let localDuration = getDurationOfIndex(durationSgements.selectedIndex)
        UserDefaults.standard.setValue(durationSgements.selectedIndex, forKey: "durationIndex")
        UserDefaults.standard.setValue(localDuration, forKey: "duration")
        self.duration = localDuration
        self.loadEvents()
    }
    
    // MARK: - Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Participant> = {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Meeting.statics.entityName)
        fetchRequest.predicate = NSPredicate(format: "meeting == %@", self.meeting)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Meeting.Keys.Name, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController as! NSFetchedResultsController<Participant>
        
    }()
    
}

// MARK: - CollectionView related methods
extension MeetingsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Datasource.sharedInstance.daysOfMeeting.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: IndexPath) {
        //something to do when clicked --- NOPE, we are having all interactions within the Cell itself
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "meetingCellHeader", for: indexPath) as? MeetingListCellHeader

        headerCell?.dayLabel.text = Datasource.sharedInstance.getSpecialWeekdayOfDate((Datasource.sharedInstance.sortedMeetingArray[indexPath.section]))
        
        return headerCell!
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let currentDate = Datasource.sharedInstance.sortedMeetingArray[section]
        let currentDateObjects = Datasource.sharedInstance.daysOfMeeting[currentDate]
        return currentDateObjects!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "meetingViewCell", for: indexPath) as! MeetingListCell
        
        let currentDate = Datasource.sharedInstance.sortedMeetingArray[indexPath.section]
        let currentDateObjects = Datasource.sharedInstance.daysOfMeeting[currentDate]
        // iterate through meetings, set necessary values and reload tableview in cell 
        if let meetingObject = currentDateObjects![indexPath.row] as? Meeting {
            cell.calendarName.text = meetingObject.name
                    
            if Date.areDatesSameDay(meetingObject.starttime, dateTwo: meetingObject.endtime) {
                cell.timingLabel?.text = (Datasource.sharedInstance.getTimeOfDate(meetingObject.starttime)) + " - " + (Datasource.sharedInstance.getTimeOfDate(meetingObject.endtime))
            } else {
                cell.timingLabel?.text = (Datasource.sharedInstance.getTimeOfDate(meetingObject.starttime)) + " - " + (Datasource.sharedInstance.getTimeOfDate(meetingObject.endtime))
            }
            cell.cellIdentifier = "meetingParticipant_" + String(indexPath.row)
            cell.meeting = meetingObject
            cell.participantDetails.isHidden = true
            cell.participantTable.reloadData()
            cell.configureUI()
            if let meetingNote = meetingObject.note {
                cell.notesText.text = meetingNote.note
            } else {
                cell.notesText.text = ""
            }
        }
        return cell
    }
}

// MARK: - Customize UI

extension MeetingsViewController {
    
    func configureUI() {
        /* Configure background gradient */
        self.view.backgroundColor = UIColor.clear
        //let colorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).CGColor
        let colorTop = UIColor(red: 1, green: 0.680, blue: 0.225, alpha: 1.0).cgColor
        //let colorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 1, green: 0.594, blue: 0.128, alpha: 1.0).cgColor
        self.backgroundGradient = CAGradientLayer()
        self.backgroundGradient!.colors = [colorTop, colorBottom]
        self.backgroundGradient!.locations = [0.0, 1.0]
        self.backgroundGradient!.frame = view.frame
        self.view.layer.insertSublayer(self.backgroundGradient!, at: 0)
    }
    
}

// MARK: - Calendar background actions (will/should be called in a backgroundThread)
extension MeetingsViewController {
    
    @IBAction func gotoSettingsButtonClick(_ sender: UIButton) {
        grantAccessClicked()
    }
    
    func grantAccessClicked() {
        let openSettingsUrl = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(openSettingsUrl!)
    }
    
    func showMessage(_ message: String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (action) -> Void in
            self.grantAccessClicked()
        }
        
        let dismissAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) { (action) -> Void in
            DispatchQueue.main.async {
                self.noAccessView.isHidden = false
                self.noAccessView.fadeIn()
            }
        }
        
        alertController.addAction(dismissAction)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func loadEvents() {
        appDelegate.checkCalendarAuthorizationStatus { (accessGranted) -> Void in
            if accessGranted {
                if self.noAccessView.isHidden == false {
                    DispatchQueue.main.async {
                        self.noAccessView.fadeOut()
                    }
                }
                self.fetchEvents(self.eventStore, calendarIdentity: self.selectedCalendar!, completed: { (events: [EKEvent]) -> Void in
                    // We are going to empty the events array first
                    self.events = [EKEvent]()
                    for event in events {
                        // Only add events which do not have a Reccurence rule (YACA cannot deal with that (yet))
                        //print(event.hasRecurrenceRules)
                        //if event.hasRecurrenceRules == false {
                            self.events.append(event)
                        //}
                        
                        /* OLD (SWIFT 2)
                        if let recRules = event.recurrenceRules {
                            if recRules.count == 0 {
                                self.events.append(event)
                            }
                        }*/
                        
                        
                    }
                    // MARK: - Feed datasource and let it do the job to structure probably for the CollectionView
                    Datasource.sharedInstance.loadMeetings(self.events)
                    //completionHandler(result: true)
                })
            } else {
                // Show dialog or something to make aware of unaccessibility of Calendar
                self.showMessage("You have not allowed access to Calendar. This application does not work without this access! You can change this Setting in the global Settings. Should I bring you there?", title: "No access to Calendar")
            }
        }
    }
    
    func fetchEvents(_ eventStore: EKEventStore, calendarIdentity: String, completed: ([EKEvent]) -> ()) {
        let endDate = Date(timeIntervalSinceNow: TimeInterval(self.duration))
        let predicate = eventStore.predicateForEvents(withStart: Date(), end: endDate, calendars: [self.eventStore.calendar(withIdentifier: calendarIdentity)!])
        completed(eventStore.events(matching: predicate) as [EKEvent]!)
    }
}

// MARK: - functions for keyboard dismiss
extension MeetingsViewController {
    
    func addKeyboardDismissRecognizer() {
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}
