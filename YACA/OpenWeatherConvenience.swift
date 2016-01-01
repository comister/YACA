//
//  OpenWeatherConvenience.swift
//  YACA
//
//  Created by Andreas Pfister on 04/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import Foundation

extension OpenWeatherClient {
    
    func getWeatherByLatLong(lat: NSNumber, long: NSNumber, unitIndex: Int, completionHandler: (result: [String:AnyObject]?, error: NSError?) -> Void) {
        let parameters = [
            ParameterKeys.Latitude  : lat,
            ParameterKeys.Longitude : long,
            ParameterKeys.Unit : ParameterKeys.Units[unitIndex]!
        ]
        taskForGETMethod(parameters) { JSONResult, error in
            if let error = error {
                print(JSONResult)
                completionHandler(result: nil, error: error)
            } else {
                var returnDict = [String:AnyObject]()
                if let weatherContainer = JSONResult.valueForKey(OpenWeatherClient.JSONResponseKeys.Weather) {
                    if let weatherId = weatherContainer.valueForKey(OpenWeatherClient.JSONResponseKeys.weatherId) {
                        returnDict["weather"] = String(weatherId[0])
                    } else {
                        completionHandler(result: nil, error: nil)
                        return
                    }
                    if let weatherDescription = weatherContainer.valueForKey(OpenWeatherClient.JSONResponseKeys.weatherDescription) {
                        returnDict["weather_description"] = String(weatherDescription[0])
                    }
                } else {
                    print("not able to parse probably: ")
                    print(JSONResult)
                }
                if let mainContainer = JSONResult.valueForKey(OpenWeatherClient.JSONResponseKeys.Main) {
                    if let temperature = mainContainer.valueForKey(OpenWeatherClient.JSONResponseKeys.mainTemperature) {
                        returnDict["weather_temp"] = NSNumber(double: temperature as! Double)
                        completionHandler(result: returnDict, error: nil)
                    }
                }
                completionHandler(result: returnDict, error: nil)
            }
        }
    }
}