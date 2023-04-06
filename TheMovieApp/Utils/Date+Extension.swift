//
//  Date+Extension.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 06/04/23.
//

import Foundation


let date = Date()
let format = date.getFormattedDate(format: "dd-MM-yyy") // Set output format

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

