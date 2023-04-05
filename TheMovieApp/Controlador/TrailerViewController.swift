//
//  TrailerViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 03/04/23.
//

import UIKit
import YouTubeiOSPlayerHelper


class TrailerViewController: UIViewController {
    
    var recibirIdTrailerMostrar: String = "QtJ46rYli1U"

    @IBOutlet weak var trailerView: YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.trailerView.load(withVideoId: recibirIdTrailerMostrar)
    }
    
    
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    

}
