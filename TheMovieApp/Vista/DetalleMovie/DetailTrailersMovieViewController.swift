//
//  DetailTrailersMovieViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 06/04/23.
//

import UIKit
import Kingfisher
import YouTubeiOSPlayerHelper
import CoreData

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
    @IBOutlet weak var favouriteStyleButton: UIButton!
    @IBOutlet weak var wishLateStyleButton: UIButton!
    @IBOutlet weak var posterMovieImage: UIImageView!
    @IBOutlet weak var favouriteInfoLabel: UILabel!
    @IBOutlet weak var watchLateInfoLabel: UILabel!
    
    @IBOutlet weak var shareButtonContraint: NSLayoutConstraint!
    
    /// Variables
    var recibirPeliculaMostrar: DataMovie?
    var recibirPosterMovie: Data?
    var manager = MoviesManager()
    var trailerDisponible = false
    var urlTrailer: String = ""
    
    var trailersMovie : [Trailer] = []
    var similarMovies: [DataMovie] = []
    var isFavourite = false
    var watchLate = false
    
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Predicados en core data para filtrar elementos
    var commitPredicate: NSPredicate?
    var wishCommitPredicateW: NSPredicate?
    
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        shareButtonContraint.constant = 0
        searchInFavouriteMovies()
        searchInWatchLate()
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
        trailersMovieConstraint.constant = 400
        self.trailersTableView.isHidden = false
        
        nameOfMovieLabel.text = recibirPeliculaMostrar?.title
        descripcionMovie.text = recibirPeliculaMostrar?.overview
        releaseDateMovieLabel.text = "Fecha estreno: \(recibirPeliculaMostrar?.release_date ?? "Próximamente")"
        
        
        
    }
    
    ///This function verify if the selected movie is already saved as favorite
    private func searchInFavouriteMovies() {
        let fetchRequest: NSFetchRequest<FavouriteMovie> = FavouriteMovie.fetchRequest()

        guard let id = recibirPeliculaMostrar!.id else { return }
        print("Debug: idMovie \(id)")
        
        self.commitPredicate = NSPredicate(format: "id = %i", id)

        fetchRequest.predicate = self.commitPredicate

        do {
          let resultados = try contexto.fetch(fetchRequest)
            if resultados.first != nil {
            // Marcar como favorita la movie y poder eliminarla
              favouriteInfoLabel.isHidden = false
                self.favouriteInfoLabel.text = "¡Favorita!"
              favouriteStyleButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
              isFavourite = true
          } else {
            // Se puede marcar como favorita
              favouriteInfoLabel.isHidden = true
          }
        } catch {
          // Ocurrió un error al realizar la consulta a Core Data
          print("Error al consultar movie por ID: \(error.localizedDescription)")
        }

    }
    
    private func searchInWatchLate(){
        let fetchRequest: NSFetchRequest<WishMovie> = WishMovie.fetchRequest()
        guard let id = recibirPeliculaMostrar!.id else { return }
        print("Debug: watchLate \(id)")
        
        self.wishCommitPredicateW = NSPredicate(format: "id = %i", id)

        fetchRequest.predicate = self.commitPredicate

        do {
          let resultados = try contexto.fetch(fetchRequest)
            if resultados.first != nil {
            // Marcar como favorita la movie y poder eliminarla
              watchLateInfoLabel.isHidden = false
                self.watchLateInfoLabel.text = "¡Quiero verla!"
              wishLateStyleButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
              watchLate = true
          } else {
              watchLateInfoLabel.isHidden = true
          }
        } catch {
          // Ocurrió un error al realizar la consulta a Core Data
          print("Error al consultar movie por ID: \(error.localizedDescription)")
        }
    }
    
    private func showOnlyImageOfMovie(){
        guard let urlImagen = recibirPeliculaMostrar?.poster_path else { return }
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
    
    private func saveMovieAsFavourite(){
        let newMovie = FavouriteMovie(context: contexto)
        if let movie = recibirPeliculaMostrar {
            let idMovie = Int64(movie.id!)
            newMovie.id = idMovie
            newMovie.titulo = self.nameOfMovieLabel.text
            newMovie.descripcion = self.descripcionMovie.text
            newMovie.fecha = self.releaseDateMovieLabel.text
            newMovie.poster = self.posterMovieImage.image?.pngData()
            do {
                try contexto.save()
                print("Guardado en favoritos!")
                animationIsFavourite()
            } catch  {
                print("Error al guardar en la bd", error.localizedDescription)
            }
        }
    }
    
    private func saveMovieToWathcLate(){
        let watchLateMovie = WishMovie(context: contexto)
        if let movie = recibirPeliculaMostrar {
            let idMovie = Int64(movie.id!)
            watchLateMovie.id = idMovie
            watchLateMovie.titulo = self.nameOfMovieLabel.text
            watchLateMovie.descripcion = self.descripcionMovie.text
            watchLateMovie.fecha = self.releaseDateMovieLabel.text
            watchLateMovie.poster = self.posterMovieImage.image?.pngData()
            do {
                try contexto.save()
                print("DEbug: Guardado en ver mas tarde!")
                animationWatchLate()
            } catch  {
                print("Error al guardar en la bd", error.localizedDescription)
            }
        }
    }
  
    
    private func animationWatchLate(){
        if !watchLate {
            watchLate = true
            wishLateStyleButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                self.watchLateInfoLabel.isHidden = false
                self.watchLateInfoLabel.text = "¡Me gustaría verla!"
            }, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {
                    self.watchLateInfoLabel.text = "¡Quiero verla!"
                }, completion: nil)
            }
        }
    }
    
    private func animationIsFavourite(){
        if !isFavourite {
            isFavourite = true
            favouriteStyleButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                self.favouriteInfoLabel.isHidden = false
                self.favouriteInfoLabel.text = "¡Agregada a favoritos!"
            }, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {
                    self.favouriteInfoLabel.text = "¡Favorita!"
                }, completion: nil)
            }
        }
    }
    
    
    // MARK:  Actions
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func favouriteButton(_ sender: UIButton) {
        if !isFavourite {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            saveMovieAsFavourite()
        }
    }
    
    @IBAction func wishButton(_ sender: UIButton) {
        if !watchLate {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            //Guardar en core data
            saveMovieToWathcLate()
        }
    }
    
  
    @IBAction func shareButton(_ sender: UIButton) {
        print("Debug: share Button Tapped")

        var elementosCompartir: [Any] = [nameOfMovieLabel.text ?? "Movieverse World",
                                         "https://apps.apple.com/us/app/movieverse-world/id6447369429"]
        
        
        if let poster = self.recibirPosterMovie {
            if let image = UIImage(data: poster) {
                elementosCompartir.append(image)
            }
        } 
        

        let activityViewController = UIActivityViewController(activityItems: elementosCompartir, applicationActivities: nil)

        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = (sender as AnyObject).bounds
            popoverController.permittedArrowDirections = .any
        }

        present(activityViewController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func relatedMoviesTrailersAction(_ sender: UISegmentedControl) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        switch sender.selectedSegmentIndex {
        case 0:
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut) {
                self.relatedMoviesConstraint.constant = 0
                self.trailersMovieConstraint.constant = 400
                self.trailersTableView.isHidden = false
            }
            
            
        case 1:
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn) {
                self.relatedMoviesConstraint.constant = 400
                self.trailersMovieConstraint.constant = 0
                self.trailersTableView.isHidden = true
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
        
        if let urlImagen = recibirPeliculaMostrar?.poster_path {
            let url = URL(string: "\(Constants.urlImages)\(urlImagen)")
            
            celda.posterTrailer.kf.setImage(with: url)
            celda.posterTrailer.layer.cornerRadius = 20
            celda.posterTrailer.layer.masksToBounds = true
            
        }
        
        if let imagenCoreData = recibirPosterMovie {
            let image = UIImage(data: imagenCoreData)
            celda.posterTrailer.image = image
            celda.posterTrailer.layer.cornerRadius = 20
            celda.posterTrailer.layer.masksToBounds = true
            shareButtonContraint.constant = 30
        } else {
            shareButtonContraint.constant = 0
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
