//
//  SearchMovieViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 07/04/23.
//

import UIKit

class SearchMovieViewController: UIViewController {
    
    @IBOutlet weak var nameOfMovieTextField: UITextField!
    @IBOutlet weak var foundMoviesCollection: UICollectionView!
    @IBOutlet weak var cancelButtonConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tablaHistorialMovies: UITableView!
    @IBOutlet weak var alturaTablaHistorialConstraint: NSLayoutConstraint!
    @IBOutlet weak var eraseButtonConstraint: NSLayoutConstraint!
    
    var historialMovies : [String] = []
    
    var moviesFound: [DataMovie] = []
    
    var manager = MoviesManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tablaHistorialMovies.delegate = self
        tablaHistorialMovies.dataSource = self
        
        nameOfMovieTextField.delegate = self
        foundMoviesCollection.delegate = self
        foundMoviesCollection.dataSource = self
        
        setupCollection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        manager.checkInternetConnectivity { isInternetAvailable in
            if !isInternetAvailable {
                DispatchQueue.main.async {
                    self.showAlertToAction()
                }
            }
        }
    }
    
    func showAlertToAction(){
        let alerta = UIAlertController(title: "Atención", message: "Para buscar películas necesitas tener conexión a internet.", preferredStyle: .alert)
        let verificarConexion = UIAlertAction(title: "Abrir configuración", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
        alerta.addAction(verificarConexion)
        present(alerta, animated: true)
    }
    
    private func setupCollection() {
        foundMoviesCollection.collectionViewLayout = UICollectionViewFlowLayout()
        if let flowLayout = foundMoviesCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
        
        cancelButtonConstraint.constant = 0
        eraseButtonConstraint.constant = 0
        alturaTablaHistorialConstraint.constant = 0
    }
        
     
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func searchMovie(nameOfMovie: String){
        self.moviesFound.removeAll()
        self.foundMoviesCollection.reloadData()
        manager.searchMovies(nameOfMovie: nameOfMovie) { [weak self] numPagesFounded, listOfMovies, error in
            
            if error != nil || listOfMovies.isEmpty {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Atención", message: "No se encontraron películas con ese nombre, favor de verificar de nuevo.")
                }
            }
            
            if !listOfMovies.isEmpty {
                self?.moviesFound = listOfMovies

                DispatchQueue.main.async {
                    self?.foundMoviesCollection.reloadData()
                }
            }
        }
    }
    
    
    
    func showAlert(title: String, message: String) {
        let alerta = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default) { _ in
            //Do something
            
        }
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
    }
    
    // MARK:  Actions
    @IBAction func erasteTextButton(_ sender: UIButton) {
        eraseButtonConstraint.constant = 0
        nameOfMovieTextField.text = ""
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        if nameOfMovieTextField.text == "" {
            nameOfMovieTextField.text = " "
            nameOfMovieTextField.endEditing(true)
        }
        cancelButtonConstraint.constant = 0
        eraseButtonConstraint.constant = 0
        alturaTablaHistorialConstraint.constant = 0
        nameOfMovieTextField.endEditing(true)
    }
    
}


// MARK:  Collection
extension SearchMovieViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        moviesFound.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoundMovieCell", for: indexPath) as! FoundMovieCell
        
        cell.setup(movie: moviesFound[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //Vibracion
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        print("Debug: moviesFound \(moviesFound[indexPath.row])")

        let storyboard = UIStoryboard(name: "DetalleMovie", bundle: nil)
        let ViewController = storyboard.instantiateViewController(withIdentifier: "DetailTrailersMovieViewController") as! DetailTrailersMovieViewController


        ViewController.modalPresentationStyle = .fullScreen ///Tipo de visualizacion
        ViewController.modalTransitionStyle = .crossDissolve ///Tipo de animacion al cambiar pantalla

        ///Enviar informacion a traves de la instancia del view controller
        ViewController.recibirPeliculaMostrar = moviesFound[indexPath.row]

        present(ViewController, animated: true)
    }
    
}

