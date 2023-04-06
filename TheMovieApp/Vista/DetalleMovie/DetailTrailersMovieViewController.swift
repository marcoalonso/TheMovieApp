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
    
    @IBOutlet weak var descripcionMovie: UITextView!
    @IBOutlet weak var moreMoviesTrailersSegmented: UISegmentedControl!
    @IBOutlet weak var nameOfMovieLabel: UILabel!
    @IBOutlet weak var releaseDateMovieLabel: UILabel!
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var trailersMovieConstraint: NSLayoutConstraint!
    @IBOutlet weak var relatedMoviesConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailersTableView: UITableView!
    
    /// Variables
    var recibirPeliculaMostrar: DataMovie?
    var manager = MoviesManager()
    
    var trailerDisponible = false
    var urlTrailer: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerView.delegate = self

        setupUI()
        getTrailers()
    }
    
    private func getTrailers(){
        if let idMovie = recibirPeliculaMostrar?.id {
            manager.getTrailersMovie(id: idMovie) { [weak self] listOfTrailers, error in
                if listOfTrailers.isEmpty {
                    print("No hay trailer disponible")
                    DispatchQueue.main.async {
                        //Show only image
                        self?.showOnlyImageOfMovie()
                    }
                } else {
                    //Play First Trailer and show a list of trailers
                    DispatchQueue.main.async {
                        self?.playerView.load(withVideoId: listOfTrailers.last!.key)
                    }
                }
            }
        }
    }
    
    private func setupUI(){
        setupPlayerStyleView()
        
        nameOfMovieLabel.text = recibirPeliculaMostrar?.title
        descripcionMovie.text = recibirPeliculaMostrar?.overview
        releaseDateMovieLabel.text = "Fecha estreno: \(recibirPeliculaMostrar?.release_date ?? "Próximamente")"
        
        
    }
    
    private func showOnlyImageOfMovie(){
        guard let urlImagen = recibirPeliculaMostrar?.backdrop_path else { return }
        let url = URL(string: "https://image.tmdb.org/t/p/w200/\(urlImagen)")
        let posterImage = UIImage()
        let posterMovieImage = UIImageView(image: posterImage)
        self.playerView.addSubview(posterMovieImage)
        posterMovieImage.kf.setImage(with: url)
        posterMovieImage.frame = CGRect(x: 0, y: 0, width: self.playerView.frame.size.width, height: 180)
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
        self.playerView.playVideo()
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func relatedMoviesTrailersAction(_ sender: UISegmentedControl) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        switch sender.selectedSegmentIndex {
        case 0:
            relatedMoviesConstraint.constant = 0
            trailersMovieConstraint.constant = 400
        case 1:
            relatedMoviesConstraint.constant = 400
            trailersMovieConstraint.constant = 0
        default:
            break
        }
    }
    

}
