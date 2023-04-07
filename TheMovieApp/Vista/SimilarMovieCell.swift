//
//  SimilarMovieCell.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 07/04/23.
//

import UIKit
import Kingfisher

class SimilarMovieCell: UICollectionViewCell {
    
    @IBOutlet weak var posterSimilarMovie: UIImageView!
    
    func setup(movie: DataMovie) {
        
        if let urlImagen = movie.backdrop_path {
            let url = URL(string: "https://image.tmdb.org/t/p/w200/\(urlImagen)")
            posterSimilarMovie.kf.setImage(with: url)
            posterSimilarMovie.layer.cornerRadius = 20
            posterSimilarMovie.layer.masksToBounds = true
        }
        
    }
    
}
