//
//  ViewMovie.swift
//  MarijnHop-pset3
//
//  Created by Marijn Hop on 17/11/2016.
//  Copyright © 2016 Marijn Hop. All rights reserved.
//

import UIKit

class ViewMovie: UIViewController {
    
    var movieDictionary: NSDictionary?
    
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var RatingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = movieDictionary!["Title"] as? String!
        yearLabel.text = movieDictionary!["Year"] as? String!
    }

}
