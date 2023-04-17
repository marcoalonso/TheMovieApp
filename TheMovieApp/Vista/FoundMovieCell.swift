//
//  FoundMovieCell.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 07/04/23.
//

import Foundation
import UIKit
import Kingfisher

class FoundMovieCell: UICollectionViewCell {
    
    
    @IBOutlet weak var posterMovieFound: UIImageView!
    
    func setup(movie: DataMovie){
        
        if let urlImagen = movie.poster_path {
            let url = URL(string: "\(Constants.urlImages)\(urlImagen)")
            posterMovieFound.kf.setImage(with: url)
            
        }  
    }
    
    
}
