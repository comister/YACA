//
//  TimezdbConvenience.swift
//  YACA
//
//  Created by Andreas Pfister on 18/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import Foundation

extension TimezdbClient {
    
    func getTimezoneByCity(cityName: String, completionHandler: (result: Int?, error: NSError?) -> Void) {
        
        let parameters = [
            ParameterKeys.Method : Methods.byCityName,
            ParameterKeys.CityName : cityName
        ]
        
        taskForGETMethod(parameters) { JSONResult, error in
            
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                print(JSONResult)
            }
            
        }
        completionHandler(result: nil, error: nil)
    }
    
    func getTimezoneByLatLong(lat: NSNumber, long: NSNumber, completionHandler: (result: Int?, error: NSError?) -> Void) {
        
        let parameters = [
            ParameterKeys.Method    : Methods.byLatLong,
            ParameterKeys.Latitude  : lat,
            ParameterKeys.Longitude : long
        ]
        
        taskForGETMethod(parameters) { JSONResult, error in
            
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                print(JSONResult)
            }
            
        }
        completionHandler(result: nil, error: nil)
    }
    
}