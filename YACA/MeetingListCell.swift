//
//  MeetingListCell.swift
//  YACA
//
//  Created by Andreas Pfister on 13/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import Foundation
import UIKit
import EventKit
import CoreData
import MapKit

class MeetingListCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var calendarName: UILabel!
    @IBOutlet weak var participantTable: UITableView!
    @IBOutlet weak var timingLabel: UILabel!
    @IBOutlet weak var notesText: UITextView!
    @IBOutlet weak var notesButton: UIButton!
    @IBOutlet weak var participantsButton: MIBadgeButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var participantDetails: UIView!
    @IBOutlet weak var participantDetailsName: UILabel!
    @IBOutlet weak var participantDetailsWeather: UILabel!
    @IBOutlet weak var participantDetailsWeatherTemperature: UILabel!
    @IBOutlet weak var participantDetailsLastUpdate: UILabel!
    @IBOutlet weak var participantDetailsLocation: UILabel!
    @IBOutlet weak var participantDetailsWeatherDescription: UILabel!
    @IBOutlet weak var participantDetailsTime: UILabel!
    @IBOutlet weak var participantDetailsMeetingTime: UILabel!
    @IBOutlet weak var participantDetailsMap: MKMapView!
    @IBOutlet weak var bottomWeatherLine: UIView!
    
    var backgroundGradient: CAGradientLayer? = nil
    
    @IBAction func closeParticipantDetails(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {
            self.participantDetails.alpha = 0
        }, completion: { (finished: Bool) -> () in
            self.participantDetails.alpha = 1
            self.participantDetails.isHidden = true
            
        })
    }
    
    var event: EKEvent?
    var events: [EKEvent]?
    var cellIdentifier: String?
    
    var meeting: Meeting! {
        didSet {
            updateContent()
        }
    }

    // MARK: - Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    fileprivate func updateContent() {
        calendarName.text = meeting.name
        //timingLabel.text = meeting.starttime
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        timingLabel.text = dateFormatter.string(from: meeting.starttime as Date) + " - " + dateFormatter.string(from: meeting.endtime as Date)
        notesArea()
    }
    
    // MARK: - apply some radius to the Cell
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        // do something
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func startSaveAnimation() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.4
        animation.repeatCount = 9999
        animation.autoreverses = true
        animation.fromValue = 1.0
        animation.toValue = 0.1
        saveButton.isHidden = false
        deleteButton.isHidden = false
        saveButton.layer.add(animation, forKey: "animateOpacity")
    }
    
    func stopSaveAnimation() {
        saveButton.layer.removeAnimation(forKey: "animateOpacity")
        saveButton.isHidden = true
        deleteButton.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let location = meeting.participantArray[indexPath.row].location {
            
            participantDetails.isHidden = false
            UIView.transition(with: participantDetails, duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromRight, animations: nil, completion: nil)
            participantDetailsName.text = ( meeting.participantArray[indexPath.row].name != nil ? meeting.participantArray[indexPath.row].name : meeting.participantArray[indexPath.row].email )
            
            participantDetailsLastUpdate.text = "Last update: " + ( Int(round(Date().timeIntervalSince(location.lastUpdate as Date))) < 60 ? " just a moment ago":String(Int(round(Date().timeIntervalSince(location.lastUpdate as Date)/60))) + " minutes ago")
            
            participantDetailsLocation.text = location.city! + (location.country != "" ? ", " + location.country! : "")
            if let weather = location.weather {
                participantDetailsWeather.text = OWFontIcons[weather]
                participantDetailsWeatherTemperature.text = String(location.weather_temp!.intValue) + (location.weather_temp_unit == 0 ? "°C":"°F")
                participantDetailsWeatherDescription.text = location.weather_description
                
            } else {
                participantDetailsWeather.text = ""
            }
            
            // use timeoffset of google timezone api to calculate th respective times for meeting as well as actual time
            if let timeOffset = location.timezoneOffset {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US")
                dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
                participantDetailsTime.text = "" + dateFormatter.string(from: Date(timeInterval: (timeOffset as! Double), since: Date()))
                dateFormatter.dateFormat = "HH:mm"
                participantDetailsMeetingTime.text = dateFormatter.string(from: Date(timeInterval: (timeOffset as! Double), since: meeting.starttime as Date)) + " - " + dateFormatter.string(from: Date(timeInterval: (timeOffset as! Double), since: meeting.endtime as Date))
            }
            
            // prepare Map and add annotation of location, if available
            if let longitude = location.longitude {
                if let latitude = location.latitude {
                    participantDetailsMap.isHidden = false
                    participantDetailsMap.removeAnnotations(participantDetailsMap.annotations)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
                    participantDetailsMap.addAnnotation(annotation)
                    participantDetailsMap.isUserInteractionEnabled = false
                    
                    let viewRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 10000000, 10000000)
                    let adjustedRegion = participantDetailsMap.regionThatFits(viewRegion)
                    participantDetailsMap.setRegion(adjustedRegion, animated: true)
                    
                } else {
                    participantDetailsMap.isHidden = true
                }
            } else {
                participantDetailsMap.isHidden = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        participantsButton.isEnabled = meeting.participantArray.count > 0
        if meeting.participantArray.count > 0 {
            participantsButton.badgeString = String(meeting.participantArray.count)
            participantsButton.badgeBackgroundColor = UIColor.darkGray
        } else {
            participantsButton.badgeString = nil
        }
        return meeting.participantArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // MARK: - Create cells programmatically - try to dequeue, if not possible create new cell with new identifier
        let identifier = cellIdentifier!
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: identifier)
        }
        
        // Use Name to display, use email if name does not exist
        cell?.textLabel?.text = ( meeting.participantArray[indexPath.row].name != nil ? meeting.participantArray[indexPath.row].name : meeting.participantArray[indexPath.row].email )
        
        if meeting.participantArray[indexPath.row].location != nil {
            cell?.imageView?.image = UIImage(named: "pin")
        } else {
            cell?.imageView?.image = UIImage().blank_x1
        }
        
        // show yourself in blue color, all others in black
        if meeting.participantArray[indexPath.row].myself {
            cell?.textLabel?.textColor = UIColor.blue
        } else {
            cell?.textLabel?.textColor = UIColor.black
        }
        
        return cell!
    }
    
}

