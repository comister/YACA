//
//  RestCountriesConvenience.swift
//  YACA
//
//  Created by Andreas Pfister on 21/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import Foundation

extension RestCountriesClient {
    
    // Mark: - Overloaded closure
    func getTimezoneByCountryCode(countryCode: String, objectToAssign: AnyObject, completionHandler: (result: AnyObject?, error: NSError?, objectToAssign: AnyObject) -> Void) {
        taskForGETMethod(Methods.byCountryCode + "/" + countryCode) { JSONResult, error in
            if let error = error {
                completionHandler(result: nil, error: error, objectToAssign: objectToAssign)
            } else {
                // MARK: - Extract timezone from JSON and return
                if let timezones = JSONResult.valueForKey(RestCountriesClient.JSONResponseKeys.TimeZone) as? [AnyObject] {                    
                    completionHandler(result: timezones.first as! String, error: nil, objectToAssign: objectToAssign)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "No timezones delivered: \(JSONResult):" + Methods.byCountryCode + "/" + countryCode, code: 0, userInfo: nil), objectToAssign: objectToAssign)
                }
            }
        }
        completionHandler(result: nil, error: nil, objectToAssign: objectToAssign)
    }
}