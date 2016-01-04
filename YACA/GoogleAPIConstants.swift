//
//  GoogleAPIConstants.swift
//  YACA
//
//  Created by Andreas Pfister on 31/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import Foundation

extension GoogleAPIClient {
    
    struct Constants {
        static let ApiKey = "AIzaSyDTdWRh0KGVRhQTdMvhsda0ex5gSZZ6gck"
        static let BaseURL = "https://maps.googleapis.com/maps/api/timezone/json"
    }
    
    struct ErrorKeys {
        static let Timeout = -1001
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        static let Location = "location"
        static let Timestamp = "timestamp"
        static let ApiKey = "key"
    }
    
    // MARK: - Response Keys
    struct JSONResponseKeys {
        static let Status = "status"
        static let DayLightSavingOffset = "dstOffset"
        static let UTCOffset = "rawOffset"
        static let TimeZoneLocation = "timeZoneId"
        static let TimezoneName = "timeZoneName"
        
    }
}