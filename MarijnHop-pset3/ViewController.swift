//
//  ViewController.swift
//  MarijnHop-pset3
//
//  Created by Marijn Hop on 16/11/2016.
//  Copyright © 2016 Marijn Hop. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // save watchlist
    let watchlist = UserDefaults.standard
    
    // arrays for storing movie info
    var movies = [String]()
    var years = [String]()
    var posters = [String]()
    var genres = [String]()
    var plots = [String]()
    
    var currentIndex: Int?
    
    @IBOutlet weak var tableView: UITableView!
    
    
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
                        self.alertUser(message:"Movie not found")
                    }
                    // When movie is found, add to watchlist
                    else {
                        self.addMovie(movieDictionary: movieDictionary)
                        self.updateWatchlist()
                    }
                    // Reload table
                    self.tableView.reloadData()
                }
            }
                // Error for developer
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
    
    // Add movie to dictionary
    func addMovie(movieDictionary: NSDictionary) {
        self.movies.append((movieDictionary["Title"] as? String)!)
        self.years.append((movieDictionary["Year"] as? String)!)
        self.plots.append((movieDictionary["Plot"] as? String)!)
        self.posters.append((movieDictionary["Poster"] as? String)!)
        self.genres.append((movieDictionary["Genre"] as? String)!)
    }
    
    
    // Get poster image from url in dictionary
    func getPoster(poster: String) -> UIImage {
        var adress = poster.replacingOccurrences(of: "http",with: "https")
        adress = poster.replacingOccurrences(of: "httpss",with: "https")
        let url = URL(string: (adress))
        let data = try! Data(contentsOf: url!)
        let image = UIImage(data: data)
        return image!
    }
    
    
    // Remove movie from watchlist
    func removeMovie(_ index: Int) {
        self.movies.remove(at: index)
        self.years.remove(at: index)
        self.plots.remove(at: index)
        self.posters.remove(at: index)
        self.genres.remove(at: index)
        updateWatchlist()
        self.tableView.reloadData()
        
    }
    


    // Update the user's watchlist
    func updateWatchlist() {
        self.watchlist.set(self.movies, forKey: "Title")
        self.watchlist.set(self.years, forKey: "Year")
        self.watchlist.set(self.plots, forKey: "Plot")
        self.watchlist.set(self.posters, forKey: "Poster")
        self.watchlist.set(self.genres, forKey: "Genre")
    }

    
    // Load the user's watchlist
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if watchlist.array(forKey: "Title") != nil {
            posters = (self.watchlist.array(forKey: "Poster") as? Array<String>)!
            movies = (self.watchlist.array(forKey: "Title") as? Array<String>)!
            years = (self.watchlist.array(forKey: "Year") as? Array<String>)!
            genres = (self.watchlist.array(forKey: "Genre") as? Array<String>)!
            plots = (self.watchlist.array(forKey: "Plot") as? Array<String>)!
        }
    }

    
    // Show alert with error message
    func alertUser(message: String) {
        let alertController = UIAlertController(title: "Oops!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        return
    }
}


//MARK: - Tableview Delegate & Datasource

extension ViewController: UITableViewDataSource {
    // Set number of rows.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    // Create new cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MovieCell
        newCell.movieTitle.text = movies[indexPath.row]
        newCell.movieYear.text = years[indexPath.row]
        
        // Get poster image for movie. If not found, show default image
        if posters[indexPath.row] != "N/A" {
            newCell.moviePoster.image = getPoster(poster: posters[indexPath.row])
        }else {
            newCell.moviePoster.image = UIImage(named: "default_poster")
        }
        
        currentIndex = indexPath.row
        return newCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // remove movie from watchlist by swiping left on cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            removeMovie(indexPath.row)
        }

    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentIndex = indexPath.row
    }
    
    // prepare for next view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewMovie = segue.destination as! ViewMovie
        
        viewMovie.moviePoster = getPoster(poster: self.posters[tableView.indexPathForSelectedRow!.row])
        viewMovie.movieTitle = self.movies[tableView.indexPathForSelectedRow!.row]
        viewMovie.movieYear = self.years[tableView.indexPathForSelectedRow!.row]
        viewMovie.movieGenre = self.genres[tableView.indexPathForSelectedRow!.row]
        viewMovie.movieDescription = self.plots[tableView.indexPathForSelectedRow!.row]
        viewMovie.currentIndex = currentIndex
    }
}
