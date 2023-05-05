//
//  NowPlayingCell.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 17/04/23.
//

import Foundation
import UIKit

class NowPlayingCell: UICollectionViewCell {
    
    @IBOutlet weak var posterMovie: UIImageView!
    
    func setupCell(movie: DataMovie){
        let url = URL(string: "\(Constants.urlImages)\(movie.poster_path ?? "")")
        
        posterMovie.kf.setImage(with: url)
        posterMovie.layer.cornerRadius = 10
        posterMovie.layer.masksToBounds = true
    }
}
