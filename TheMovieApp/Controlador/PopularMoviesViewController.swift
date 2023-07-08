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
    
    
    @IBOutlet weak var scrollMain: UIScrollView!
    @IBOutlet weak var popularMoviesCollection: UICollectionView!
    @IBOutlet weak var nowPlayingMoviesCollection: UICollectionView!
    @IBOutlet weak var topRatedMoviesCollection: UICollectionView!
    
    var popularMoviesList: [DataMovie] = []
    var topRatedMovies: [DataMovie] = []
    var nowPlaying: [DataMovie] = []
    
    var numPagePopularMovies = 1
    var totalPagesPopularMovies = 1
    
    var numPageTopRatedMovies = 1
    var totalPagesTopRatedMovies  = 1
    
    var numPageNowPlayingMovies = 1
    var totalPagesNowPlayingMovies = 1
    
    var timerGetMoteMovies = Timer()
    var timerGetTopRatedMovies = Timer()
    var timerGetNowPlayingMovies = Timer()
    
    var manager = MoviesManager()
    var activityView: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popularMoviesCollection.delegate = self
        popularMoviesCollection.dataSource = self
        
        topRatedMoviesCollection.delegate = self
        topRatedMoviesCollection.dataSource = self
        
        nowPlayingMoviesCollection.delegate = self
        nowPlayingMoviesCollection.dataSource = self
        
        setupCollection()
        
        obtenerPeliculas(numPag: self.numPagePopularMovies)
        getTopMovies(numPag: self.numPageTopRatedMovies)
        getNowPlaying(numPage: self.numPageNowPlayingMovies)
        
        timerGetMoteMovies = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getMoreMovies), userInfo: nil, repeats: true)
        timerGetTopRatedMovies = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getTopRatedMovies), userInfo: nil, repeats: true)
        timerGetNowPlayingMovies = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getNowPlayingMovies), userInfo: nil, repeats: true)
    }

    @objc func getMoreMovies() {
        obtenerPeliculas(numPag: self.numPagePopularMovies)
    }
    
    @objc func getTopRatedMovies() {
        getTopMovies(numPag: self.numPageTopRatedMovies)
    }
    
    @objc func getNowPlayingMovies() {
        getNowPlaying(numPage: self.numPageNowPlayingMovies)
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
        //Scroll
        scrollMain.isDirectionalLockEnabled = true
        scrollMain.alwaysBounceVertical = true
        scrollMain.showsVerticalScrollIndicator = false
        scrollMain.showsHorizontalScrollIndicator = false
        popularMoviesCollection.collectionViewLayout = UICollectionViewFlowLayout()
        if let flowLayout = popularMoviesCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
        
        topRatedMoviesCollection.collectionViewLayout = UICollectionViewFlowLayout()
        if let flowLayout = topRatedMoviesCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
        
        nowPlayingMoviesCollection.collectionViewLayout = UICollectionViewFlowLayout()
        if let flowLayout = nowPlayingMoviesCollection.collectionViewLayout as? UICollectionViewFlowLayout {
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
        
        manager.getPopularMovies(numPagina: numPag) { [weak self] numPages, listaPeliculas, error in
            guard let self = self else { return }
            self.totalPagesPopularMovies = numPages
            
            if let listaPeliculas = listaPeliculas {

                self.popularMoviesList.append(contentsOf: listaPeliculas)  ///Agregar al arreglo
                
                DispatchQueue.main.async { ///Hilo principal, actualizar la Interfaz de usuario
                    self.popularMoviesCollection.reloadData()
                }
            }
            
            self.numPagePopularMovies += 1
            
            if self.numPagePopularMovies == self.totalPagesPopularMovies {
                self.timerGetMoteMovies.invalidate()
            }
        }
    }
    
    private func getTopMovies(numPag: Int){
        
        manager.getTopRatedMovies(numPagina: numPag) { [weak self] numPages, listaPeliculas, error in
            guard let self = self else { return }
            self.totalPagesTopRatedMovies = numPages
            
            if let listaPeliculas = listaPeliculas {
                self.topRatedMovies.append(contentsOf: listaPeliculas)  ///Agregar al arreglo
                
                DispatchQueue.main.async { ///Hilo principal, actualizar la Interfaz de usuario
                    self.topRatedMoviesCollection.reloadData()
                }
            }
            
            self.numPageTopRatedMovies += 1
            
            if self.numPageTopRatedMovies == self.totalPagesTopRatedMovies {
                self.timerGetTopRatedMovies.invalidate()
            }
        }
    }
    
    private func getNowPlaying(numPage: Int){
        
        manager.getNowPlayingMovies(numPag: numPage) { [weak self] numPages, listaPeliculas, error in
            guard let self = self else { return }
            self.totalPagesNowPlayingMovies = numPages
            
            if let listaPeliculas = listaPeliculas {
                self.nowPlaying.append(contentsOf: listaPeliculas)  ///Agregar al arreglo
                
                DispatchQueue.main.async { ///Hilo principal, actualizar la Interfaz de usuario
                    self.nowPlayingMoviesCollection.reloadData()
                }
            }
            
            self.numPageNowPlayingMovies += 1
            
            if self.numPageNowPlayingMovies == self.totalPagesNowPlayingMovies {
                self.timerGetNowPlayingMovies.invalidate()
            }
        }
    }

}



