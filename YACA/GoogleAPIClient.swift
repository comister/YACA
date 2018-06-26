//
//  GoogleAPIClient.swift
//  YACA
//
//  Created by Andreas Pfister on 31/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import Foundation

class GoogleAPIClient : NSObject {
    
    /* Shared session */
    var session: URLSession
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    
    // MARK: - GET
    
    func taskForGETMethod(_ parameters: [String : AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        mutableParameters[ParameterKeys.ApiKey] = Constants.ApiKey as AnyObject
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.BaseURL + GoogleAPIClient.escapedParameters(mutableParameters)
        let url = URL(string: urlString)!
        //let request = NSMutableURLRequest(url: url)
        var request = URLRequest(url: url)
        request.timeoutInterval = 10 // this cannot take longer than 10 seconds, otherwise we are assuming connection is not working
        /* 4. Make the request */
        let task = self.session.dataTask(with: request, completionHandler: {data, response, downloadError in
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = GoogleAPIClient.errorForData(data, response: response, error: error as NSError)
                completionHandler(nil, newError)
            } else {
                GoogleAPIClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler as (AnyObject?, NSError?) -> Void)
            }
        }) 
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    // MARK: - Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(_ data: Data?, response: URLResponse?, error: NSError) -> NSError {
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject
        
        do {
            try parsedResult = JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
            completionHandler(parsedResult, nil)
        } catch let error as NSError {
            // FROM (SWIFT 2) -- There was nil before ""
            completionHandler(nil, error)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        var isSimple = false
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            if stringValue != "" {
                /* Escape it */
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                
                /* Append it */
                urlVars += [key + "=" + "\(escapedValue!)"]
            } else {
                urlVars += ["\(key)"]
                isSimple = true
            }
            
        }
        
        return (!urlVars.isEmpty ? isSimple ? "":"?" : "") + ( isSimple ? urlVars.joined(separator: "/"):urlVars.joined(separator: "&") )
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> GoogleAPIClient {
        
        struct Singleton {
            static var sharedInstance = GoogleAPIClient()
        }
        
        return Singleton.sharedInstance
    }
    
}
