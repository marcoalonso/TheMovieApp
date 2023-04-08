//
//  MoreInfoSheetViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 08/04/23.
//

import UIKit

class MoreInfoSheetViewController: UIViewController {
    
    var movieDetails: DataMovie?
    
    @IBOutlet weak var titleMovie: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        print(movieDetails)
    }
    

   

}
