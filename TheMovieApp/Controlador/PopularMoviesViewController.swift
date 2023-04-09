//
//  PopularMoviesViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 06/04/23.
//

import UIKit
import Kingfisher
import ProgressHUD

class PopularMoviesViewController: UIViewController {
    
    
    @IBOutlet weak var popularMoviesCollection: UICollectionView!
    
    var popularMoviesList: [DataMovie] = []
    var numPagina = 1
    var totalPages = 1
    private var isLoadingMoreCharacters = false
    
    var manager = MoviesManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popularMoviesCollection.delegate = self
        popularMoviesCollection.dataSource = self
        
        setupCollection()
        obtenerPeliculas(numPag: self.numPagina)
    }
    
    private func setupCollection(){
        popularMoviesCollection.collectionViewLayout = UICollectionViewFlowLayout()
        if let flowLayout = popularMoviesCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
    }
    
    private func obtenerPeliculas(numPag: Int){
        
        ///Si esta cargando mas caracteres detente
        guard !isLoadingMoreCharacters else {
            return
        }
        isLoadingMoreCharacters = true
        ProgressHUD.show("Buscando", icon: .shuffle)
        
        manager.getPopularMovies(numPagina: numPag) { numPages, listaPeliculas, error in
            self.totalPages = numPages
            
            if let listaPeliculas = listaPeliculas {
                print("Debug: listaPeliculas \(listaPeliculas)")

                self.popularMoviesList.append(contentsOf: listaPeliculas)  ///Agregar al arreglo
                
                DispatchQueue.main.async { ///Hilo principal, actualizar la Interfaz de usuario
                    self.popularMoviesCollection.reloadData()
                    self.isLoadingMoreCharacters = false

                        ProgressHUD.remove()
                    
                    self.numPagina += 1
                    print("Debug: numPag func\(self.numPagina)")

                }
            }
        }
    }

}

// MARK:  DidScroll
extension PopularMoviesViewController: UIScrollViewDelegate {
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
}

// MARK:  FlowLayout
extension PopularMoviesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 145, height: 195)
    }

}

extension PopularMoviesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        popularMoviesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let celda = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularesCell", for: indexPath) as! PopularesCell
        
        celda.setupCell(movie: popularMoviesList[indexPath.row])
        
        return celda
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let ViewController = storyboard.instantiateViewController(withIdentifier: "DetalleMovieViewController") as! DetalleMovieViewController
        
        ///- * New Flow of Movie Detail
        let storyboard = UIStoryboard(name: "DetalleMovie", bundle: nil)
        let ViewController = storyboard.instantiateViewController(withIdentifier: "DetailTrailersMovieViewController") as! DetailTrailersMovieViewController
        
        
        ViewController.modalPresentationStyle = .pageSheet ///Tipo de visualizacion
        ViewController.modalTransitionStyle = .crossDissolve ///Tipo de animacion al cambiar pantalla
        
        ///Enviar informacion a traves de la instancia del view controller
        ViewController.recibirPeliculaMostrar = popularMoviesList[indexPath.row]
        
        present(ViewController, animated: true)
    }
    
}
