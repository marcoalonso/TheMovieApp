//
//  DetalleMovieViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 29/03/23.
//

import UIKit
import Kingfisher

class DetalleMovieViewController: UIViewController {
    
    var recibirPeliculaMostrar: EstrenoMovie?
    
    
    @IBOutlet weak var descripcionMovie: UITextView!
    @IBOutlet weak var tituloMovie: UILabel!
    @IBOutlet weak var posterMovie: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configurarUI()
    }
    
    private func configurarUI(){
        tituloMovie.text = recibirPeliculaMostrar?.title
        descripcionMovie.text = recibirPeliculaMostrar?.overview
        
        ///URL
        guard let urlImagen = recibirPeliculaMostrar?.backdrop_path else { return }
        let url = URL(string: "https://image.tmdb.org/t/p/w200/\(urlImagen)")
        
        posterMovie.kf.setImage(with: url)
    }
    
    @IBAction func verTrailerButton(_ sender: UIButton) {
    }
    
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
