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
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        static let Method = "q"
        static let ApiKey = "apiKey"
        static let CityName = "cityName"
    }
    
    struct JSONResponseKeys {
        static let Coordinates = "coord"
        static let Weather = "weather"
        static let Wind = "wind"
        static let Clouds = "clouds"
        static let Name = "name"
    }
    
}