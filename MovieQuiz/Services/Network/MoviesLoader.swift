//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Ilia Liasin on 10/09/2024.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    
    private let networkClient = NetworkClient()
    
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    
                    if mostPopularMovies.errorMessage.isEmpty {
                        handler(.success(mostPopularMovies))
                    } else {
                        let error = ApiError.errorMessage(mostPopularMovies.errorMessage)
                        handler(.failure(error))
                    }
                } catch {
                    handler(.failure(error))
                }
                
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    private enum ApiError: Error {
        case errorMessage(String)
    }
}
