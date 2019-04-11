//
//  FavoritesTableViewController.swift
//  MyFavoriteMovies
//
//  Created by Geek on 3/9/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController {
    
    var appDelegate: AppDelegate!
    var movies: [Movie] = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
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
            
            self.movies = Movie.moviesFromResults(results)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        task.resume()
    }
    
    @objc func logout() {
        dismiss(animated: true, completion: nil)
    }
}

extension FavoritesTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "FavoriteTableViewCell"
        let movie = movies[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        cell?.textLabel!.text = movie.title
        cell?.imageView!.image = UIImage(named: "Film Icon")
        cell?.imageView!.contentMode = UIView.ContentMode.scaleAspectFit
        
        if let posterPath = movie.posterPath {
            let baseURL = URL(string: appDelegate.config.baseImageURLString)!
            let url = baseURL.appendingPathComponent("w154").appendingPathComponent(posterPath)
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
                        cell?.imageView!.image = image
                    }
                } else {
                    print("Could not create image from \(data)")
                }
            }
            
            task.resume()
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "MovieDetailViewController") as! MovieDetailViewController
        controller.movie = movies[(indexPath as NSIndexPath).row]
        navigationController!.pushViewController(controller, animated: true)
    }
}
