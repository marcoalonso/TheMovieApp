//
//  SimilarMovieCell.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 07/04/23.
//

import UIKit
import Kingfisher
import UIView_Shimmer

class SimilarMovieCell: UICollectionViewCell {
    
    @IBOutlet weak var posterSimilarMovie: UIImageView!
    
    func setup(movie: DataMovie) {
        posterSimilarMovie.setTemplateWithSubviews(true, viewBackgroundColor: .gray)
        
        if let urlImagen = movie.poster_path {
            let url = URL(string: "\(Constants.urlImages)\(urlImagen)")
            posterSimilarMovie.kf.setImage(with: url)
            posterSimilarMovie.layer.cornerRadius = 20
            posterSimilarMovie.layer.masksToBounds = true
            posterSimilarMovie.setTemplateWithSubviews(false)
        }
        
    }
    
}

extension UIImageView: ShimmeringViewProtocol {
    
}
