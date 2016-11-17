//
//  MovieCell.swift
//  MarijnHop-pset3
//
//  Created by Marijn Hop on 16/11/2016.
//  Copyright © 2016 Marijn Hop. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieYear: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
