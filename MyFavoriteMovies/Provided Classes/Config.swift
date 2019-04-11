//
//  Config.swift
//  MyFavoriteMovies
//
//  Created by Geek on 3/9/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import Foundation
import UIKit

private let _documentsDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
private let _fileURL: URL = _documentsDirectoryURL.appendingPathComponent("TheMovieDB-Context")

class Config: NSObject, NSCoding{
    var baseImageURLString = "http://image.tmdb.org/t/p/"
    var secureBaseImageURLString = "https://image.tmdb.org/t/p/"
    var posterSizes = ["w92","w154","w185","w342","w500","w780","original"]
    var profileSizes = ["w45","w185","h632","original"]
    var dateUpdated: Date? = nil
    
    var daysSinceLastUpdate: Int?{
        if let lastUpdate = dateUpdated{
            return Int(Date().timeIntervalSince(lastUpdate)) / 60*60*24
        }else{
            return nil
        }
    }
    
    override init(){}
    
    convenience init?(dictionary: [String:AnyObject]){
        self.init()
        if let imageDictionary = dictionary["images"] as? [String:AnyObject],
        let urlString = imageDictionary["base_url"] as? String,
        let secureURLString = imageDictionary["secure_base_url"] as? String,
        let posterSizesArray = imageDictionary["poster_sizes"] as? [String],
        let profileSizesArray = imageDictionary["profile_sizes"] as? [String]{
            baseImageURLString = urlString
            secureBaseImageURLString = secureURLString
            posterSizes = posterSizesArray
            profileSizes = profileSizesArray
            dateUpdated = Date()
        }else{
            return nil
        }
    }
    
    func updateIfDaysSinceUpdateExceeds(_ days: Int){
        if let daysSinceLastUpdate = daysSinceLastUpdate, daysSinceLastUpdate <= days{
            return
        }else{
            updateConfiguration()
        }
    }
    
    private func updateConfiguration(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let methodParameters = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey
        ]
        let request = NSMutableURLRequest(url: appDelegate.tmdbURLFromParameters(methodParameters as [String:AnyObject],
            withPathExtension: "/configuration"))
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        let task = appDelegate.sharedSession.dataTask(with: request as URLRequest){(data,response,error) in
            guard (error == nil) else{
                print("There was an error with your request: \(error!)")
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                print("Your request returned a status code other than 2xx!")
                return
            }
            guard let data = data else{
                print("No data was returned by the request!")
                return
            }
            let parsedResult: [String:AnyObject]!
            do{
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            }catch{
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            if let newConfig = Config(dictionary: parsedResult){
                appDelegate.config = newConfig
                appDelegate.config.save()
            }else{
                print("Could not parse config")
            }
        }
        task.resume()
    }
    
    let BaseImageURLStringKey = "config.base_image_url_string_key"
    let SecureBaseImageURLStringKey = "config.secure_base_image_url_key"
    let PosterSizesKey = "config.poster_size_key"
    let ProfileSizesKey = "config.profile_size_key"
    let DateUpdatedKey = "config.date_update_key"
    
    required init(coder aDecoder: NSCoder){
        baseImageURLString = aDecoder.decodeObject(forKey: baseImageURLString) as! String
        secureBaseImageURLString = aDecoder.decodeObject(forKey: SecureBaseImageURLStringKey) as! String
        posterSizes = aDecoder.decodeObject(forKey: PosterSizesKey) as! [String]
        profileSizes = aDecoder.decodeObject(forKey: ProfileSizesKey) as! [String]
        dateUpdated = aDecoder.decodeObject(forKey: DateUpdatedKey) as? Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(baseImageURLString,forKey:BaseImageURLStringKey)
        aCoder.encode(secureBaseImageURLString,forKey:secureBaseImageURLString)
        aCoder.encode(posterSizes,forKey:PosterSizesKey)
        aCoder.encode(profileSizes,forKey:ProfileSizesKey)
        aCoder.encode(dateUpdated,forKey:DateUpdatedKey)
    }
    private func save(){
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path)
    }
    class func unarchivedInstance() -> Config?{
        if FileManager.default.fileExists(atPath: _fileURL.path) {
            return NSKeyedUnarchiver.unarchiveObject(withFile: _fileURL.path) as? Config
        } else {
            return nil
        }    }
}
