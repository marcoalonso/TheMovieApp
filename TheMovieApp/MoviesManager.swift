//
//  MoviesManager.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 29/03/23.
//

import Foundation

struct MoviesManager {
    func obtenerProximosEstrenos(numPagina: Int = 1, completion: @escaping ([EstrenoMovie]?, Error?) -> Void ) {
        //URL
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/upcoming?api_key=2cfa8720256036601fb9ac4e4bce1a9b&language=es-MX&page=1") else { return }
        
        let tarea = URLSession.shared.dataTask(with: url) { data, _, error in
            
            guard let data = data, error == nil else {
                print("Error al obtener la data desde el server")
                completion(nil, error)
                return
            }
            
            do {
                ///Decodificando la data que previamente desenvolvi
                let dataDecodificada = try JSONDecoder().decode(MovieDataModel.self, from: data)
                let listaPeliculas = dataDecodificada.results ///Extraer la informacion de las peliculas
                
                completion(listaPeliculas, nil) ///Devuelve al ViewController el arreglo de peliculas
            } catch {
                print("Error al decodificar la data \(error.localizedDescription)")
            }
            
        }
        
        tarea.resume()
    }
}
