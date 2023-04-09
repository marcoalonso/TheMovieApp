//
//  PerfilViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 08/04/23.
//

import UIKit
import CoreData

class PerfilViewController: UIViewController {
    
    @IBOutlet weak var photoUser: UIImageView!
    @IBOutlet weak var nameUser: UILabel!
    @IBOutlet weak var genresUser: UITextView!
    
    @IBOutlet weak var tableWishListMovies: UITableView!
    
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var watchLateMovies: [WishMovie] = []
    var usuarioData : [Usuario] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableWishListMovies.register(UINib(nibName: "WatchLateCell", bundle: nil), forCellReuseIdentifier: "WatchLateCell")

        tableWishListMovies.delegate = self
        tableWishListMovies.dataSource = self
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        readMovies()
        readProfileData()
    }
    
    private func setupUI(){
        photoUser.layer.cornerRadius = 25
        photoUser.layer.masksToBounds = true
    }
    
    private func readProfileData(){
        let solicitud : NSFetchRequest<Usuario> = Usuario.fetchRequest()
        
        do {
            usuarioData =  try contexto.fetch(solicitud)
            print("Debug: usuarioData \(usuarioData)")

        } catch  {
            print("Error al leer de core data,",error.localizedDescription)
        }
        
        if !usuarioData.isEmpty {
            if let dataPhoto = usuarioData[0].foto {
                photoUser.image = UIImage(data: dataPhoto)
                nameUser.text = "Bienvenido \(usuarioData[0].nombre ?? "")"
                genresUser.text = usuarioData[0].generos
            }
        }
    }

    private func readMovies(){
        self.watchLateMovies.removeAll()
        let solicitud : NSFetchRequest<WishMovie> = WishMovie.fetchRequest()
        do {
            watchLateMovies =  try contexto.fetch(solicitud)
            print("Debug: watchLateMovies \(watchLateMovies.count)")

        } catch  {
            print("Error al leer de core data,",error.localizedDescription)
        }
        tableWishListMovies.reloadData()
    }

    @IBAction func editProfileButton(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditarPerfilViewController") as! EditarPerfilViewController
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        
        if !usuarioData.isEmpty {
            vc.dataUser = usuarioData[0]
        }
        
        
        self.present(vc, animated: true)
    }
    
    
}

extension PerfilViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        watchLateMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WatchLateCell", for: indexPath) as! WatchLateCell
        
        cell.namoOfMovieWatchLate.text = watchLateMovies[indexPath.row].titulo
        if let dataImage = watchLateMovies[indexPath.row].poster {
            cell.posterMovieWatchLate.image = UIImage(data: dataImage)
            cell.posterMovieWatchLate.layer.masksToBounds = true
            cell.posterMovieWatchLate.layer.cornerRadius = 15
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = watchLateMovies[indexPath.row]
        self.mostrarAlerta(titulo: "\(movie.titulo ?? "")", mensaje: "\(movie.description)")
    }
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "OK", style: .default) { _ in
            //Do something
        }
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190
    }
    
    
    
}
