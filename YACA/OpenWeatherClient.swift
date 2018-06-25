//
//  OpenWeatherClient.swift
//  YACA
//
//  Created by Andreas Pfister on 04/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import Foundation

class OpenWeatherClient : NSObject {
    
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
        let urlString = Constants.BaseURL + OpenWeatherClient.escapedParameters(mutableParameters)
        let url = URL(string: urlString)!
        let request = NSMutableURLRequest(url: url)
        request.timeoutInterval = 15
        
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = OpenWeatherClient.errorForData(data, response: response, error: error as NSError)
                completionHandler(nil, newError)
            } else {
                OpenWeatherClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
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
        
        var parsedResult: Any
        
        do {
            try parsedResult = JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            completionHandler(parsedResult as AnyObject, nil)
        } catch let error as NSError {
            completionHandler(nil, error)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> OpenWeatherClient {
        
        struct Singleton {
            static var sharedInstance = OpenWeatherClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: - Shared Image Cache
    /*
    struct Caches {
    static let imageCache = ImageCache()
    }
    */
}
