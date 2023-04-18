//
//  PopularResponseDataModel.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 06/04/23.
//

import Foundation

struct MovieResponseDataModel: Codable {
    let page: Int?
    let results: [DataMovie]
    let total_pages : Int?
    let total_results: Int?
}

struct MovieNowPlayingResponseDataModel: Codable {
    let page: Int?
    let dates: Dates
    let results: [DataMovie]
    let total_pages : Int?
    let total_results: Int?
}

struct Dates: Codable {
    let maximum: String
    let minimum: String
}
