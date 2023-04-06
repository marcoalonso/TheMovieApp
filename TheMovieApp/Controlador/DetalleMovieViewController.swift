//
//  DetalleMovieViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 29/03/23.
//

import UIKit
import Kingfisher

class DetalleMovieViewController: UIViewController {
    
    var recibirPeliculaMostrar: DataMovie?
    var manager = MoviesManager()
    var trailerDisponible = false
    var urlTrailer: String = ""
    
    @IBOutlet weak var releaseDateMovie: UILabel!
    @IBOutlet weak var descripcionMovie: UITextView!
    @IBOutlet weak var tituloMovie: UILabel!
    @IBOutlet weak var posterMovie: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configurarUI()
        
        obtenerTrailer()
    }
    
    
    
    ///Consumir el nuevo servicio de listado de trailers
    private func obtenerTrailer(){
        if let idMovie = recibirPeliculaMostrar?.id {
            print("Llamando al servicio de trailers")
            manager.getTrailersMovie(id: idMovie) { listaTrailes, error in
                
                if listaTrailes.isEmpty {
                    print("No hay trailer disponible")
                } else {
                    self.trailerDisponible = true
                    self.urlTrailer = listaTrailes[0].key
                }
            }
        }
    }
    
    private func configurarUI(){
        tituloMovie.text = recibirPeliculaMostrar?.title
        descripcionMovie.text = recibirPeliculaMostrar?.overview
        releaseDateMovie.text = recibirPeliculaMostrar?.release_date
        
        ///URL
        guard let urlImagen = recibirPeliculaMostrar?.backdrop_path else { return }
        let url = URL(string: "https://image.tmdb.org/t/p/w200/\(urlImagen)")
        
        posterMovie.kf.setImage(with: url)
    }
    
    @IBAction func verTrailerButton(_ sender: UIButton) {
        
        if trailerDisponible {
           navegarTrailer()
        } else {
            print("No hay trailer disponibles")
        }
        
    }
    
    
    func navegarTrailer() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ViewController = storyboard.instantiateViewController(withIdentifier: "TrailerViewController") as! TrailerViewController
        
        ViewController.modalPresentationStyle = .fullScreen ///Tipo de visualizacion
        ViewController.modalTransitionStyle = .crossDissolve ///Tipo de animacion al cambiar pantalla
        
        ViewController.recibirIdTrailerMostrar = urlTrailer
        
        present(ViewController, animated: true)
    }
    
    
    
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