// MARK:  CollectionView Methods
extension PopularMoviesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.popularMoviesCollection {
            return popularMoviesList.count
        }
        
        if collectionView == self.topRatedMoviesCollection {
            return topRatedMovies.count
        }
        
        if collectionView == self.nowPlayingMoviesCollection {
            return nowPlaying.count
        }
        
        else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.popularMoviesCollection {
            let celda = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularesCell", for: indexPath) as! PopularesCell
            
            celda.setupCell(movie: popularMoviesList[indexPath.row])
            
            return celda
        }
        
        if collectionView == self.topRatedMoviesCollection {
            let celda = collectionView.dequeueReusableCell(withReuseIdentifier: "TopRatedCell", for: indexPath) as! TopRatedCell
            
            celda.setupCell(movie: topRatedMovies[indexPath.row])
            
            return celda
        }
        
        if collectionView == self.nowPlayingMoviesCollection {
            let celda = collectionView.dequeueReusableCell(withReuseIdentifier: "NowPlayingCell", for: indexPath) as! NowPlayingCell
            
            celda.setupCell(movie: nowPlaying[indexPath.row])
            
            return celda
        }
        
        else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Vibracion
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        switch collectionView {
        case popularMoviesCollection:
            goToDetailMovieTrailer(movieToWatch: popularMoviesList[indexPath.row])
            
        case topRatedMoviesCollection:
            goToDetailMovieTrailer(movieToWatch: topRatedMovies[indexPath.row])
            
        case nowPlayingMoviesCollection:
            goToDetailMovieTrailer(movieToWatch: nowPlaying[indexPath.row])
        
        default:
            print("Default")
        }
    }
    
    func goToDetailMovieTrailer(movieToWatch: DataMovie){
        let storyboard = UIStoryboard(name: "DetalleMovie", bundle: nil)
        let ViewController = storyboard.instantiateViewController(withIdentifier: "DetailTrailersMovieViewController") as! DetailTrailersMovieViewController
        
        
        ViewController.modalPresentationStyle = .fullScreen ///Tipo de visualizacion
        ViewController.modalTransitionStyle = .crossDissolve ///Tipo de animacion al cambiar pantalla
        
        ///Enviar informacion a traves de la instancia del view controller
        ViewController.recibirPeliculaMostrar = movieToWatch
        
        present(ViewController, animated: true)
    }
}

// MARK:  FlowLayout
extension PopularMoviesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 165, height: 245)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }


}
