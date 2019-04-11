//
//  Movie.swift
//  MyFavoriteMovies
//
//  Created by Geek on 3/9/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import Foundation
import UIKit

struct Movie {
    let title: String
    let id: Int
    let posterPath: String?
    
    init(dictionary: [String:AnyObject]){
        title = dictionary[Constants.TMDBResponseKeys.Title] as! String
        id = dictionary[Constants.TMDBResponseKeys.ID] as! Int
        posterPath = dictionary[Constants.TMDBResponseKeys.PosterPath] as? String
    }
    
    static func moviesFromResults(_ results: [[String:AnyObject]]) -> [Movie]{
        var movies = [Movie]()
        
        for result in results{
            movies.append(Movie(dictionary: result))
        }
        return movies
    }
}
extension Movie: Equatable{}
func ==(lhs: Movie,rhs: Movie) -> Bool{
        return lhs.id == rhs.id
}
