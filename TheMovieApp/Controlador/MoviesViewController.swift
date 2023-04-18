//
//  ViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 29/03/23.
//

import UIKit
import Kingfisher
import Network
import DataCache

class MoviesViewController: UIViewController {
    
    @IBOutlet weak var estrenosCollection: UICollectionView!
    
    var upcomingMovies: [DataMovie] = []
    var numPagina = 1
    var totalPages = 1
    
    private var isLoadingMoreCharacters = false
    
    var activityView: UIActivityIndicatorView?
    var manager = MoviesManager()
    var timerGetMoteMovies = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        estrenosCollection.dataSource = self
        estrenosCollection.delegate = self
        
        setupCollection()
        obtenerPeliculas(numPag: self.numPagina)
        
        shouldShowOnboarding()
        
        timerGetMoteMovies = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getMoreMovies), userInfo: nil, repeats: true)
        
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
    
    func showAlertToAction(){
        let alerta = UIAlertController(title: "Atención", message: "Para continuar necesitas tener conexión a internet.", preferredStyle: .alert)
        
        let aceptar = UIAlertAction(title: "Continuar", style: .default) { _ in
            self.checkCacheUpcoming()
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
    
    private func checkCacheUpcoming(){
        if let dataCache = DataCache.instance.readData(forKey: "dataUpcoming") {
            do {
                let moviesFromCache = try JSONDecoder().decode(MovieDataModel.self, from: dataCache)
                self.upcomingMovies = moviesFromCache.results ?? []
                print("Debug: listaProximosEstrenos \(self.upcomingMovies.count)")

                DispatchQueue.main.async {
                    self.estrenosCollection.reloadData()
                    self.hideActivityIndicator()
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
    
    private func shouldShowOnboarding(){
        if !UserDefaults.standard.bool(forKey: "onboarding") {
            showTutorial()
            print("Mostrar tutorial")
            UserDefaults.standard.set(true, forKey: "onboarding")
        }
    }
    
    private func showTutorial(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true)
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
//        self.showActivityIndicator()
        
        manager.getUpcomingMovies(numPagina: numPag) { [weak self] numPages, listaPeliculas, error in
            
            self?.totalPages = numPages
            
            if let listaPeliculas = listaPeliculas {
                self?.upcomingMovies.append(contentsOf: listaPeliculas)  ///Agregar al arreglo
                
                DispatchQueue.main.async { ///Hilo principal, actualizar la Interfaz de usuario
                    self?.estrenosCollection.reloadData()
                    self?.isLoadingMoreCharacters = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                        self?.hideActivityIndicator()
                    }
                }
            }
            
            self?.numPagina += 1
            ///Valida si la pagina actual es menor de las disponibles
            if self?.numPagina == self?.totalPages {
                self?.timerGetMoteMovies.invalidate()
            }
            
        }
    }
    
    
    
    @IBAction func infoButton(_ sender: UIBarButtonItem) {
        showTutorial()
    }
    
    
}

extension MoviesViewController: UIScrollViewDelegate {
}

extension MoviesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 145, height: 195)
    }
}


// MARK:  UICollectionViewDataSource
extension MoviesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return upcomingMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let celda = collectionView.dequeueReusableCell(withReuseIdentifier: "EstrenosCell", for: indexPath) as! EstrenosCell
        
        celda.setupCell(movie: upcomingMovies[indexPath.row])
        
        
        return celda
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let ViewController = storyboard.instantiateViewController(withIdentifier: "DetalleMovieViewController") as! DetalleMovieViewController
        
        ///- * New Flow of Movie Detail
        let storyboard = UIStoryboard(name: "DetalleMovie", bundle: nil)
        let ViewController = storyboard.instantiateViewController(withIdentifier: "DetailTrailersMovieViewController") as! DetailTrailersMovieViewController
        
        ViewController.modalPresentationStyle = .fullScreen ///Tipo de visualizacion
        ViewController.modalTransitionStyle = .crossDissolve ///Tipo de animacion al cambiar pantalla
        
        ///Enviar informacion a traves de la instancia del view controller
        ViewController.recibirPeliculaMostrar = upcomingMovies[indexPath.row]
        
        present(ViewController, animated: true)
    }
    
}
