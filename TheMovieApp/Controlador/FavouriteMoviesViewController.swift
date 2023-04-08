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
    
    var favoriteMovies: [FavouriteMovie] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableFavouriteMovies.register(UINib(nibName: "FavoriteCell", bundle: nil), forCellReuseIdentifier: "FavoriteCell")
        
        tableFavouriteMovies.delegate = self
        tableFavouriteMovies.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        readMovies()
    }
    
    private func readMovies(){
        self.favoriteMovies.removeAll()
        let solicitud : NSFetchRequest<FavouriteMovie> = FavouriteMovie.fetchRequest()
        do {
            favoriteMovies =  try contexto.fetch(solicitud)
            print("Debug: Read DB ")
        } catch  {
            print("Error al leer de core data,",error.localizedDescription)
        }
        tableFavouriteMovies.reloadData()
    }

    

}

extension FavouriteMoviesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favoriteMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoriteCell
        
        
        cell.titleMovie.text = favoriteMovies[indexPath.row].titulo ?? ""
        cell.releaseDateMovie.text = favoriteMovies[indexPath.row].fecha
        cell.descripctionMovie.text = favoriteMovies[indexPath.row].descripcion
        
        if let image = UIImage(data: favoriteMovies[indexPath.row].poster!) {
            cell.posterMovie.image = image
        }
       
        cell.posterMovie.layer.cornerRadius = 12
        cell.posterMovie.layer.masksToBounds = true
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction  = UIContextualAction(style: .normal, title: "quitar") { _, _, _ in
            
            self.contexto.delete(self.favoriteMovies[indexPath.row])
            self.favoriteMovies.remove(at: indexPath.row)
        
            do {
                try self.contexto.save()
            } catch  {
                print("Error al guardar en la bd", error.localizedDescription)
            }
            self.tableFavouriteMovies.reloadData()
        }
        
        let shareAction = UIContextualAction(style: .normal, title: "compartir") { _, _, _ in
            
            guard let poster = self.favoriteMovies[indexPath.row].poster else { return }
            guard let image = UIImage(data: poster) else { return }
            
            let vc = UIActivityViewController(
                activityItems:
                    ["\(self.favoriteMovies[indexPath.row].titulo ?? "") descarga la app en: https://testflight.apple.com/join/QCF7X63I", image], applicationActivities: nil)
            self.present(vc, animated: true)
            
        }
        
        
        shareAction.image = UIImage(systemName: "arrowshape.turn.up.right")
        shareAction.backgroundColor = .blue
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction, shareAction ])
    }
}
