//
//  MovieDetailViewController.swift
//  MyFavoriteMovies
//
//  Created by Geek on 3/9/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    var appDelegate: AppDelegate!
    var isFavorite = false
    var movie: Movie?
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let movie = movie {
            
            posterImageView.image = UIImage(named: "film342.png")
            titleLabel.text = movie.title
   
            let methodParameters = [
                Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey,
                Constants.TMDBParameterKeys.SessionID: appDelegate.sessionID!
            ]
            
            let request = NSMutableURLRequest(url: appDelegate.tmdbURLFromParameters(methodParameters as [String:AnyObject], withPathExtension: "/account/\(appDelegate.userID!)/favorite/movies"))
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = appDelegate.sharedSession.dataTask(with: request as URLRequest) { (data, response, error) in
                
                guard (error == nil) else {
                    print("There was an error with your request: \(error!)")
                    return
                }
                
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    print("Your request returned a status code other than 2xx!")
                    return
                }
                
                guard let data = data else {
                    print("No data was returned by the request!")
                    return
                }
                
                let parsedResult: [String:AnyObject]!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                } catch {
                    print("Could not parse the data as JSON: '\(data)'")
                    return
                }
                
                if let _ = parsedResult[Constants.TMDBResponseKeys.StatusCode] as? Int {
                    print("TheMovieDB returned an error. See the '\(Constants.TMDBResponseKeys.StatusCode)' and '\(Constants.TMDBResponseKeys.StatusMessage)' in \(parsedResult)")
                    return
                }
                
                guard let results = parsedResult[Constants.TMDBResponseKeys.Results] as? [[String:AnyObject]] else {
                    print("Cannot find key '\(Constants.TMDBResponseKeys.Results)' in \(parsedResult)")
                    return
                }
                
                let movies = Movie.moviesFromResults(results)
                self.isFavorite = false
                
                for movie in movies {
                    if movie.id == self.movie!.id {
                        self.isFavorite = true
                    }
                }
                
                DispatchQueue.main.async {
                    self.favoriteButton.tintColor = (self.isFavorite) ? nil : .black
                }
            }
            
            task.resume()
            
            if let posterPath = movie.posterPath {

                let baseURL = URL(string: appDelegate.config.baseImageURLString)!
                let url = baseURL.appendingPathComponent("w342").appendingPathComponent(posterPath)
                
                let request = URLRequest(url: url)
                
                let task = appDelegate.sharedSession.dataTask(with: request) { (data, response, error) in
                    
                    guard (error == nil) else {
                        print("There was an error with your request: \(error!)")
                        return
                    }
                    
                    guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                        print("Your request returned a status code other than 2xx!")
                        return
                    }
                    
                    guard let data = data else {
                        print("No data was returned by the request!")
                        return
                    }
                  
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.posterImageView!.image = image
                        }
                    } else {
                        print("Could not create image from \(data)")
                    }
                }
                
                task.resume()
            }
        }
    }
    
    
    @IBAction func toggleFavorite(_ sender: AnyObject) {
        
        let shouldFavorite = !isFavorite
        
        let methodParameters = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey,
            Constants.TMDBParameterKeys.SessionID: appDelegate.sessionID!
        ]
        
        let request = NSMutableURLRequest(url: appDelegate.tmdbURLFromParameters(methodParameters as [String:AnyObject], withPathExtension: "/account/\(appDelegate.userID!)/favorite"))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"media_type\": \"movie\",\"media_id\": \(movie!.id),\"favorite\":\(shouldFavorite)}".data(using: String.Encoding.utf8)
        
        let task = appDelegate.sharedSession.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard (error == nil) else {
                print("There was an error with your request: \(error!)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let tmdbStatusCode = parsedResult[Constants.TMDBResponseKeys.StatusCode] as? Int else {
                print("Could not find key '\(Constants.TMDBResponseKeys.StatusCode)' in  \(parsedResult)")
                return
            }
            
            if shouldFavorite && !(tmdbStatusCode == 12 || tmdbStatusCode == 1) {
                print("Unrecognized '\(Constants.TMDBResponseKeys.StatusCode)' in  \(parsedResult)")
                return
            } else if !shouldFavorite && tmdbStatusCode != 13 {
                print("Unrecognized '\(Constants.TMDBResponseKeys.StatusCode)' in  \(parsedResult)")
                return
            }
            
            self.isFavorite = shouldFavorite
            
            DispatchQueue.main.async {
                self.favoriteButton.tintColor = (shouldFavorite) ? nil : .black
            }
        }
        
        task.resume()
    }
}
