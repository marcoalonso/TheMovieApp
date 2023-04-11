//
//  CinesCercanosViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 11/04/23.
//

import UIKit
import CoreLocation
import MapKit

class CinesCercanosViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var cinesLabel: UILabel!
    @IBOutlet weak var mapaCines: MKMapView!
    
    var manager = CLLocationManager()
    var userLocation: CLLocation?
    
    var activityView: UIActivityIndicatorView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager.delegate = self
        mapaCines.delegate = self
        
        ///Pedir el permiso del usuario.
        manager.requestWhenInUseAuthorization()
        
        showActivityIndicator()
    }
    
    func showActivityIndicator() {
        self.cinesLabel.text = "Buscando cines cercanos ... "
        activityView = UIActivityIndicatorView(style: .large)
        activityView?.center = self.view.center
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
    }
    
    func hideActivityIndicator(){
        if (activityView != nil){
            activityView?.stopAnimating()
        }
        self.cinesLabel.text = "Cines encontrados"
    }
    
    
    

    func performSearch(place: String = "cine") {
        print("Debug: Buscando cines cercanos")

        self.mapaCines.removeAnnotations(self.mapaCines.annotations)
        
        guard let userLocation = userLocation else { return }
        
        /// Realiza un busqueda alrededor de la ubicacion del usuario
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = place
        
        request.region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 6000, longitudinalMeters: 6000)
        
        ///Comienza con la búsqueda
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            /// Agrega los resultado al mapa
            for item in response.mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                annotation.subtitle = place
                //Animacion
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.mapaCines.addAnnotation(annotation)
                }, completion: nil)
            }
        }
        
        ///Nivel de zoom al mapa
        let spanMapa = MKCoordinateSpan(latitudeDelta: 0.09, longitudeDelta: 0.09)
        let regionMapa = MKCoordinateRegion(center: userLocation.coordinate, span: spanMapa)
        
        ///Agregar la region al mapa y mostrar la ubicacion del usuario
        mapaCines.setRegion(regionMapa, animated: true)
        self.mapaCines.showsUserLocation = true
        
        self.hideActivityIndicator()
    }
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "OK", style: .default) { _ in
            //Do something
        }
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
    }
    
    
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}

extension CinesCercanosViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        ///Si se obtiene la ubicación la guarda
        userLocation = locations.last
        print("Debug: userLocation \(userLocation?.coordinate)")
        
        ///Muestra en el mapa la ubicacion del usuario
        self.mapaCines.showsUserLocation = true
        
        performSearch()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error al obtener ubicacion : \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            mostrarAlerta(titulo: "ATENCIÓN", mensaje: "No hemos podido obtener tu ubicación.")
        case .restricted:
            mostrarAlerta(titulo: "ATENCIÓN", mensaje: "Es posible que tu ubicación no sea la más precisa ya que esta limitada, cambia los permisos en configuración.")
        case .denied:
            mostrarAlerta(titulo: "ATENCIÓN", mensaje: "Error al obtener ubicacion debido a que no tenemos tu permiso.")
        case .authorizedAlways:
            print("authorizedAlways")
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            //Acceder a la ubicacion
            manager.requestLocation()
        case .authorized:
            print("authorized")
        @unknown default:
            fatalError("Error desconocido :/")
        }
    }
}
