//
//  MovieViewModel.swift
//  FindIT
//
//  Created by Eseosa Atekha on 2024-01-01.
//

import Foundation
import UIKit

class MovieViewModel: ObservableObject {
    @Published var movie: Movie
    

    init(movie: Movie) {
        self.movie = movie
    }

    func openExternalURL(link: String) {
        guard let url = URL(string: link) else {
            print("Invalid URL")
            return
        }
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
    }
    
    
    func starFillValue(for rating: Double, at index: Int) -> Double {
            let starNumber = Double(index + 1)
            if rating >= starNumber {
                return 1.0 // Full star
            } else if rating > Double(index) {
                return rating - Double(index) // Partial star for decimals
            } else {
                return 0.0 // Empty star
            }
        }
    
    static func sampleMovie() -> Movie {
        return Movie(
            title: "Spider Man: No Way Home",
            overview: """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
            """,
            releaseDate: "2023-01-01",
            posterPath: "https://image.tmdb.org/t/p/original/14QbnygCuTO0vl7CAFmPf1fgZfV.jpg",
            trailer: "https://www.youtube.com/watch?v=JfVOs4VSpmA",
            movieLink: "https://movie-web.app/media/tmdb-movie-634649-spider-man-no-way-home",
            dialogue_start: "00:56:46",
            backdrop_path: "https://www.themoviedb.org/t/p/w1280/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg",
            genres: ["Comedy", "Action", "Adventure"],
            rating: 3.5
        )
    }
}
