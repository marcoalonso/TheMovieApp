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
    
    var moviesFound: [DataMovie] = []
    
    var manager = MoviesManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameOfMovieTextField.delegate = self
        foundMoviesCollection.delegate = self
        foundMoviesCollection.dataSource = self
        
        setupCollection()
    }
    
    private func setupCollection() {
        foundMoviesCollection.collectionViewLayout = UICollectionViewFlowLayout()
        if let flowLayout = foundMoviesCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
        }
    }
        
     
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func searchMovie(nameOfMovie: String){
        self.moviesFound.removeAll()
        manager.searchMovies(nameOfMovie: nameOfMovie) { [weak self] numPagesFounded, listOfMovies, error in
            
            if error != nil || listOfMovies.isEmpty {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Atención", message: "No se encontraron películas con ese nombre, favor de verificar de nuevo.")
                }
            }
            
            if !listOfMovies.isEmpty {
                self?.moviesFound = listOfMovies
                print("Debug: listOfMovies VC \(listOfMovies)")

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
        let storyboard = UIStoryboard(name: "DetalleMovie", bundle: nil)
        let ViewController = storyboard.instantiateViewController(withIdentifier: "DetailTrailersMovieViewController") as! DetailTrailersMovieViewController
        
        
        ViewController.modalPresentationStyle = .pageSheet ///Tipo de visualizacion
        ViewController.modalTransitionStyle = .crossDissolve ///Tipo de animacion al cambiar pantalla
        
        ///Enviar informacion a traves de la instancia del view controller
        ViewController.recibirPeliculaMostrar = moviesFound[indexPath.row]
        
        present(ViewController, animated: true)
    }
    
}

//EXTENSION
extension SearchMovieViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 230)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
}

//MARK: UITextFieldDelegate
extension SearchMovieViewController: UITextFieldDelegate {
    //1.- Habilitar el boton del teclado virtual
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    //2.- Identificar cuando el usuario termina de editar y que pueda borrar el contenido del textField
    func textFieldDidEndEditing(_ textField: UITextField) {
        //Hacer algo
        if textField.text!.count > 2 {
            let nameOfMovie = textField.text!.replacingOccurrences(of: " ", with: "%20").folding( options: .diacriticInsensitive,locale: .current)
            searchMovie(nameOfMovie: nameOfMovie )
            print("Debug: nameOfMovie \(nameOfMovie)")

        }
        
        
        textField.text = ""
        //ocultar teclado
        textField.endEditing(true)
    }
    
    //3.- Evitar que el usuario no escriba nada
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
    
//    func textFieldDidChangeSelection(_ textField: UITextField) {
//        if let nameOfMovie = textField.text?.replacingOccurrences(of: " ", with: "%20").folding( options: .diacriticInsensitive,locale: .current) {
//            if nameOfMovie.count > 3 {
//                self.searchMovie(nameOfMovie: nameOfMovie)
//            }
//        }
//    }
}