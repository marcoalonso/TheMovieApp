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
