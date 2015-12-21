//
//  RestCountriesConstants.swift
//  YACA
//
//  Created by Andreas Pfister on 21/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import Foundation

extension RestCountriesClient {
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: URLs
        static let BaseURL : String = "https://restcountries.eu/rest/v1/"
    }
    
    // MARK: - Methods
    struct Methods {
        // MARK: currently no methods, everything queried through the URL set in BaseURL
        // static let Common = "weather"
        static let byCountryCode = "alpha"
        static let byCallingCode = "callingcode"
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        // No ParameterKeys required for this Client
    }
    
    struct JSONResponseKeys {
        static let Coordinates = "latlng"
        static let SubRegion = "subregion"
        static let Region = "region"
        static let Capital = "capital"
        static let Name = "name"
        static let TimeZone = "timezones"
        static let CallingCode = "callingCodes"
        static let Languages = "languages"
    }
    
}