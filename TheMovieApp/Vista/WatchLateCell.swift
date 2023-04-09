//
//  WatchLateCell.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 08/04/23.
//

import UIKit

class WatchLateCell: UITableViewCell {
    
    @IBOutlet weak var posterMovieWatchLate: UIImageView!
    @IBOutlet weak var namoOfMovieWatchLate: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
