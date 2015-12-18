//
//  OpenWeatherConstants.swift
//  YACA
//
//  Created by Andreas Pfister on 04/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import Foundation

extension OpenWeatherClient {
    
    // MARK: - Constants
    struct Constants {
        
        static let ApiKey : String = "3583aa542343bbd2441704b68ec44c93"
        // MARK: URLs
        static let BaseURL : String = "api.openweathermap.org/data/2.5/weather"
    }
    
    // MARK: - Methods
    struct Methods {
        // MARK: currently no methods, everything queried through the URL set in BaseURL
        // static let Common = "weather"
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        static let Method = "q"
        static let ApiKey = "appid"
        static let Latitude = "lat"
        static let Longitude = "lon"
    }
    
    struct JSONResponseKeys {
        static let Coordinates = "coord"
        static let Weather = "weather"
        static let Wind = "wind"
        static let Clouds = "clouds"
        static let Name = "name"
    }
    
}