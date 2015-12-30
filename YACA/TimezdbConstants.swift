//
//  TimezdbConstants.swift
//  YACA
//
//  Created by Andreas Pfister on 18/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import Foundation

import Foundation

extension TimezdbClient {
    
    // MARK: - Constants
    struct Constants {
        
        static let ApiKey : String = "1161dfe406c812b869626c225e3dcaee"
        // MARK: URLs
        static let BaseURL : String = "http://api.timezdb.com/"
    }
    
    // MARK: - Methods
    struct Methods {
        // MARK: currently no methods, everything queried through the URL set in BaseURL
        // static let Common = "weather"
        static let byCityName = "getByCityName"
        static let byLatLong = "getByLatLng"
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        static let Method = "q"
        static let ApiKey = "apiKey"
        static let CityName = "cityName"
        static let Latitude = "lat"
        static let Longitude = "lng"
    }
    
    struct JSONResponseKeys {
        static let dataContainer = "data"
        static let CountryName = "countryName"
        static let CountryCode = "countryCode"
        static let ZoneName = "zoneName"
        static let TZOffset = "tzOffset"
    }
    
}