// MARK:  Tabla Historial
extension SearchMovieViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        historialMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        
        celda.textLabel?.text = historialMovies[indexPath.row]
        
        return celda
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //Vibracion
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        nameOfMovieTextField.text = historialMovies[indexPath.row]
        
        if let movieToSearch = nameOfMovieTextField.text?.lowercased().replacingOccurrences(of: " ", with: "%20") {
            searchMovie(nameOfMovie: movieToSearch)
            alturaTablaHistorialConstraint.constant = 0
            nameOfMovieTextField.endEditing(true)
            nameOfMovieTextField.text = ""
        }
        
    }
    
}


extension SearchMovieViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 180)
    }
}

//MARK: UITextFieldDelegate
extension SearchMovieViewController: UITextFieldDelegate {
    ///1.- Habilitar el boton del teclado virtual
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    ///2.- Identificar cuando el usuario termina de editar y que pueda borrar el contenido del textField
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text!.count > 2 {
            let nameOfMovie = textField.text!.lowercased().replacingOccurrences(of: " ", with: "%20").folding( options: .diacriticInsensitive,locale: .current)
            searchMovie(nameOfMovie: nameOfMovie )
            
            //Buscar en el historial si ya existe p borrarlo y agregarlo mas reciente
            if let historial = UserDefaults.standard.array(forKey: "historialMovies") as? [String] {
                print("Debug: Buscando historial guardado...")

                historialMovies = historial
                historialMovies.reverse()
                print("Debug: historialMovies \(historialMovies)")

                print("Debug: nameOfMovie \(nameOfMovie)")

                if let elementoEliminar = historialMovies.firstIndex(where: { $0 == "\(nameOfMovie.replacingOccurrences(of: "%20", with: " "))" }) {
                    historialMovies.remove(at: elementoEliminar)
                    print("Debug: elementoEliminar \(elementoEliminar)")
                }
            }
            let nameWithouthCharacters = nameOfMovie.replacingOccurrences(of: "%20", with: " ")
            historialMovies.append(nameWithouthCharacters)
            historialMovies.reverse()
            UserDefaults.standard.set(historialMovies, forKey: "historialMovies")

            textField.text = ""
            alturaTablaHistorialConstraint.constant = 0
            textField.endEditing(true)
            eraseButtonConstraint.constant = 0
            cancelButtonConstraint.constant = 0
        }
        
        
    }
    
    ///3.- Evitar que el usuario no escriba nada
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            //el usuario no escribio nada
            textField.placeholder = "Escribe el nombre de una pelicula"
            self.showAlert(title: "Atención", message: "Para buscar peliculas debes de escribir el nombre de una pelicula")
            return false
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        cancelButtonConstraint.constant = 80
        return true
    }
    
    ///4.- Buscando cada vez que el usuario escribe un nuevo caracter.
    func textFieldDidChangeSelection(_ textField: UITextField) {
        cancelButtonConstraint.constant = 80
        if textField.text!.count > 0 {
            eraseButtonConstraint.constant = 20
        } else {
            eraseButtonConstraint.constant = 0
        }
        
        if textField.text!.count < 4 {
            self.moviesFound.removeAll()
            self.foundMoviesCollection.reloadData()
        }
         let nameOfMovie = nameOfMovieTextField.text!.replacingOccurrences(of: " ", with: "%20").folding( options: .diacriticInsensitive,locale: .current)
            if nameOfMovie.count > 3 {
                self.moviesFound.removeAll()
                self.foundMoviesCollection.reloadData()

                self.searchMovie(nameOfMovie: nameOfMovie)
            }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        ///Buscar historial guardado para mostrar tabla
        if let historial = UserDefaults.standard.array(forKey: "historialMovies") as? [String] {
            
            historialMovies = historial

            if !historialMovies.isEmpty {
//                self.borrarHistorialButton.isHidden = false
                
                switch historial.count {
                case 1...2 :
                    self.alturaTablaHistorialConstraint.constant = 70
                case 3...4:
                    self.alturaTablaHistorialConstraint.constant = 150
                case 5...6:
                    self.alturaTablaHistorialConstraint.constant = 200
                default:
                    self.alturaTablaHistorialConstraint.constant = 250
                }
                                self.tablaHistorialMovies.reloadData()
            } else {
                alturaTablaHistorialConstraint.constant = 0
            }
            
        } else {
            print("Debug: no hay historial guardado!")

        }
    }
}
