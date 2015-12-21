//
//  RestCountriesConvenience.swift
//  YACA
//
//  Created by Andreas Pfister on 21/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import Foundation

extension RestCountriesClient {
    
    func getTimezoneByCountryCode(countryCode: String, completionHandler: (result: AnyObject?, error: NSError?) -> Void) {
        taskForGETMethod(Methods.byCountryCode + "/" + countryCode) { JSONResult, error in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                // MARK: - Extract timezone from JSON and return
                if let timezones = JSONResult.valueForKey(RestCountriesClient.JSONResponseKeys.TimeZone) as? [AnyObject] {
                    completionHandler(result: timezones.first as! String, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "No timezones delivered", code: 0, userInfo: nil))
                }
            }
        }
        completionHandler(result: nil, error: nil)
    }
}