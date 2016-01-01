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
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    // MARK: - GET
    
    func taskForGETMethod(parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        mutableParameters[ParameterKeys.ApiKey] = Constants.ApiKey
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.BaseURL + GoogleAPIClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = GoogleAPIClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                //print(strData)
                GoogleAPIClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    // MARK: - Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        if data == nil {
            return NSError(domain: "No data received", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
        }
        
        do {
            _ = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            // TODO - do something here, figure out later, how to work with errors from Facebook API
            print("client/restcountries:" + error.localizedDescription)
        }
        /*
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
        
        if let errorMessage = parsedResult[parseClient.JSONResponseKeys.StatusMessage] as? String {
        
        let userInfo = [NSLocalizedDescriptionKey : errorMessage]
        
        return NSError(domain: "parse Client Error", code: 1, userInfo: userInfo)
        }
        }
        */
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject?
        
        
        do {
            try parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            completionHandler(result: parsedResult, error: nil)
        } catch let error as NSError {
            completionHandler(result: nil, error: error)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        var isSimple = false
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            if stringValue != "" {
                /* Escape it */
                let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                
                /* Append it */
                urlVars += [key + "=" + "\(escapedValue!)"]
            } else {
                urlVars += ["\(key)"]
                isSimple = true
            }
            
        }
        
        return (!urlVars.isEmpty ? isSimple ? "":"?" : "") + ( isSimple ? urlVars.joinWithSeparator("/"):urlVars.joinWithSeparator("&") )
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> GoogleAPIClient {
        
        struct Singleton {
            static var sharedInstance = GoogleAPIClient()
        }
        
        return Singleton.sharedInstance
    }
    
}