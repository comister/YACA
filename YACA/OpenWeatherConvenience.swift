//
//  OpenWeatherConvenience.swift
//  YACA
//
//  Created by Andreas Pfister on 04/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import Foundation

extension OpenWeatherClient {
    
    func getWeatherByLatLong(_ lat: NSNumber, long: NSNumber, unitIndex: Int, completionHandler: @escaping (_ result: [String:AnyObject]?, _ error: NSError?) -> Void) {
        let parameters = [
            ParameterKeys.Latitude  : lat,
            ParameterKeys.Longitude : long,
            ParameterKeys.Unit : ParameterKeys.Units[unitIndex]!
        ] as [String : Any]
        taskForGETMethod(parameters as [String : AnyObject]) { JSONResult, error in
            if let error = error {
                completionHandler(nil, error)
            } else {
                var returnDict = [String:AnyObject]()
                
                if let weatherContainer = JSONResult?.value(forKey: OpenWeatherClient.JSONResponseKeys.Weather) {
                    if let weatherId = (weatherContainer as AnyObject).value(forKey: OpenWeatherClient.JSONResponseKeys.weatherId) {
                        returnDict["weather"] = (weatherId as! [Int])[0] as AnyObject?
                    } else {
                        completionHandler(nil, error)
                        return
                    }
                    if let weatherDescription = (weatherContainer as AnyObject).value(forKey: OpenWeatherClient.JSONResponseKeys.weatherDescription) {
                        returnDict["weather_description"] = (weatherDescription as! [String])[0] as AnyObject? 
                    }
                } else {
                    completionHandler(nil, error)
                    return
                }
                
                
                if let sysContainer = JSONResult?.value(forKey: OpenWeatherClient.JSONResponseKeys.Sys) {
                    if let country = (sysContainer as AnyObject).value(forKey: OpenWeatherClient.JSONResponseKeys.Country) {
                        returnDict["country"] = country as AnyObject
                    }
                }
                
                if let city = JSONResult?.value(forKey: OpenWeatherClient.JSONResponseKeys.City) {
                    returnDict["city"] = city as AnyObject
                }
                
                if let mainContainer = JSONResult?.value(forKey: OpenWeatherClient.JSONResponseKeys.Main) {
                    if let temperature = (mainContainer as AnyObject).value(forKey: OpenWeatherClient.JSONResponseKeys.mainTemperature) {
                        returnDict["weather_temp"] = NSNumber(value: temperature as! Double as Double)
                        completionHandler(returnDict, nil)
                        return
                    }
                }
                completionHandler(returnDict, nil)
            }
        }
    }
}
