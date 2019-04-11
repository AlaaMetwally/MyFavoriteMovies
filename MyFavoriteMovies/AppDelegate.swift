//
//  AppDelegate.swift
//  MyFavoriteMovies
//
//  Created by Geek on 2/7/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var sharedSession = URLSession.shared
    var requestToken: String? = nil
    var sessionID: String? = nil
    var userID: Int? = nil
    
    var config = Config()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        config.updateIfDaysSinceUpdateExceeds(7)
        return true
    }
}

extension AppDelegate{
    func tmdbURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL{
        var components = URLComponents()
        components.scheme = Constants.TMDB.ApiScheme
        components.host = Constants.TMDB.ApiHost
        components.path = Constants.TMDB.ApiPath
        for (key,value) in parameters{
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
}

