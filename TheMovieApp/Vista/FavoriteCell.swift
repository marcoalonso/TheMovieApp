//
//  FavoriteCell.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 08/04/23.
//

import UIKit
import Kingfisher


class FavoriteCell: UITableViewCell {
    
    @IBOutlet weak var titleMovie: UILabel!
    @IBOutlet weak var descripctionMovie: UILabel!
    @IBOutlet weak var releaseDateMovie: UILabel!
    @IBOutlet weak var posterMovie: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