// MARK: - Toolbarbuttons
extension MeetingListCell {
    
    func participantArea() {
        participantTable.isHidden = false
        notesText.isHidden = true
        participantTable.reloadData()
        participantsButton.backgroundColor = UIColor.white
        notesButton.backgroundColor = .none
    }
    
    func notesArea() {
        participantTable.isHidden = true
        notesText.isHidden = false
        
        notesButton.backgroundColor = UIColor.white
        participantsButton.backgroundColor = .none
    }
    
    @IBAction func participantsButton(_ sender: UIButton) {
        participantArea()
    }
    
    @IBAction func notesButton(_ sender: UIButton) {
        notesArea()
    }
    
}

extension MeetingListCell: UITextViewDelegate {
    
    @IBAction func saveNote(_ sender: UIButton) {
        self.endEditing(true)
    }
    
    @IBAction func deleteNote(_ sender: UIButton) {
        self.endEditing(true)
        notesText.text = ""
        doSaveNote()
    }
    
    func doSaveNote() {
        // a new note to be created
        if self.meeting.note == nil {
            if notesText.text == "" {
                return
            }
            let noteDictionary = [
                Note.Keys.Note: notesText.text,
                Note.Keys.MeetingId: self.meeting.meetingId,
                Note.Keys.MeetingTitle: self.meeting.name
            ] as [String : Any]
            self.meeting.note = Note(dictionary: noteDictionary as [String : AnyObject], context: self.sharedContext)
        // an existing note to be updated
        } else {
            if notesText.text == "" {
                self.sharedContext.delete(self.meeting.note!)
            } else {
                self.meeting.note?.note = notesText.text
                self.meeting.note?.meetingTitle = self.meeting.name
            }
        }
        startSaveAnimation()
        CoreDataStackManager.sharedInstance().saveContext() {
            self.stopSaveAnimation()
        }
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        saveButton.isHidden = false
        deleteButton.isHidden = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        doSaveNote()
    }
    
    func configureUI() {
        
    }
    
}

