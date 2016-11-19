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
    @IBOutlet weak var searchBar: UISearchBar!
    
    // When search button is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchMovie(title: searchBar.text!)
        view.endEditing(true)
        searchBar.text = ""
    }
    
    // When cancel button is clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        searchBar.text = ""
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
                    
                    // Alert when movie is not found
                    let response = movieDictionary["Response"] as? String
                    if response == "False" || movie == "" {
                        self.alertUser(title: "Oops!", message:"Movie not found")
                    }
                    // Alert when movie is already in the watchlist
                    else if self.movies.contains(movieDictionary["Title"] as! String) == true  {
                        self.alertUser(title: "Oops!", message:"This movie is already in your watchlist")
                    }
                    // When movie is found, add to watchlist
                    else {
                        self.addMovie(movieDictionary: movieDictionary)
                        self.updateWatchlist()
                    }
                    
                    // Reload table on main thread to load faster (source: Andrew @http://stackoverflow.com/questions/4968424/tableview-reloaddata-doesnt-work-until-i-scroll-the-tableview)
                    self.performSelector(onMainThread: #selector(ViewController.reloadTableView), with: nil, waitUntilDone: false)
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
    
    // Edit button to remove movies from watchlist
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBAction func editWatchlist(_ sender: Any) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            editButton.title = "Edit"
        } else{
            tableView.setEditing(true, animated: true)
            editButton.title = "Done"
        }
    }
    
    // reload watchlist
    func reloadTableView() {
        self.tableView.reloadData()
    }

    // Update watchlist
    func updateWatchlist() {
        self.watchlist.set(self.movies, forKey: "Title")
        self.watchlist.set(self.years, forKey: "Year")
        self.watchlist.set(self.plots, forKey: "Plot")
        self.watchlist.set(self.posters, forKey: "Poster")
        self.watchlist.set(self.genres, forKey: "Genre")
    }
    
    // When view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If watchlist is empty, show welcome message
        if watchlist.array(forKey: "Title") == nil {
            alertUser(title: "Welcome!", message:"Search for movies and add them to your watchlist.")
        } else {
            // Load the user's watchlist
            posters = (self.watchlist.array(forKey: "Poster") as? Array<String>)!
            movies = (self.watchlist.array(forKey: "Title") as? Array<String>)!
            years = (self.watchlist.array(forKey: "Year") as? Array<String>)!
            genres = (self.watchlist.array(forKey: "Genre") as? Array<String>)!
            plots = (self.watchlist.array(forKey: "Plot") as? Array<String>)!
        }
        
        // reference to searchbar delegate (apparently needed)
        searchBar.delegate = self
    }
    
    // Show alert with message
    func alertUser(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
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
    
    // Make cells editable
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Remove movie from watchlist by swiping left on cell
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
        
        // Get poster image for next view. If not found, use default image
        if posters[tableView.indexPathForSelectedRow!.row] != "N/A" {
            viewMovie.moviePoster = getPoster(poster: self.posters[tableView.indexPathForSelectedRow!.row])
        }else {
            viewMovie.moviePoster = UIImage(named: "default_poster")
        }
        
        // Get movie info for next view
        viewMovie.movieTitle = self.movies[tableView.indexPathForSelectedRow!.row]
        viewMovie.movieYear = self.years[tableView.indexPathForSelectedRow!.row]
        viewMovie.movieGenre = self.genres[tableView.indexPathForSelectedRow!.row]
        viewMovie.movieDescription = self.plots[tableView.indexPathForSelectedRow!.row]
        viewMovie.currentIndex = currentIndex
    }
}

// empty searchbar delegate (apparently needed)
extension ViewController: UISearchBarDelegate {
}
