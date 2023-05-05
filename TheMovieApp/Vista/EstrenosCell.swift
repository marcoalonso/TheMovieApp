//
//  EstrenosCell.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 29/03/23.
//

import UIKit

class EstrenosCell: UICollectionViewCell {
    
    
    @IBOutlet weak var posterMovie: UIImageView!
    
    func setupCell(movie: DataMovie){
        let url = URL(string: "\(Constants.urlImages)\(movie.poster_path ?? "")")
        
        posterMovie.kf.setImage(with: url)
        posterMovie.layer.cornerRadius = 10
        posterMovie.layer.masksToBounds = true
    }
    
    
}
