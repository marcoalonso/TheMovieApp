//
//  TrailerCell.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 06/04/23.
//

import UIKit

class TrailerCell: UITableViewCell {
    
    @IBOutlet weak var posterTrailer: UIImageView!
    @IBOutlet weak var nameTrailerLabel: UILabel!
    @IBOutlet weak var dateReleaseTrailerLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
