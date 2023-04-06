//
//  TrailerViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 03/04/23.
//

import UIKit
import YouTubeiOSPlayerHelper


class TrailerViewController: UIViewController, YTPlayerViewDelegate {
    
    var recibirIdTrailerMostrar: String = "QtJ46rYli1U"

    @IBOutlet weak var trailerView: YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trailerView.delegate = self

        self.trailerView.load(withVideoId: recibirIdTrailerMostrar)
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.trailerView.playVideo()
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    

}
