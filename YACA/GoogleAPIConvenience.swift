//
//  GoogleAPIConvenience.swift
//  YACA
//
//  Created by Andreas Pfister on 31/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import Foundation

extension GoogleAPIClient {
    
    func getTimeOfLocation(lat: NSNumber, long: NSNumber, completionHandler: @escaping (_ result: Double?, _ error: NSError?) -> Void) {
        let parameters = [
            ParameterKeys.Location  : String(describing: lat) + "," + String(describing: long),
            ParameterKeys.Timestamp : Date().timeIntervalSince1970
        ] as [String : Any]
        
        taskForGETMethod(parameters as [String : AnyObject]) {
            result, error in
            if let connectionError = error {
                completionHandler(nil, connectionError)
                return
            }
            if let status = result?[JSONResponseKeys.Status] {
                //all good, we have offset + daylight saving offset which we simply add together
                if status as! String == "OK" {
                    completionHandler(((result?[JSONResponseKeys.UTCOffset] as! Double) + (result?[JSONResponseKeys.DayLightSavingOffset] as! Double)), nil)
                }
                
            } else {
                completionHandler(nil, NSError(domain: "No data received", code: 1, userInfo: [NSLocalizedDescriptionKey: "google timezone API did not provide any information"]))
            }
            
        }
    }
    
}
