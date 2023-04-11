//
//  WebViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 11/04/23.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var urlBusqueda: String = "https://cinepolis.com/"
    var nameMovieTeather: String = "Cinepolis"
    
    @IBOutlet weak var nameCine: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameCine.text = nameMovieTeather
        
        guard let url = URL(string: urlBusqueda) else { return }
        
        webView.load(URLRequest(url: url))
    }

    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
}
