//
//  Theme.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 14/06/23.
//

import UIKit
 
enum Theme: Int {
    case light
    case dark
    
    func getUserInterfaceStyle() -> UIUserInterfaceStyle {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

struct MTUserDefaults {
    static var shared = MTUserDefaults()
    
    var theme: Theme {
        get {
            return Theme(rawValue: UserDefaults.standard.integer(forKey: "selectedTheme")) ?? .light
        }
        
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedTheme")
        }
    }
}
