//
//  ViewController.swift
//  MarijnHop-pset3
//
//  Created by Marijn Hop on 16/11/2016.
//  Copyright © 2016 Marijn Hop. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let myMovies = UserDefaults.standard
    
    var movies = [String]()
    var years = [String]()
    var posters = [String]()
    var genres = [String]()
    var plots = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // When the Add movie button is pressed, show search box
    @IBAction func addButton(_ sender: Any) {
        let searchBox = UIAlertController(title: "Search Movie", message: "Search for a movie to add to your watch list", preferredStyle: .alert)
        var textField: UITextField?
        
        searchBox.addTextField(configurationHandler: {(input:UITextField) in
            input.placeholder="Movie title"
            input.clearButtonMode=UITextFieldViewMode.whileEditing
            textField = input
        })
        
        func search(actionTarget: UIAlertAction){
            self.searchMovie(title: textField!.text!)
        }
        
        searchBox.addAction(UIAlertAction(title: "Search", style: UIAlertActionStyle.default, handler: search))
        present(searchBox, animated: true, completion: nil)
    }
    
    //MARK: -  Search movie function
    func searchMovie(title: String){
        let movie = title.components(separatedBy: " ").joined(separator: "+")
        let url = URL(string: "https://omdbapi.com/?t="+movie+"&yplot=short&r=json")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            do {
                // create dictionary from JSON object
                let movieObject =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                if let movieDictionary = movieObject {
                    
                    // If movie is not found
                    let response = movieDictionary["Response"] as? String
                    if response == "False" || movie == "" {
                        print("Movie not found")
                    }
                    else {
                        self.viewMovie(movieDictionary: movieDictionary)
                    }
                }
            }
                // Error for developer
            catch {
                print("hier gaat iets mis")
            }
        }
        task.resume()
    }
    
    // View movie: Go to next viewcontroller
    func viewMovie(movieDictionary: NSDictionary) {
        
        func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let viewMovie = segue.destination as! ViewMovie
            viewMovie.movieDictionary = movieDictionary
        }
        
    }
    
    func alertUser(message: String) {
        let alertController = UIAlertController(title: "Oops!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        return
    }
    
    //MARK: - Tableview Delegate & Datasource
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        return cell
    }
    
}
