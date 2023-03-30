//
//  MovieDataModel.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 29/03/23.
//

import Foundation

struct MovieDataModel : Codable {
    let results: [EstrenoMovie]
    let total_pages: Int
    let total_results: Int
}

struct EstrenoMovie : Codable {
    let backdrop_path: String
    let id: Int
    let original_title : String
    let overview: String
    let title: String
    let release_date: String
    let poster_path: String
}
