//
//  DetailTrailersMovieViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 06/04/23.
//

import UIKit
import Kingfisher
import YouTubeiOSPlayerHelper

class DetailTrailersMovieViewController: UIViewController, YTPlayerViewDelegate {
    
    @IBOutlet weak var similarMoviesCollection: UICollectionView!
    @IBOutlet weak var descripcionMovie: UITextView!
    @IBOutlet weak var moreMoviesTrailersSegmented: UISegmentedControl!
    @IBOutlet weak var nameOfMovieLabel: UILabel!
    @IBOutlet weak var releaseDateMovieLabel: UILabel!
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var trailersMovieConstraint: NSLayoutConstraint!
    @IBOutlet weak var relatedMoviesConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailersTableView: UITableView!
    @IBOutlet weak var posterMovieImage: UIImageView!
    
    
    
    /// Variables
    var recibirPeliculaMostrar: DataMovie?
    var manager = MoviesManager()
    var trailerDisponible = false
    var urlTrailer: String = ""
    
    var trailersMovie : [Trailer] = []
    var similarMovies: [DataMovie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerView.delegate = self
        trailersTableView.delegate = self
        trailersTableView.dataSource = self
        trailersTableView.register(UINib(nibName: "TrailerCell", bundle: nil), forCellReuseIdentifier: "TrailerCell")
        
        similarMoviesCollection.delegate = self
        similarMoviesCollection.dataSource = self

        setupUI()
        getTrailers()
        getSimilarMovies()
       
        setupCollectionWithLayout()
    }
    
    func setupCollectionWithLayout() {
        similarMoviesCollection.collectionViewLayout = UICollectionViewFlowLayout()
        if let flowLayout = similarMoviesCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    private func getSimilarMovies() {
        if let idMovie = recibirPeliculaMostrar?.id {
            manager.getSimilarMovies(idMovie: idMovie) { [weak self] similarMovies, error in
                if similarMovies.isEmpty {
                    print("No hay peliculas similares")
                } else {
                    ///Save in array and reload collection
                    DispatchQueue.main.async {
                        self?.similarMovies = similarMovies
                        self?.similarMoviesCollection.reloadData()
                    }
                    
                }
            }
        }
    }
    
    private func getTrailers(){
        if let idMovie = recibirPeliculaMostrar?.id {
            manager.getTrailersMovie(id: idMovie) { [weak self] listOfTrailers, error in
                if listOfTrailers.isEmpty {
                    print("No hay trailer disponible")
                } else {
                    //Play First Trailer and show a list of trailers
                    DispatchQueue.main.async {
                        self?.trailersMovie.append(contentsOf: listOfTrailers)
                        self?.trailersTableView.reloadData()
                        self?.playerView.load(withVideoId: listOfTrailers.last!.key)
                    }
                }
            }
        }
    }
    
    private func setupUI(){
        setupPlayerStyleView()
        /// - Hide playerView and show the posterMovie
        self.playerView.isHidden = true
        self.posterMovieImage.isHidden = false
        showOnlyImageOfMovie()
        
        ///- Constraints for moviesRelated and trailers table
        relatedMoviesConstraint.constant = 0
        trailersMovieConstraint.constant = 1400
        
        nameOfMovieLabel.text = recibirPeliculaMostrar?.title
        descripcionMovie.text = recibirPeliculaMostrar?.overview
        releaseDateMovieLabel.text = "Fecha estreno: \(recibirPeliculaMostrar?.release_date ?? "Próximamente")"
        
        
    }
    
    private func showOnlyImageOfMovie(){
        guard let urlImagen = recibirPeliculaMostrar?.backdrop_path else { return }
        let url = URL(string: "https://image.tmdb.org/t/p/w200/\(urlImagen)")
        
        posterMovieImage.kf.setImage(with: url)
        
    }
    
    private func setupPlayerStyleView(){
        let cornerRadius: CGFloat = 10.0
        let maskLayer = CAShapeLayer()
        
        // redondear solo las esquinas superior izquierda y superior derecha
        maskLayer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        maskLayer.frame = view.bounds
        
        // crear la forma de la máscara
        let path = UIBezierPath(roundedRect: view.bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        maskLayer.path = path.cgPath
        
        // aplicar la máscara
        self.playerView.layer.mask = maskLayer
        
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.playerView.isHidden = false
            self.posterMovieImage.isHidden = true
            self.playerView.playVideo()
        }
        
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func relatedMoviesTrailersAction(_ sender: UISegmentedControl) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        switch sender.selectedSegmentIndex {
        case 0:
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut) {
                self.relatedMoviesConstraint.constant = 0
                self.trailersMovieConstraint.constant = 1400
            }
            
            
        case 1:
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn) {
                self.relatedMoviesConstraint.constant = 400
                self.trailersMovieConstraint.constant = 0
            }
        default:
            break
        }
    }
}

// MARK:  Table View Trailers
extension DetailTrailersMovieViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trailersMovie.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "TrailerCell", for: indexPath) as! TrailerCell
        
        celda.nameTrailerLabel.text = trailersMovie[indexPath.row].name
        ///Se le quitan los ulitmos caracteres a la fecha con este formato: 2022-12-09T19:59:51.000Z
        let dateTrailer = trailersMovie[indexPath.row].publishedAt
        let index = dateTrailer.index(dateTrailer.startIndex, offsetBy: 10)
        let mySubstring = dateTrailer[..<index]
        
        celda.dateReleaseTrailerLabel.text = "Fecha: \(mySubstring)"
        
        if let urlImagen = recibirPeliculaMostrar?.backdrop_path {
            let url = URL(string: "https://image.tmdb.org/t/p/w200/\(urlImagen)")
            
            celda.posterTrailer.kf.setImage(with: url)
            celda.posterTrailer.layer.cornerRadius = 20
            celda.posterTrailer.layer.masksToBounds = true
        }
        
        
        return celda
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ViewController = storyboard.instantiateViewController(withIdentifier: "TrailerViewController") as! TrailerViewController
        
        ViewController.modalPresentationStyle = .fullScreen ///Tipo de visualizacion
        ViewController.modalTransitionStyle = .crossDissolve ///Tipo de animacion al cambiar pantalla
        
        ViewController.recibirIdTrailerMostrar = trailersMovie[indexPath.row].key
        
        present(ViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
}

extension DetailTrailersMovieViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        similarMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let celda = collectionView.dequeueReusableCell(withReuseIdentifier: "SimilarMovieCell", for: indexPath) as! SimilarMovieCell
        
        celda.setup(movie: similarMovies[indexPath.row])
        
        return celda
    }
    
    
}

//EXTENSION
extension DetailTrailersMovieViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        15
    }
}
