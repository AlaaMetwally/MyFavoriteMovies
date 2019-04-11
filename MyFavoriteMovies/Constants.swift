//
//  Constants.swift
//  MyFavoriteMovies
//
//  Created by Geek on 3/9/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import Foundation
import UIKit

struct Constants{
    struct TMDB{
        static let ApiScheme = "http"
        static let ApiHost = "api.themoviedb.org"
        static let ApiPath = "/3"
    }
    struct TMDBParameterKeys {
        static let ApiKey = "api_key"
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
        static let Username = "username"
        static let Password = "password"
    }
    struct TMDBParameterValues {
        static let ApiKey = "8ef5fa9ef1349b34332c69940c80b719"
    }
    struct TMDBResponseKeys{
        static let Title = "title"
        static let ID = "id"
        static let PosterPath = "poster_path"
        static let StatusCode = "status_code"
        static let StatusMessage = "status_message"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        static let Success = "success"
        static let UserID = "id"
        static let Results = "results"
    }
    struct UI {
        static let LoginColorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).cgColor
        static let LoginColorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).cgColor
        static let GreyColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha: 1.0)
        static let BlueColor = UIColor(red: 0.0, green: 0.502, blue: 0.839, alpha: 1.0)
    }
}
