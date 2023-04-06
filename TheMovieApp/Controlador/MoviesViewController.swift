//
//  ViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 29/03/23.
//

import UIKit
import Kingfisher
import ProgressHUD

class MoviesViewController: UIViewController {
    
    @IBOutlet weak var estrenosCollection: UICollectionView!
    
    var listaProximosEstrenos: [EstrenoMovie] = []
    var numPagina = 1
    var totalPages = 1
    
    private var isLoadingMoreCharacters = false
    
    var manager = MoviesManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        estrenosCollection.dataSource = self
        estrenosCollection.delegate = self
        
        setupCollection()
        obtenerPeliculas(numPag: self.numPagina)
    }
    
    private func setupCollection(){
        estrenosCollection.collectionViewLayout = UICollectionViewFlowLayout()
        if let flowLayout = estrenosCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
    }
    
    private func obtenerPeliculas(numPag: Int){
        
        ///Si esta cargando mas caracteres detente
        guard !isLoadingMoreCharacters else {
            return
        }
        isLoadingMoreCharacters = true
        print("Fetching more characters")
        ProgressHUD.show("Buscando", icon: .shuffle)
        
        manager.obtenerProximosEstrenos(numPagina: numPag) { numPages, listaPeliculas, error in
            self.totalPages = numPages
            
            if let listaPeliculas = listaPeliculas {
                self.listaProximosEstrenos.append(contentsOf: listaPeliculas)  ///Agregar al arreglo
                
                DispatchQueue.main.async { ///Hilo principal, actualizar la Interfaz de usuario
                    self.estrenosCollection.reloadData()
                    self.isLoadingMoreCharacters = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        ProgressHUD.remove()
                    }
                    self.numPagina += 1
                    print("Debug: numPag func\(self.numPagina)")

                }
            }
        }
    }
    
}

extension MoviesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard !isLoadingMoreCharacters else { return }
        
        ///This shoet delay is because at the first calculation of the scrollView do the same validation to scroll
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] t in
            guard let self = self else { return }
            let offset = scrollView.contentOffset.x
            let totalContentHeight = scrollView.contentSize.width
            let totalScrollViewFixedHeight = scrollView.frame.size.width
            
            if offset >= (totalContentHeight - totalScrollViewFixedHeight) {
                
                ///Valida si la pagina actual es menor de las disponibles
                if self.numPagina < self.totalPages {
                    
                    
                    DispatchQueue.main.async {
                        self.obtenerPeliculas(numPag: self.numPagina)
                    }
                }
            }
            t.invalidate()
        }
    }
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "OK", style: .default) { _ in
            //Do something
        }
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
    }
}

extension MoviesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 138, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
}


// MARK:  UICollectionViewDataSource
extension MoviesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listaProximosEstrenos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let celda = collectionView.dequeueReusableCell(withReuseIdentifier: "EstrenosCell", for: indexPath) as! EstrenosCell
        
        
        let url = URL(string: "https://image.tmdb.org/t/p/w200/\(listaProximosEstrenos[indexPath.row].poster_path ?? "")")
        
        celda.posterMovie.kf.setImage(with: url)
        celda.posterMovie.layer.cornerRadius = 25
        celda.layer.masksToBounds = true
        
        return celda
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ViewController = storyboard.instantiateViewController(withIdentifier: "DetalleMovieViewController") as! DetalleMovieViewController
        
        ViewController.modalPresentationStyle = .fullScreen ///Tipo de visualizacion
        ViewController.modalTransitionStyle = .crossDissolve ///Tipo de animacion al cambiar pantalla
        
        ///Enviar informacion a traves de la instancia del view controller
        ViewController.recibirPeliculaMostrar = listaProximosEstrenos[indexPath.row]
        
        present(ViewController, animated: true)
    }
    
}
