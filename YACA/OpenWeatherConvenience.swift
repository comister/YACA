//
//  OpenWeatherConvenience.swift
//  YACA
//
//  Created by Andreas Pfister on 04/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import Foundation

extension OpenWeatherClient {
    
    func getWeatherByLatLong(lat: NSNumber, long: NSNumber, completionHandler: (result: String?, error: NSError?) -> Void) {
        let parameters = [
            ParameterKeys.Latitude  : lat,
            ParameterKeys.Longitude : long
        ]
        taskForGETMethod(parameters) { JSONResult, error in
            if let error = error {
                print(JSONResult)
                completionHandler(result: nil, error: error)
            } else {
                if let weatherContainer = JSONResult.valueForKey(OpenWeatherClient.JSONResponseKeys.Weather) {
                    if let weatherId = weatherContainer.valueForKey(OpenWeatherClient.JSONResponseKeys.weatherId) {
                        completionHandler(result: String(weatherId[0]), error: error)
                        return
                    } else {
                        completionHandler(result: nil, error: nil)
                    }                    
                } else {
                    print("not able to parse probably: ")
                    print(JSONResult)
                }
                completionHandler(result: nil, error: nil)
            }
        }
    }
}