//
//  PopularesCell.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 06/04/23.
//

import Foundation
import UIKit

class PopularesCell: UICollectionViewCell {
    
    @IBOutlet weak var posterMovie: UIImageView!
    
    func setupCell(movie: DataMovie){
        let url = URL(string: "\(Constants.urlImages)\(movie.poster_path ?? "")")
        
        posterMovie.kf.setImage(with: url)
        posterMovie.layer.cornerRadius = 10
        posterMovie.layer.masksToBounds = true
    }
    
    
}
