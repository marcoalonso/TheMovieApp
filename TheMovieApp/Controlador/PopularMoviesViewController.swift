//
//  PopularMoviesViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 06/04/23.
//

import UIKit
import Kingfisher
import DataCache

class PopularMoviesViewController: UIViewController {
    
    
    @IBOutlet weak var popularMoviesCollection: UICollectionView!
    
    var popularMoviesList: [DataMovie] = []
    var numPagina = 1
    var totalPages = 1
    private var isLoadingMoreCharacters = false
    var timerGetMoteMovies = Timer()
    var manager = MoviesManager()
    var activityView: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popularMoviesCollection.delegate = self
        popularMoviesCollection.dataSource = self
        
        setupCollection()
        obtenerPeliculas(numPag: self.numPagina)
        
        timerGetMoteMovies = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(getMoreMovies), userInfo: nil, repeats: true)
        
    }

    @objc func getMoreMovies() {
        obtenerPeliculas(numPag: self.numPagina)
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
    
    private func setupCollection(){
        popularMoviesCollection.collectionViewLayout = UICollectionViewFlowLayout()
        if let flowLayout = popularMoviesCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
    }
    
    func showAlertToAction(){
        let alerta = UIAlertController(title: "Atención", message: "Para continuar necesitas tener conexión a internet.", preferredStyle: .alert)
        
        let aceptar = UIAlertAction(title: "Continuar", style: .default) { _ in
            self.checkCachePopularMovies()
        }
        
        let verificarConexion = UIAlertAction(title: "Abrir configuración", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
        
        alerta.addAction(aceptar)
        alerta.addAction(verificarConexion)
        present(alerta, animated: true)
    }
    
    private func checkCachePopularMovies(){
        if let dataCache = DataCache.instance.readData(forKey: "dataPopularMovies") {
            do {
                let moviesFromCache = try JSONDecoder().decode(MovieDataModel.self, from: dataCache)
                self.popularMoviesList = moviesFromCache.results ?? []
                print("Debug: listaProximosEstrenos \(self.popularMoviesList.count)")

                DispatchQueue.main.async {
                    self.popularMoviesCollection.reloadData()
                }
            } catch {
                print("Debug: error al codificar data de cache \(error.localizedDescription)")
            }
        } else {
            DispatchQueue.main.async {
                self.showAlertToAction()
            }
        }
    }
    
    
    func showActivityIndicator() {
        activityView = UIActivityIndicatorView(style: .large)
        activityView?.center = self.view.center
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
    }
    
    func hideActivityIndicator(){
        if (activityView != nil){
            activityView?.stopAnimating()
        }
    }
    
    private func obtenerPeliculas(numPag: Int){
        
        ///Si esta cargando mas caracteres detente
        guard !isLoadingMoreCharacters else {
            return
        }
        isLoadingMoreCharacters = true
        showActivityIndicator()
        
        manager.getPopularMovies(numPagina: numPag) { [weak self] numPages, listaPeliculas, error in
            guard let self = self else { return }
            self.totalPages = numPages
            print("Debug: totalPages \(self.totalPages)")

            
            if let listaPeliculas = listaPeliculas {
                print("Debug: listaPeliculas \(listaPeliculas)")

                self.popularMoviesList.append(contentsOf: listaPeliculas)  ///Agregar al arreglo
                
                DispatchQueue.main.async { ///Hilo principal, actualizar la Interfaz de usuario
                    self.popularMoviesCollection.reloadData()
                    self.isLoadingMoreCharacters = false

                    self.hideActivityIndicator()
                }
            }
            
            self.numPagina += 1
            print("Debug: numPag \(self.numPagina)")
            
            ///Valida si la pagina actual es menor de las disponibles
            if self.numPagina == self.totalPages {
                self.timerGetMoteMovies.invalidate()
            }
        }
    }

}

// MARK:  DidScroll
extension PopularMoviesViewController: UIScrollViewDelegate {
    
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
