//
//  ViewMovie.swift
//  MarijnHop-pset3
//
//  Created by Marijn Hop on 17/11/2016.
//  Copyright © 2016 Marijn Hop. All rights reserved.
//

import UIKit

class ViewMovie: UIViewController {
    
    var moviePoster: UIImage?
    var movieTitle: String?
    var movieYear: String?
    var movieGenre: String?
    var movieDescription: String?
    
    var currentIndex: Int?
    
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var plotText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        poster.image = moviePoster!
        titleLabel.text = movieTitle!
        yearLabel.text = movieYear!
        genreLabel.text = movieGenre!
        plotText.text = movieDescription!
        
    }

}


