//
//  PerfilViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 08/04/23.
//

import UIKit
import CoreData

class PerfilViewController: UIViewController {
    
    @IBOutlet weak var historialButton: UIButton!
    @IBOutlet weak var historialEliminadoLabel: UILabel!
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
        
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        readMovies()
        readProfileData()
        setupUI()
    }
    
    private func setupUI(){
        photoUser.layer.cornerRadius = 25
        photoUser.layer.masksToBounds = true
        historialEliminadoLabel.isHidden = true
        
        //Check if there are history and show button
        if let historial = UserDefaults.standard.array(forKey: "historialMovies") as? [String] {
            if historial.isEmpty {
                historialButton.isHidden = true
                print("Debug: No se encontro historial, ocultar boton para eliminar")
                
            } else {
                historialButton.isHidden = false
                print("Debug: Se encontro historial se muestra boton para eliminar")
            }
            

        }
        
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
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "Si", style: .default) { _ in
            //Navegar
        }
        let accionCancelar = UIAlertAction(title: "No", style: .destructive) { _ in
            //Navegar
        }
        alerta.addAction(accionAceptar)
        alerta.addAction(accionCancelar)
        present(alerta, animated: true)
    }
    
    // MARK:  Actions
    @IBAction func moreButton(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MoreViewController") as! MoreViewController
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
    
    
    @IBAction func cinesCercanosButton(_ sender: UIButton) {
        let viewControllerCines = CinesCercanosViewController(nibName: "CinesCercanosViewController", bundle: nil)
        viewControllerCines.modalPresentationStyle = .fullScreen
        viewControllerCines.modalTransitionStyle = .crossDissolve
        self.present(viewControllerCines, animated: true)
    }
    
    
    @IBAction func comprarBoletos(_ sender: UIButton) {
        
        let alerta = UIAlertController(title: "Atención", message: "Las siguientes páginas web son ajenas a la aplicación, ¿Deseas continuar?", preferredStyle: .alert)
        
        let cinepolis = UIAlertAction(title: "Visitar Cinemex", style: .default) { _ in
            let vcWeb = WebViewController(nibName: "WebViewController", bundle: nil)
            vcWeb.modalPresentationStyle = .fullScreen
            vcWeb.modalTransitionStyle = .crossDissolve
            vcWeb.urlBusqueda = "https://cinemex.com/"
            vcWeb.nameMovieTeather = "Cinemex"
            self.present(vcWeb, animated: true)
        }
        
        let cinemex = UIAlertAction(title: "Visitar Cinepolis", style: .default) { _ in
            let vcWeb = WebViewController(nibName: "WebViewController", bundle: nil)
            vcWeb.modalPresentationStyle = .fullScreen
            vcWeb.modalTransitionStyle = .crossDissolve
            vcWeb.urlBusqueda = "https://cinepolis.com/"
            vcWeb.nameMovieTeather = "Cinepolis"
            self.present(vcWeb, animated: true)
        }
        
        let accionCancelar = UIAlertAction(title: "Cancelar", style: .destructive)
        
        alerta.addAction(cinepolis)
        alerta.addAction(cinemex)
        alerta.addAction(accionCancelar)
        
        present(alerta, animated: true)
        
       
        
    }
    
    @IBAction func borrarHistorialButton(_ sender: UIButton) {
        
        self.historialButton.isHidden = true
        let alerta = UIAlertController(title: "Borrar historial", message: "¿Quieres eliminar el historia de búsqueda?", preferredStyle: .alert)
        
        let aceptar = UIAlertAction(title: "Si", style: .default) { _ in
            let historialMovies : [String] = []
            UserDefaults.standard.set(historialMovies, forKey: "historialMovies")
            //Animacion
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                self.historialEliminadoLabel.isHidden = false
                
            }, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                    self.historialEliminadoLabel.isHidden = true
                }, completion: nil)
            }
        }
        
        let cancelar = UIAlertAction(title: "No", style: .destructive)
        
        alerta.addAction(aceptar)
        alerta.addAction(cancelar)
        present(alerta, animated: true)
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
        cell.releaseDateWatchLate.text = watchLateMovies[indexPath.row].fecha
        if let dataImage = watchLateMovies[indexPath.row].poster {
            print("Debug: dataImage watch Late Movies : \(dataImage)")

            cell.posterMovieWatchLate.image = UIImage(data: dataImage)
            cell.posterMovieWatchLate.layer.masksToBounds = true
            cell.posterMovieWatchLate.layer.cornerRadius = 15
        } else {
            print("Debug: no hay data en ver peliculas despues")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Vibracion
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let movieSelected = watchLateMovies[indexPath.row]

        let storyboard = UIStoryboard(name: "DetalleMovie", bundle: nil)
        let ViewController = storyboard.instantiateViewController(withIdentifier: "DetailTrailersMovieViewController") as! DetailTrailersMovieViewController
        
        ViewController.modalPresentationStyle = .fullScreen ///Tipo de visualizacion
        ViewController.modalTransitionStyle = .crossDissolve ///Tipo de animacion al cambiar pantalla
        
        let movieData = DataMovie(backdrop_path: "", id: Int(movieSelected.id), original_title: movieSelected.titulo, overview: movieSelected.descripcion, title: movieSelected.titulo, release_date: movieSelected.fecha, poster_path: "")
        ViewController.recibirPeliculaMostrar = movieData
        ViewController.recibirPosterMovie = movieSelected.poster
        
        present(ViewController, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction  = UIContextualAction(style: .normal, title: "eliminar") { _, _, _ in
            
            self.contexto.delete(self.watchLateMovies[indexPath.row])
            self.watchLateMovies.remove(at: indexPath.row)
        
            do {
                try self.contexto.save()
            } catch  {
                print("Error al guardar en la bd", error.localizedDescription)
            }
            self.tableWishListMovies.reloadData()
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction ])
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
    
}
