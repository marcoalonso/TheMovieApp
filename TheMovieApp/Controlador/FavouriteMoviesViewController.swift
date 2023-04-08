//
//  FavouriteMoviesViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 08/04/23.
//

import UIKit
import CoreData

class FavouriteMoviesViewController: UIViewController {

    
    @IBOutlet weak var tableFavouriteMovies: UITableView!
    
    // MARK: - Contexto
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var favouriteMovies: [FavouriteMovie] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableFavouriteMovies.delegate = self
        tableFavouriteMovies.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        readMovies()
    }
    
    private func readMovies(){
        self.favouriteMovies.removeAll()
        let solicitud : NSFetchRequest<FavouriteMovie> = FavouriteMovie.fetchRequest()
        do {
            favouriteMovies =  try contexto.fetch(solicitud)
            print("Debug: Read DB ")
        } catch  {
            print("Error al leer de core data,",error.localizedDescription)
        }
        tableFavouriteMovies.reloadData()
    }

    

}

extension FavouriteMoviesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favouriteMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = "\(favouriteMovies[indexPath.row].titulo ?? "") id: \(favouriteMovies[indexPath.row].id)"
        cell.detailTextLabel?.text = favouriteMovies[indexPath.row].fecha
        
        return cell
    }
    
    
}
