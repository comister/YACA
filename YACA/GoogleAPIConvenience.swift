//
//  GoogleAPIConvenience.swift
//  YACA
//
//  Created by Andreas Pfister on 31/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import Foundation

extension GoogleAPIClient {
    
    func getTimeOfLocation(lat: NSNumber, long: NSNumber, completionHandler: (result: Double?, error: NSError?) -> Void) {
        let parameters = [
            ParameterKeys.Location  : String(lat) + "," + String(long),
            ParameterKeys.Timestamp : NSDate().timeIntervalSince1970
        ]
        
        taskForGETMethod(parameters as! [String : AnyObject]) {
            result, error in
            if let connectionError = error {
                completionHandler(result: nil, error: connectionError)
                return
            }
            if let status = result[JSONResponseKeys.Status] {
                //all good, we have offset + daylight saving offset which we simply add together
                if status as! String == "OK" {
                    completionHandler(result: ((result[JSONResponseKeys.UTCOffset] as! Double) + (result[JSONResponseKeys.DayLightSavingOffset] as! Double)), error: nil)
                }
                
            } else {
                completionHandler(result: nil, error: NSError(domain: "No data received", code: 1, userInfo: [NSLocalizedDescriptionKey: "google timezone API did not provide any information"]))
            }
            
        }
    }
    
}