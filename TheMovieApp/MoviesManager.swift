//
//  MoviesManager.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 29/03/23.
//

import Foundation

struct MoviesManager {
    func obtenerProximosEstrenos(numPagina: Int = 1, completion: @escaping (Int, [EstrenoMovie]?, Error?) -> Void ) {
        //URL
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/upcoming?api_key=2cfa8720256036601fb9ac4e4bce1a9b&language=es-MX&page=\(numPagina)") else { return }
        
        let tarea = URLSession.shared.dataTask(with: url) { data, _, error in
            
            guard let data = data, error == nil else {
                print("Error al obtener la data desde el server")
                completion(0, nil, error)
                return
            }
            
            print("Debug: data : \(data)")

            ///Mostrar data decodificada usando utf8
            let str = String(decoding: data, as: UTF8.self)
            print("Data str : \(str)")
            
            do {
                
                ///Decodificando la data que previamente desenvolvi
                let dataDecodificada = try JSONDecoder().decode(MovieDataModel.self, from: data)
                let listaPeliculas = dataDecodificada.results ///Extraer la informacion de las peliculas
                let numPages = dataDecodificada.total_pages
                completion(numPages ?? 0, listaPeliculas, nil) ///Devuelve al ViewController el arreglo de peliculas
                
            } catch {
                print("Error al decodificar la data \(error.localizedDescription)")
            }
            
        }
        
        tarea.resume()
    }
    
    
    ///Consultar trailers
    func getTrailersMovie(id: Int, completion: @escaping ([Trailer], Error?) -> Void ){
        
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(id)/videos?api_key=2cfa8720256036601fb9ac4e4bce1a9b&language=es_MX") else { return }
        
        let tarea = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion([], error)
                print("Error al realizar la peticion")
                return
            }
            
            do {
                let respuesta = try JSONDecoder().decode(ResponseTrailerModel.self, from: data)
                let listaTrailers = respuesta.results
                completion(listaTrailers, nil)
            } catch {
                print("Debug: error al decodificar la data \(error.localizedDescription)")

            }
        }
        tarea.resume()
    }
}
